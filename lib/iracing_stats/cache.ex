defmodule IracingStats.Cache do
  alias IracingStats.{RequestBuilder, CachedContent}

  # By default, authentication is cached for 20 minutes
  @auth_ttl 60 * 20
  # Other data for two hours
  @default_ttl 3600 * 2

  def child_spec(_options) do
    Registry.child_spec(keys: :unique, name: __MODULE__)
  end

  def data(url), do: data(url, [])

  def data(url, options) do
    authenticate() |> data(url, options)
  end

  def data(cookies, url, options) do
    query = Keyword.get(options, :query, [])
    ttl = Keyword.get(options, :ttl, @default_ttl)

    fn options -> fetch(options, ttl) end
    |> RequestBuilder.get(cookies, url, query)
  end

  defp authenticate do
    fn -> RequestBuilder.authenticate(&request/1) end
    |> fetch(:cookies, @auth_ttl)
  end

  defp fetch(init, key, ttl) do
    name = {:via, Registry, {__MODULE__, key}}
    GenServer.start_link(CachedContent, {init, ttl}, name: name)
    CachedContent.get(name)
  end

  defp fetch(options, ttl) do
    :get = Keyword.fetch!(options, :method)
    url = Keyword.fetch!(options, :url)
    query = Keyword.get(options, :query, [])

    init = fn ->
      response = request(options)

      case response.status do
        200 -> response
        _ -> nil
      end
    end

    fetch(init, {url, query}, ttl)
  end

  defp client, do: Application.fetch_env!(:iracing_stats, :client)
  defp request(options), do: client().request(options)
end
