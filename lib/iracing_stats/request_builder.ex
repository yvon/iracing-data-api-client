defmodule IracingStats.RequestBuilder do
  def authenticate(), do: authenticate(&client().request/1)

  def authenticate(fun) do
    %{headers: headers} =
      fun.(
        method: :post,
        url: "/auth",
        body: %{
          email: email(),
          password: hash_password()
        }
      )

    for {k, v} <- headers, k == "set-cookie", do: v
  end

  def get(cookies, url, query \\ []) do
    get(cookies, url, query, &client().request/1)
  end

  def get(cookies, url, query, fun) do
    headers = build_headers(cookies)
    body = fun.(method: :get, url: url, query: query, headers: headers) |> response_body()
    follow_links(body, fun)
  end

  defp follow_links(%{data: %{chunk_info: chunk_info}}, fun) do
    %{
      base_download_url: base_download_url,
      chunk_file_names: chunk_file_names
    } = chunk_info

    download_and_merge_chunks(base_download_url, chunk_file_names, fun)
  end

  defp follow_links(%{link: link}, fun) do
    fun.(method: :get, url: link) |> response_body()
  end

  defp follow_links(body, _fun), do: body

  defp download_and_merge_chunks(base_download_url, chunks, fun) do
    Enum.reduce(chunks, [], fn chunk, acc ->
      url = base_download_url <> chunk
      acc ++ response_body(fun.(method: :get, url: url))
    end)
  end

  defp build_headers(cookies) do
    Enum.map(cookies, fn v -> {"cookie", v} end)
  end

  defp hash_password() do
    :crypto.hash(:sha256, password() <> email()) |> Base.encode64()
  end

  def response_body(response) do
    unless response.status == 200, do: raise("Request failed: #{inspect(response)}")
    response.body
  end

  defp email, do: Application.fetch_env!(:iracing_stats, :email)
  defp password, do: Application.fetch_env!(:iracing_stats, :password)
  defp client, do: Application.fetch_env!(:iracing_stats, :client)
end
