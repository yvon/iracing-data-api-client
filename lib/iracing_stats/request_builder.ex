defmodule IracingStats.RequestBuilder do
  def authenticate(request) when is_function(request, 1) do
    %{headers: headers} =
      request.(
        method: :post,
        url: "/auth",
        body: %{
          email: email(),
          password: hash_password()
        }
      )

    for {k, v} <- headers, k == "set-cookie", do: v
  end

  def get(request, cookies, url, query \\ []) do
    headers = build_headers(cookies)
    body = request.(method: :get, url: url, query: query, headers: headers).body
    follow_links(request, body)
  end

  defp follow_links(request, %{data: %{chunk_info: chunk_info}}) do
    %{
      base_download_url: base_download_url,
      chunk_file_names: chunk_file_names
    } = chunk_info

    download_and_merge_chunks(request, base_download_url, chunk_file_names)
  end

  defp follow_links(request, %{link: link}) do
    request.(method: :get, url: link).body
  end

  defp follow_links(_request, body), do: body

  defp download_and_merge_chunks(request, base_download_url, chunks) do
    Enum.reduce(chunks, [], fn chunk, acc ->
      url = base_download_url <> chunk
      acc ++ request.(method: :get, url: url).body
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
end
