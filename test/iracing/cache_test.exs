defmodule Iracing.CacheTest do
  use ExUnit.Case, async: true

  test "allows authenticated requests" do
    %{profile: _} = Iracing.Cache.data("/data/member/profile")
  end
end
