defmodule RequestBuilderTest do
  use ExUnit.Case, async: true

  test "authenticates user and return cookies" do
    [cookie | _] = Iracing.RequestBuilder.authenticate()
    assert cookie == "auth-token=42"
  end

  test "follows links" do
    cookies = Iracing.RequestBuilder.authenticate()
    data = Iracing.RequestBuilder.get(cookies, "/data/member/profile")
    assert Map.has_key?(data, :profile)
  end

  test "can search series" do
    cookies = Iracing.RequestBuilder.authenticate()
    query = [start_range_begin: DateTime.to_iso8601(DateTime.utc_now())]
    data = Iracing.RequestBuilder.get(cookies, "/data/results/search_series", query)
    assert Map.has_key?(hd(data), :subsession_id)
  end
end
