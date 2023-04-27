defmodule Iracing.SeasonTest do
  use ExUnit.Case, async: true

  test "includes IMSA season" do
    seasons = Iracing.Season.all()
    assert Enum.any?(seasons, &(&1.series_id == 447))
  end
end
