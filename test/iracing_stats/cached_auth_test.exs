defmodule IracingStats.CachedAuthTest do
  use ExUnit.Case, async: true

  test "allows authenticated requests" do
    %{profile: _} = IracingStats.CachedAuth.get("/data/member/profile")
  end
end
