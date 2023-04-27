defmodule Iracing.Api.Fake do
  @behaviour Iracing.Api

  @email "john@example.org"
  @password "secret"
  @cookie "auth-token=42"

  def authenticate(@email, @password) do
    [@cookie]
  end

  def get([@cookie], "/data/results/search_series", start_range_begin: _) do
    %{
      data: %{
        chunk_info: %{
          base_download_url: "CHUNKS/",
          chunk_file_names: ["DATA0"]
        }
      }
    }
  end

  def get([@cookie], "/data/member/profile", []) do
    %{link: "MEMBER_PROFILE"}
  end

  def get("MEMBER_PROFILE") do
    %{profile: %{}}
  end

  def get("CHUNKS/DATA0") do
    [%{subsession_id: 42}]
  end

  def get([@cookie], "/data/series/seasons", []) do
    File.read!(Path.join(__DIR__, "fake/series/seasons.json")) |> Jason.decode!(keys: :atoms)
  end
end
