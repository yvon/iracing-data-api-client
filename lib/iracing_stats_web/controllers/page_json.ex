defmodule IracingStatsWeb.PageJSON do
  def chart(%{points: points}) do
    points =
      for %{session: session, result: result} <- points,
          do: %{
            irating: result.oldi_rating,
            lap_time: result.best_lap_time,
            start_time: session.start_time,
            display_name: result.display_name,
            car_name: result.car_name
          }

    %{points: points}
  end
end
