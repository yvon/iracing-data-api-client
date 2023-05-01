defmodule Iracing.Api.Http do
  @middleware [
    {Tesla.Middleware.BaseUrl, "https://members-ng.iracing.com"},
    {Tesla.Middleware.JSON, engine_opts: [keys: :atoms]}
  ]

  @adapter {Tesla.Adapter.Hackney, recv_timeout: 30_000}

  @client Tesla.client(@middleware, @adapter)

  defp request(options) do
    Tesla.request!(@client, options)
  end
end
