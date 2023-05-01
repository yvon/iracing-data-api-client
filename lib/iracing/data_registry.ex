defmodule Iracing.DataRegistry do
  # 20 minutes
  @auth_ttl 60 * 20
  # Two hours
  @default_ttl 3600 * 2
  @perform_request &Iracing.HttpClient.request/1

  def child_spec(options) do
    Registry.child_spec(keys: :unique, name: __MODULE__)
  end

  def authenticate(f \\ @perform_request) do
    init = fn -> Iracing.RequestBuilder.authenticate(f, email(), password()) end
    cache(@auth_ttl, :cookies, init)
  end

  def get(url, options \\ [], f \\ @perform_request) do
    cookies = authenticate(f)
    query = Keyword.get(options, :query, [])
    ttl = Keyword.get(options, :ttl, @default_ttl)
    key = {url, query}
    init = fn -> Iracing.RequestBuilder.get(f, cookies, url, query) end
    cache(ttl, key, init)
  end

  defp cache(ttl, key, init) do
    name = {:via, Registry, {__MODULE__, key}}
    GenServer.start_link(CachedContent, {init, ttl}, name: name)
    CachedContent.get(name)
  end

  defp email, do: Application.fetch_env!(:iracing, :email)
  defp password, do: Application.fetch_env!(:iracing, :password)
end
