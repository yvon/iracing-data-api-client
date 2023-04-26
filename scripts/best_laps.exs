defmodule GenerateData do
  # IMSA
  @series_id 447
  # Races
  @event_types 5

  def spawn_link(email, password) do
    parent = self()
    spawn_link(fn -> run(parent, email, password) end)
  end

  def run(parent, email, password) do
    {:ok, client} = Iracing.Client.start_link({email, password})

    %{
      "season_year" => year,
      "season_quarter" => quarter,
      "race_week" => week
    } = current_season(client)

    info("#{year} S#{quarter} W#{week}")
    search_series = search_series(client, year, quarter, week)

    # TODO: concurrency
    for %{"subsession_id" => subsession_id} <- search_series,
        session <- results(client, subsession_id)["session_results"],
        session["simsession_type_name"] == "Race",
        result <- session["results"],
        result["drop_race"] == false,
        result["average_lap"] > 0,
        result["car_class_short_name"] == "IMSA23",
        result["class_interval"] > 0,
        do: send(parent, "#{result["oldi_rating"]} #{result["best_lap_time"]}")

    send(parent, :done)
  end

  defp info(msg) do
    IO.puts(:stderr, msg)
  end

  defp current_season(client) do
    Iracing.Client.data(client, "/data/series/seasons")
    |> Enum.find(&matching_season?/1)
  end

  defp matching_season?(data) do
    data["series_id"] == @series_id and data["active"] == true
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
        info("Fetching results from #{subsession_id} subsession")
        query = [subsession_id: subsession_id]
        data = Iracing.Client.data(client, "/data/results/get", query)
        FileCache.cache(cache_key, Jason.encode!(data))
        data

      data ->
        info("Reading cache data from #{subsession_id} subsession")
        Jason.decode!(data)
    end
  end

  defp cache_key(subsession_id) do
    "result_#{subsession_id}"
  end
end

defmodule Plot do
  @script_path Path.join(__DIR__, "best_laps.gp")

  def generate do
    data_path = Path.join(System.tmp_dir!(), "data.gp")
    generate_data(data_path)
    {_, 0} = System.cmd("gnuplot", [data_path, @script_path], into: IO.stream())
  end

  def generate_data(path) do
    File.open(path, [:write], fn file ->
      IO.puts(file, "$Data << EOD")
      write_messages(file)
      IO.puts(file, "EOD")
    end)
  end

  defp write_messages(file) do
    receive do
      :done ->
        :done

      message ->
        IO.puts(file, message)
        write_messages(file)
    end
  end
end

email = System.fetch_env!("IRACING_EMAIL")
password = System.fetch_env!("IRACING_PASSWORD")

GenerateData.spawn_link(email, password)
Plot.generate()
