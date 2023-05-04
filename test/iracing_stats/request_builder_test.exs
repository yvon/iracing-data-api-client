defmodule RequestBuilderTest do
  alias IracingStats.RequestBuilder
  use ExUnit.Case, async: true

  test "authenticates user and return cookies" do
    [cookie | _] = RequestBuilder.authenticate()
    assert cookie == "auth-token=42"
  end

  test "follows links" do
    cookies = RequestBuilder.authenticate()
    data = RequestBuilder.get(cookies, "/data/member/profile")
    assert Map.has_key?(data, :profile)
  end

  test "can search series" do
    cookies = RequestBuilder.authenticate()
    query = [start_range_begin: DateTime.to_iso8601(DateTime.utc_now())]
    data = RequestBuilder.get(cookies, "/data/results/search_series", query)
    assert Map.has_key?(hd(data), :subsession_id)
  end
end
