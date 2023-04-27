defmodule Iracing.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    season_names =
      for season <- Iracing.Season.all(),
          do: season.season_name

    send_resp(conn, 200, Enum.join(season_names, "\n"))
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
