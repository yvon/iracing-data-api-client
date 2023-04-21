defmodule FileCacheTest do
  use ExUnit.Case

  setup do
    File.mkdir_p("cache/")
    :ok
  end

  test "caches a value and retrieves it" do
    FileCache.cache("key", "value")
    assert FileCache.get("key") == "value"
  end

  test "returns nil for a missing value" do
    assert FileCache.get("missing_key") == nil
  end

  test "removes a cached value" do
    FileCache.cache("key", "value")
    FileCache.remove("key")
    assert FileCache.get("key") == nil
  end

  test "clears the cache" do
    FileCache.cache("key1", "value1")
    FileCache.cache("key2", "value2")
    FileCache.clear()
    assert FileCache.get("key1") == nil
    assert FileCache.get("key2") == nil
  end
end
