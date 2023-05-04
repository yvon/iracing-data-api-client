defmodule IracingStats.CachedContent do
  use GenServer

  def get(pid) do
    GenServer.call(pid, :get)
  end

  @impl true
  def init({function, ttl}) when is_number(ttl) do
    Process.send_after(self(), :expired, ttl * 1000)
    init(function)
  end

  @impl true
  def init(function) do
    {:ok, function.()}
  end

  @impl true
  def handle_call(:get, _from, content) do
    {:reply, content, content}
  end

  @impl true
  def handle_info(:expired, _state) do
    {:stop, {:shutdown, :expired}, nil}
  end
end
