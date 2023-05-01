import Config

if config_env() == :test do
  config :iracing, client: Iracing.FakeClient
else
  config :iracing, client: Iracing.HttpClient
end
