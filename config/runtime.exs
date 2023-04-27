import Config

credentials =
  case config_env() do
    :test ->
      [email: "john@example.org", password: "secret"]

    _ ->
      [
        email: System.fetch_env!("IRACING_EMAIL"),
        password: System.fetch_env!("IRACING_PASSWORD")
      ]
  end

config :iracing, credentials
