[email, password] = System.argv()
{:ok, pid} = Iracing.Client.start_link({email, password})

# IMSA
series_id = 447
# races
event_types = 5
# 8 hours ago
start_range_begin = DateTime.utc_now() |> DateTime.add(-3600 * 8)

query = [
  start_range_begin: DateTime.to_iso8601(start_range_begin),
  series_id: series_id,
  official_only: true,
  event_types: event_types
]

data = Iracing.Client.data(pid, "/data/results/search_series", query)
IO.inspect(data)
