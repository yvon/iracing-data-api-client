defmodule Iracing.Router do
  use Plug.Router

  @template_dir "lib/iracing/router/templates"

  plug(:match)
  plug(:dispatch)

  get "/" do
    render(conn, "index.html.eex", seasons: Iracing.Season.active())
  end

  get "/seasons/:season_id" do
    send_resp(conn, 200, season_id)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp render(%{status: status} = conn, template, assigns \\ []) do
    body = @template_dir |> Path.join(template) |> EEx.eval_file(assigns)
    send_resp(conn, status || 200, body)
  end
end
