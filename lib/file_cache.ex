defmodule FileCache do
  @cache_dir "cache/"

  # Cache a value with a given key
  def cache(key, value) do
    File.write!(cache_path(key), value)
    value
  end

  # Retrieve a cached value for a given key
  def get(key) do
    case File.read(cache_path(key)) do
      {:ok, data} -> data
      {:error, :enoent} -> nil
    end
  end

  # Remove a cached value for a given key
  def remove(key) do
    File.rm(cache_path(key))
  end

  # Clear the entire cache
  def clear() do
    File.rm_rf(@cache_dir)
    File.mkdir_p(@cache_dir)
  end

  # Get the file path for a given cache key
  defp cache_path(key) do
    "#{@cache_dir}#{key}"
  end
end
