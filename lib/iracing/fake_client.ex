defmodule Iracing.FakeClient do
  @cookie "auth-token=42"

  @auth_body %{
    email: "john@example.com",
    password: "fsJTSA1NM6b2kkU/Yc8s7NjIGBNDCbuwwS835DjTJwM="
  }

  def request(options) when is_list(options) do
    respond_to(Map.new(options))
  end

  defp respond_to(%{method: :post, url: "/auth", body: @auth_body}) do
    %{headers: [{"set-cookie", @cookie}]}
  end

  defp respond_to(options = %{headers: [{"cookie", @cookie}], method: :get}) do
    data(options)
  end

  defp respond_to(%{method: :get, url: "MEMBER_PROFILE"}) do
    respond_with(%{profile: %{}})
  end

  defp respond_to(%{method: :get, url: "CHUNKS/DATA0"}) do
    respond_with([%{subsession_id: 42}])
  end

  defp data(%{url: "/data/member/profile"}) do
    %{link: "MEMBER_PROFILE"} |> respond_with
  end

  defp data(%{url: "/data/results/search_series", query: [start_range_begin: _]}) do
    respond_with(%{
      data: %{
        chunk_info: %{
          base_download_url: "CHUNKS/",
          chunk_file_names: ["DATA0"]
        }
      }
    })
  end

  defp respond_with(body) do
    %{body: body}
  end
end
