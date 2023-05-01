defmodule Iracing.Cache do
  # 20 minutes
  @auth_ttl 60 * 20
  # Two hours
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

    fn -> Iracing.RequestBuilder.get(cookies, url, query) end
    |> fetch({url, query}, ttl)
  end

  defp authenticate do
    fn -> Iracing.RequestBuilder.authenticate() end
    |> fetch(:cookies, @auth_ttl)
  end

  defp fetch(function, key, ttl) do
    name = {:via, Registry, {__MODULE__, key}}
    GenServer.start_link(CachedContent, {function, ttl}, name: name)
    CachedContent.get(name)
  end
end
