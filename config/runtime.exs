import Config

if config_env() == :test do
  config :iracing, email: "john@example.com", password: "secret"
else
  config :iracing,
    email: System.fetch_env!("IRACING_EMAIL"),
    password: System.fetch_env!("IRACING_PASSWORD")
end
