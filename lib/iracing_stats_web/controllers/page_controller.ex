defmodule IracingStatsWeb.PageController do
  use IracingStatsWeb, :controller
  alias IracingStats.Cache

  @one_hour 3600
  @one_day @one_hour * 24
  @one_week @one_day * 7

  def home(conn, _params) do
    assets = Cache.data("/data/series/assets", ttl: @one_day)
    render(conn, :home, seasons: seasons(), assets: assets)
  end

  def season(conn, %{"id" => id}) do
    season_id = String.to_integer(id)
    season = Enum.find(seasons(), fn e -> e.season_id == season_id end)
    week = Enum.find(season.schedules, fn e -> e.race_week_num == season.race_week end)
    car_classes = for id <- season.car_class_ids, do: car_classe(id)
    assets = Cache.data("/data/series/assets", ttl: @one_day)
    logo = assets[season.series_id |> Integer.to_string() |> String.to_existing_atom()][:logo]

    render(conn, :season, season: season, week: week, car_classes: car_classes, logo: logo)
  end

  def chart(conn, params) do
    season_id = String.to_integer(params["season_id"])
    race_week = String.to_integer(params["race_week"])
    car_class_id = String.to_integer(params["car_class_id"])

    # Concurrent requests
    stream =
      subsession_ids(season_id, race_week)
      |> Task.async_stream(&result(&1))

    points =
      for {:ok, data} <- stream,
          session <- data.session_results,
          # Exclude pratices and qualifications
          session.simsession_type_name == "Race",
          result <- session.results,
          # Members who finished the race
          result.drop_race == false,
          # Under the winner lap
          result.class_interval > 0,
          # Only concerned class
          result.car_class_id == car_class_id,
          # With lap times (I have -1 values)
          result.best_lap_time > 0,
          # With irating (I have -1 values, rookies?)
          result.oldi_rating > 0,
          do: {result.oldi_rating, result.best_lap_time}

    render(conn, :chart, points: points)
  end

  defp seasons do
    Cache.data("/data/series/seasons", ttl: @one_day)
  end

  defp subsession_ids(season_id, race_week) do
    for result <- results_list(season_id, race_week),
        result.event_type_name == "Race",
        result.official_session == true,
        do: result.subsession_id
  end

  defp result(subsession_id) do
    query = [subsession_id: subsession_id]
    Cache.data("/data/results/get", query: query, ttl: @one_week)
  end

  defp results_list(season_id, race_week) do
    query = [season_id: season_id, race_week_num: race_week]
    Cache.data("/data/results/season_results", query: query, ttl: @one_day).results_list
  end

  defp car_classe(id) do
    Cache.data("/data/carclass/get", ttl: @one_day)
    |> Enum.find(fn e -> e.car_class_id == id end)
  end
end
