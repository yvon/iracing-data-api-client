defmodule Iracing.Client do
  use GenServer

  @doc """
  Starts a GenServer process.

      iex> {:ok, pid} = Iracing.Client.start_link({"john@example.org", "secret"})
      iex> is_pid(pid)
      true

  """
  def start_link({email, password}, options \\ []) do
    GenServer.start_link(__MODULE__, {email, password}, options)
  end

  @doc """
  Query the API with authentication cookies.

      iex> {:ok, pid} = Iracing.Client.start_link({"john@example.org", "secret"})
      iex> data = Iracing.Client.data(pid, "/data/member/profile")
      iex> is_map(data)
      true

  """
  def data(pid, url, query \\ []) do
    cookies(pid) |> api().get(url, query) |> follow_links
  end

  @impl true
  def init({email, password}) do
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

  def cookies(pid) do
    GenServer.call(pid, :cookies)
  end

  defp api do
    Application.fetch_env!(:iracing, :api)
  end
end
