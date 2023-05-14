defmodule IracingStats.CachedRequestTest do
  use ExUnit.Case, async: true

  test "allows authenticated requests" do
    %{profile: _} = IracingStats.CachedRequest.data("/data/member/profile")
  end
end
