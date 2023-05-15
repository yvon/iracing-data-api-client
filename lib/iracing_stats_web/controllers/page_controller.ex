defmodule IracingStatsWeb.PageController do
  use IracingStatsWeb, :controller
  alias IracingStats.{CachedAuth, CachedContent}

  def home(conn, _params) do
    render(conn, :home, seasons: seasons(), assets: assets())
  end

  def season(conn, %{"id" => id}) do
    season_id = String.to_integer(id)
    season = season(season_id)

    render(conn, :season,
      season: season,
      week: week(season),
      car_classes: car_classes(season),
      logo: logo(season),
      page_title: season.season_name
    )
  end

  def chart(conn, params) do
    season_id = String.to_integer(params["season_id"])
    race_week = String.to_integer(params["race_week"])
    car_class_id = String.to_integer(params["car_class_id"])

    # Concurrent requests
    stream =
      subsession_ids(season_id, race_week)
      |> Task.async_stream(&IracingStats.Result.fetch/1)

    points =
      for {:ok, data} <- stream,
          session <- data.session_results,
          # Exclude pratices and qualifications
          session.simsession_type_name == "Race",
          result <- session.results,
          # Members who finished the race
          result.drop_race == false,
          # Under the winner lap
          result.class_interval >= 0,
          # Only concerned class
          result.car_class_id == car_class_id,
          # With lap times (I have -1 values)
          result.best_lap_time > 0,
          # With irating (I have -1 values, rookies?)
          result.oldi_rating > 0,
          do: %{session: data, result: result}

    render(conn, :chart, points: points)
  end

  defp seasons do
    init = fn -> CachedAuth.get("/data/series/seasons") end
    # Cache for 1 hour
    CachedContent.fetch(init, :seasons, 3600)
  end

  def season(id) do
    Enum.find(seasons(), fn e -> e.season_id == id end)
  end

  def assets do
    init = fn -> CachedAuth.get("/data/series/assets") end
    # Cache for a day
    CachedContent.fetch(init, :assets, 3600 * 24)
  end

  def logo(season) do
    assets()[season.series_id |> Integer.to_string() |> String.to_existing_atom()][:logo]
  end

  def week(season) do
    Enum.find(season.schedules, fn e -> e.race_week_num == season.race_week end)
  end

  def car_classes(season) do
    for id <- season.car_class_ids, do: car_classe(id)
  end

  defp subsession_ids(season_id, race_week) do
    for result <- results_list(season_id, race_week),
        result.event_type_name == "Race",
        result.official_session == true,
        do: result.subsession_id
  end

  defp results_list(season_id, race_week) do
    query = [season_id: season_id, race_week_num: race_week]
    CachedAuth.get("/data/results/season_results", query).results_list
  end

  defp car_classe(id) do
    CachedContent.fetch(fn -> CachedAuth.get("/data/carclass/get") end, :car_classes, 3600)
    |> Enum.find(&(&1.car_class_id == id))
  end
end
