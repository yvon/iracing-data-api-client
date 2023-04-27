defmodule Iracing.Season do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  @impl true
  def init([]) do
    {:ok, nil}
  end

  @impl true
  def handle_call(:all, _from, nil) do
    data = Iracing.AuthenticatedClient.data("/data/series/seasons")
    {:reply, data, data}
  end

  @impl true
  def handle_call(:all, _from, data) do
    {:reply, data, data}
  end
end
