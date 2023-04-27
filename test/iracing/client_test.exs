defmodule Iracing.ClientTest do
  use ExUnit.Case
  doctest Iracing.Client

  test "can fetch profile data" do
    {:ok, pid} = Iracing.Client.start_link({"john@example.org", "secret"})
    data = Iracing.Client.data(pid, "/data/member/profile")
    assert Map.has_key?(data, :profile)
  end

  test "can search series" do
    {:ok, pid} = Iracing.Client.start_link({"john@example.org", "secret"})
    query = [start_range_begin: DateTime.to_iso8601(DateTime.utc_now())]
    data = Iracing.Client.data(pid, "/data/results/search_series", query)
    assert Map.has_key?(hd(data), :subsession_id)
  end
end
