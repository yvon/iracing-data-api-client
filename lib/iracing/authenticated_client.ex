defmodule Iracing.AuthenticatedClient do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def data(url, query \\ []) do
    cookies() |> api().get(url, query) |> follow_links
  end

  @impl true
  def init([]) do
    email = Application.fetch_env!(:iracing, :email)
    password = Application.fetch_env!(:iracing, :password)

    GenServer.cast(self(), {:init, email, password})
    {:ok, %{cookies: []}}
  end

  @impl true
  def handle_call(:cookies, _from, state) do
    {:reply, state.cookies, state}
  end

  @impl true
  def handle_cast({:init, email, password}, _state) do
    cookies = api().authenticate(email, password)
    {:noreply, %{cookies: cookies}}
  end

  defp download_and_merge_chunks(base_download_url, chunks) do
    Enum.reduce(chunks, [], fn chunk, acc ->
      url = base_download_url <> chunk
      acc ++ api().get(url)
    end)
  end

  defp follow_links(%{data: %{chunk_info: chunk_info}}) do
    %{
      base_download_url: base_download_url,
      chunk_file_names: chunk_file_names
    } = chunk_info

    download_and_merge_chunks(base_download_url, chunk_file_names)
  end

  defp follow_links(%{link: link}) do
    api().get(link)
  end

  defp follow_links(body), do: body

  def cookies() do
    GenServer.call(__MODULE__, :cookies)
  end

  defp api do
    Application.fetch_env!(:iracing, :api)
  end
end
