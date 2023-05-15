defmodule RequestBuilderTest do
  alias IracingStats.RequestBuilder
  use ExUnit.Case, async: true

  @request &IracingStats.FakeClient.request/1

  test "authenticates user and return cookies" do
    [cookie | _] = RequestBuilder.authenticate(@request)
    assert cookie == "auth-token=42"
  end

  test "follows links" do
    cookies = RequestBuilder.authenticate(@request)
    data = RequestBuilder.get(cookies, "/data/member/profile", [], @request)
    assert Map.has_key?(data, :profile)
  end

  test "can search series" do
    cookies = RequestBuilder.authenticate(@request)
    query = [start_range_begin: DateTime.to_iso8601(DateTime.utc_now())]
    data = RequestBuilder.get(cookies, "/data/results/search_series", query, @request)
    assert Map.has_key?(hd(data), :subsession_id)
  end
end
