import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :iracing_stats, IracingStatsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ArNsRlolCX8vshGUO7sIp58u+5Y25rkPChYTgTK/7s+lxea+EejKF5aQldU0e1D2",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :iracing_stats,
  email: "john@example.com",
  password: "secret",
  client: IracingStats.FakeClient
