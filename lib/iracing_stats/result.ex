defmodule IracingStats.Result do
  @ten_minutes 600

  def fetch(subsession_id) do
    query_method = fn "/data/results/get", query: [subsession_id: ^subsession_id] ->
      # With a nil ttl only the authentication request is cached.
      IracingStats.CachedRequest.data("/data/results/get",
        query: [subsession_id: subsession_id],
        ttl: nil
      )
    end

    fetch(subsession_id, query_method)
  end

  def fetch(subsession_id, query_method) do
    fun = fn -> init(subsession_id, query_method) end
    key = {:result, subsession_id}

    # Cache the result for 10 minutes.
    # Requesting a dedicated genserver prevents race conditions writing/reading the file.
    # We don't want to cache longer than 10 minutes because it's huge chunk of data. That's what the file is for.
    IracingStats.CachedContent.fetch(fun, key, @ten_minutes)
  end

  defp init(subsession_id, query_method) do
    file = "results/#{subsession_id}.json"

    # I considered using DETS, but it's not worth the hassle. I don't require key/value lookups.
    if File.exists?(file) do
      File.read!(file) |> Jason.decode!(keys: :atoms)
    else
      content = query_method.("/data/results/get", query: [subsession_id: subsession_id])
      File.write!(file, Jason.encode!(content))
      content
    end
  end
end
