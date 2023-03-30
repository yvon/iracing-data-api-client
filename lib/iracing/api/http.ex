defmodule Iracing.Api.Http do
  @moduledoc """
  Performs HTTP calls to Iracing /data API
  https://forums.iracing.com/discussion/15068/general-availability-of-data-api/p1

      iex> %{"EMAIL" => email, "PASSWD" => passwd} = System.get_env
      iex> cookies = Iracing.Api.Http.authenticate(email, passwd)
      iex> profile = Iracing.Api.Http.get(cookies, "/data/member/profile")
      iex> Map.has_key?(profile, "link")
      true

  """

  @behaviour Iracing.Api

  @middleware [
    {Tesla.Middleware.BaseUrl, "https://members-ng.iracing.com"},
    Tesla.Middleware.JSON
  ]

  @adapter {Tesla.Adapter.Hackney, recv_timeout: 30_000}

  @client Tesla.client(@middleware, @adapter)

  def authenticate(email, password) do
    %{headers: headers} =
      request(
        method: "post",
        url: "/auth",
        body: %{
          email: email,
          password: hash_password(email, password)
        }
      )

    for {k, v} <- headers, k == "set-cookie", do: v
  end

  def get(cookies, url, query \\ []) do
    request(cookies, method: :get, url: url, query: query).body
  end

  def get(url) do
    request(method: :get, url: url).body
  end

  defp request(options) do
    Tesla.request!(@client, options)
  end

  defp request(cookies, options) do
    auth_headers = Enum.map(cookies, fn v -> {"cookie", v} end)

    options =
      Keyword.update(options, :headers, auth_headers, fn headers ->
        headers ++ auth_headers
      end)

    request(options)
  end

  defp hash_password(email, password) do
    :crypto.hash(:sha256, password <> email) |> Base.encode64()
  end
end
