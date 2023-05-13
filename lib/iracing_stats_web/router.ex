defmodule IracingStatsWeb.Router do
  use IracingStatsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :put_root_layout, {IracingStatsWeb.Layouts, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IracingStatsWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/seasons/:id", PageController, :season
  end

  scope "/api", IracingStatsWeb do
    pipe_through :api

    get "/chart/:season_id/:race_week/:car_class_id", PageController, :chart
  end

  # Other scopes may use custom stacks.
  # scope "/api", IracingStatsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:iracing_stats, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: IracingStatsWeb.Telemetry
    end
  end
end
