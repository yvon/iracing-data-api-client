defmodule IracingStats.CacheTest do
  use ExUnit.Case, async: true

  test "allows authenticated requests" do
    %{profile: _} = IracingStats.Cache.data("/data/member/profile")
  end
end
