# IracingStats

A simple Iracing data API client in Elixir.
It follows links and consolidate chunks.

Refer to [Iracing forum post](https://forums.iracing.com/discussion/15068/general-availability-of-data-api/p1)
for all available endpoints.

## Usage

```elixir
{:ok, pid} = Iracing.Client.start_link({email, password})
data = Iracing.Client.data(pid, "/data/data/member/profile")
```

Client can be registered via `:name` option.  
Cf https://hexdocs.pm/elixir/GenServer.html#module-name-registration.

```elixir
Iracing.Client.start_link({email, password}, name: :iracing_client)
Iracing.Client.data(:iracing_client, "/data/data/member/profile")
```

## Example

```
mix run examples/search_series.exs YOUR_IRACING_EMAIL YOUR_IRACING_PASSWORD
```
