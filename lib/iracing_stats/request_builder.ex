defmodule IracingStats.RequestBuilder do
  def authenticate() do
    %{headers: headers} =
      client().request(
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
    headers = build_headers(cookies)

    client().request(method: :get, url: url, query: query, headers: headers).body
    |> follow_links
  end

  defp follow_links(%{data: %{chunk_info: chunk_info}}) do
    %{
      base_download_url: base_download_url,
      chunk_file_names: chunk_file_names
    } = chunk_info

    download_and_merge_chunks(base_download_url, chunk_file_names)
  end

  defp follow_links(%{link: link}) do
    client().request(method: :get, url: link).body
  end

  defp follow_links(body), do: body

  defp download_and_merge_chunks(base_download_url, chunks) do
    Enum.reduce(chunks, [], fn chunk, acc ->
      url = base_download_url <> chunk
      acc ++ client().request(method: :get, url: url).body
    end)
  end

  defp build_headers(cookies) do
    Enum.map(cookies, fn v -> {"cookie", v} end)
  end

  defp hash_password() do
    :crypto.hash(:sha256, password() <> email()) |> Base.encode64()
  end

  defp email, do: Application.fetch_env!(:iracing_stats, :email)
  defp password, do: Application.fetch_env!(:iracing_stats, :password)
  defp client, do: Application.fetch_env!(:iracing_stats, :client)
end
