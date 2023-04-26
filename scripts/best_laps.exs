defmodule GenerateData do
  # IMSA
  @series_id 447
  # Races
  @event_types 5

  def run(email, password) do
    {:ok, client} = Iracing.Client.start_link({email, password})

    %{
      season_year: year,
      season_quarter: quarter,
      race_week: week
    } = current_season(client)

    IO.puts("#{year} S#{quarter} W#{week}")
    search_series = search_series(client, year, quarter, week)

    stream =
      Task.async_stream(search_series, fn subsession ->
        results(client, subsession.subsession_id)
      end)

    for {:ok, data} <- stream,
        session <- data.session_results,
        # Exclude pratices and qualifications
        session.simsession_type_name == "Race",
        result <- session.results,
        # Members who finished the race
        result.drop_race == false,
        # Under the winner lap
        result.class_interval > 0,
        # Group results by car class
        reduce: %{} do
      acc ->
        point = {result.oldi_rating, result.best_lap_time}
        Map.update(acc, result.car_class_id, [], &[point | &1])
    end
  end

  defp current_season(client) do
    Iracing.Client.data(client, "/data/series/seasons")
    |> Enum.find(&matching_season?/1)
  end

  defp matching_season?(data) do
    data.series_id == @series_id and data.active == true
  end

  defp search_series(client, year, quarter, week) do
    # Up to 7 days ago
    start_range_begin = DateTime.utc_now() |> DateTime.add(-3600 * 24 * 7)

    query = [
      start_range_begin: DateTime.to_iso8601(start_range_begin),
      season_year: year,
      season_quarter: quarter,
      race_week_num: week,
      series_id: @series_id,
      official_only: true,
      event_types: @event_types
    ]

    Iracing.Client.data(client, "/data/results/search_series", query)
  end

  defp results(client, subsession_id) do
    cache_key = cache_key(subsession_id)

    case FileCache.get(cache_key) do
      nil ->
        IO.puts("Fetching results from #{subsession_id} subsession")
        query = [subsession_id: subsession_id]
        data = Iracing.Client.data(client, "/data/results/get", query)
        FileCache.cache(cache_key, Jason.encode!(data))
        data

      data ->
        IO.puts("Reading cache data from #{subsession_id} subsession")
        Jason.decode!(data, keys: :atoms)
    end
  end

  defp cache_key(subsession_id) do
    "result_#{subsession_id}"
  end
end

defmodule Plot do
  @shared_script Path.join(__DIR__, "best_laps.gp")

  def generate({basename, points}) do
    path = write_gp_script(basename, points)
    {_, 0} = System.cmd("gnuplot", [path, @shared_script], into: IO.stream())
  end

  defp write_gp_script(basename, points) do
    path = Path.join(System.tmp_dir!(), "#{basename}.gp")

    File.open(path, [:write], fn f ->
      IO.puts(f, "$Data << EOD")
      Enum.each(points, fn {x, y} -> IO.puts(f, "#{x} #{y}") end)

      IO.puts(f, """
      EOD
      set output "public_html/#{basename}.svg"
      """)
    end)

    path
  end
end

email = System.fetch_env!("IRACING_EMAIL")
password = System.fetch_env!("IRACING_PASSWORD")

GenerateData.run(email, password) |> Enum.each(&Plot.generate/1)
