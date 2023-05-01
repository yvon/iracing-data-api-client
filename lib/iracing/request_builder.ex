defmodule Iracing.RequestBuilder do
  def authenticate(perform_request, email, password) do
    %{headers: headers} =
      perform_request.(
        method: :post,
        url: "/auth",
        body: %{
          email: email,
          password: hash_password(email, password)
        }
      )

    for {k, v} <- headers, k == "set-cookie", do: v
  end

  def get(perform_request, cookies, url, query \\ []) do
    headers = build_headers(cookies)
    body = perform_request.(method: :get, url: url, query: query, headers: headers).body
    follow_links(perform_request, body)
  end

  defp follow_links(perform_request, %{data: %{chunk_info: chunk_info}}) do
    %{
      base_download_url: base_download_url,
      chunk_file_names: chunk_file_names
    } = chunk_info

    download_and_merge_chunks(perform_request, base_download_url, chunk_file_names)
  end

  defp follow_links(perform_request, %{link: link}) do
    perform_request.(method: :get, url: link).body
  end

  defp follow_links(_, body) do
    body
  end

  defp download_and_merge_chunks(perform_request, base_download_url, chunks) do
    Enum.reduce(chunks, [], fn chunk, acc ->
      url = base_download_url <> chunk
      acc ++ perform_request.(method: :get, url: url).body
    end)
  end

  defp build_headers(cookies) do
    Enum.map(cookies, fn v -> {"cookie", v} end)
  end

  defp hash_password(email, password) do
    :crypto.hash(:sha256, password <> email) |> Base.encode64()
  end
end
