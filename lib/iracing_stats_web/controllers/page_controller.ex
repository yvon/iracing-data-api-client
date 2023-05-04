defmodule IracingStatsWeb.PageController do
  use IracingStatsWeb, :controller
  alias IracingStats.Cache

  def home(conn, _params) do
    seasons = IracingStats.Cache.data("/data/series/seasons")
    render(conn, :home, seasons: seasons)
  end

  def season(conn, %{"id" => id}) do
    season =
      Cache.data("/data/series/seasons")
      |> Enum.find(&(&1.season_id == String.to_integer(id)))

    week =
      season.schedules
      |> Enum.find(&(&1.race_week_num == season.race_week))

    car_classes =
      for car_class_id <- season.car_class_ids,
          do: car_classe(car_class_id)

    render(conn, :season, season: season, week: week, car_classes: car_classes)
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
          do: {result.oldi_rating, result.best_lap_time}

    render(conn, :chart, points: points)
  end

  defp subsession_ids(season_id, race_week) do
    for result <-
          Cache.data("/data/results/season_results",
            query: [
              season_id: season_id,
              race_week_num: race_week
            ]
          ).results_list,
        result.event_type_name == "Race",
        result.official_session == true,
        do: result.subsession_id
  end

  defp result(subsession_id) do
    Cache.data("/data/results/get", query: [subsession_id: subsession_id])
  end

  defp car_classe(id) do
    Cache.data("/data/carclass/get")
    |> Enum.find(&(&1.car_class_id == id))
  end
end
