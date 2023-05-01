defmodule RequestBuilderTest do
  use ExUnit.Case, async: true

  @request &Iracing.FakeClient.request/1
  @user "john@example.com"
  @password "secret"

  test "authenticates user and return cookies" do
    [cookie | _] = Iracing.RequestBuilder.authenticate(@request, @user, @password)
    assert cookie == "auth-token=42"
  end

  test "follows links" do
    cookies = Iracing.RequestBuilder.authenticate(@request, @user, @password)
    data = Iracing.RequestBuilder.get(@request, cookies, "/data/member/profile")
    assert Map.has_key?(data, :profile)
  end

  test "can search series" do
    cookies = Iracing.RequestBuilder.authenticate(@request, @user, @password)
    query = [start_range_begin: DateTime.to_iso8601(DateTime.utc_now())]
    data = Iracing.RequestBuilder.get(@request, cookies, "/data/results/search_series", query)
    assert Map.has_key?(hd(data), :subsession_id)
  end
end
