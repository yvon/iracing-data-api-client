defmodule IracingStats.CachedContent do
  use GenServer

  @registry __MODULE__.Registry

  def child_spec(_options) do
    Registry.child_spec(keys: :unique, name: @registry)
  end

  def fetch(fun, key, ttl) do
    name = {:via, Registry, {@registry, key}}
    # We try to start a new Genserver. It might be already started, which is fine.
    # If not, it will be started and the init function will be called.
    GenServer.start_link(__MODULE__, {fun, ttl}, name: name)
    # Regardless we ask for the content.
    GenServer.call(name, :get)
  end

  @impl true
  def init({function, ttl}) when is_number(ttl) do
    Process.send_after(self(), :expired, ttl * 1000)
    init(function)
  end

  @impl true
  def init(function) do
    value = function.()

    case value do
      nil -> {:stop, {:shutdown, :nil_value}, nil}
      _ -> {:ok, value}
    end
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
