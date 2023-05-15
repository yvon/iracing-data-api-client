defmodule IracingStats.CachedAuth do
  # Authentication is cached for 20 minutes
  @auth_ttl 60 * 20

  def get(url, query \\ []) do
    authenticate() |> IracingStats.RequestBuilder.get(url, query)
  end

  defp authenticate do
    init = fn -> IracingStats.RequestBuilder.authenticate() end
    IracingStats.CachedContent.fetch(init, :cookies, @auth_ttl)
  end
end
