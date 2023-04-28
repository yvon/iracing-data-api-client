defmodule CachedContentTest do
  use ExUnit.Case, async: true

  test "stores evaluated value" do
    value = DateTime.utc_now()
    function = fn -> value end
    {:ok, pid} = GenServer.start_link(CachedContent, function)
    assert CachedContent.get(pid) == value
  end

  test "expires and shuts down" do
    function = fn -> nil end
    {:ok, pid} = GenServer.start(CachedContent, {function, 0})
    Process.monitor(pid)
    assert_receive {:DOWN, _, _, pid, _}
    refute Process.alive?(pid)
  end
end
