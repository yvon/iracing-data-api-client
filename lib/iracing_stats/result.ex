defmodule IracingStats.Result do
  # 10 minutes
  @cache_duration 600

  def fetch(subsession_id), do: fetch(subsession_id, &IracingStats.CachedAuth.get/2)

  def fetch(subsession_id, query_method) do
    fun = fn -> init(subsession_id, query_method) end
    key = {:result, subsession_id}

    # Dedicated genserver prevents race conditions while writing/reading the file.
    # That's a very likely scenario, since I request several charts for a given subsession at once.
    # That's also the reason I cache the content in memory for 10 minutes.
    IracingStats.CachedContent.fetch(fun, key, @cache_duration)
  end

  defp init(subsession_id, query_method) do
    file = "results/#{subsession_id}.json"

    # I considered using DETS, but it's not worth the hassle. I don't require key/value lookups.
    if File.exists?(file) do
      File.read!(file) |> Jason.decode!(keys: :atoms)
    else
      content = query_method.("/data/results/get", subsession_id: subsession_id)
      File.write!(file, Jason.encode!(content))
      content
    end
  end
end
