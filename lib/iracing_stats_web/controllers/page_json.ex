defmodule IracingStatsWeb.PageJSON do
  def chart(%{points: points}) do
    points =
      for {irating, lap_time} <- points,
          do: %{irating: irating, lap_time: lap_time}

    %{points: points}
  end
end
