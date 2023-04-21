defmodule Mix.Tasks.BestLaps do
  use Mix.Task

  # Wait for app
  @requirements ["app.start"]

  @file_path "data.txt"

  # IMSA
  @series_id 447
  # Races
  @event_types 5

  def run([email, password]) do
    {:ok, pid} = Iracing.Client.start_link({email, password})

    %{
      "season_year" => year,
      "season_quarter" => quarter,
      "race_week" => week
    } = current_season(pid)

    info("#{year} S#{quarter} W#{week}")
    search_series = search_series(pid, year, quarter, week)

    File.open(@file_path, [:write], fn file ->
      for %{"subsession_id" => subsession_id} <- search_series,
          session <- results(pid, subsession_id)["session_results"],
          session["simsession_type_name"] == "Race",
          result <- session["results"],
          result["drop_race"] == false,
          result["average_lap"] > 0,
          result["car_class_short_name"] == "IMSA23",
          result["class_interval"] > 0,
          do: IO.puts(file, "#{result["oldi_rating"]} #{result["best_lap_time"]}")
    end)
  end

  defp info(msg) do
    IO.puts(:stderr, msg)
  end

  defp current_season(pid) do
    Iracing.Client.data(pid, "/data/series/seasons")
    |> Enum.find(&matching_season?/1)
  end

  defp matching_season?(data) do
    data["series_id"] == @series_id and data["active"] == true
  end

  defp search_series(pid, year, quarter, week) do
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

    Iracing.Client.data(pid, "/data/results/search_series", query)
  end

  defp results(pid, subsession_id) do
    cache_key = cache_key(subsession_id)

    case FileCache.get(cache_key) do
      nil ->
        info("Fetching results from #{subsession_id} subsession")
        query = [subsession_id: subsession_id]
        data = Iracing.Client.data(pid, "/data/results/get", query)
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
