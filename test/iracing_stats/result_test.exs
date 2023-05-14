defmodule IracingStats.ResultTest do
  use ExUnit.Case, async: false
  alias IracingStats.Result

  @subsession_id 4242

  setup do
    File.rm("results/#{@subsession_id}.json")
    pid = self()

    query_function = fn "/data/results/get", query: [subsession_id: @subsession_id] ->
      send(pid, :request)
      %{id: @subsession_id}
    end

    {:ok, query_function: query_function}
  end

  test "queries iRacing API", %{query_function: query_function} do
    %{id: @subsession_id} = Result.fetch(@subsession_id, query_function)
    assert_received :request
  end

  test "caches the result", %{query_function: query_function} do
    %{id: @subsession_id} = Result.fetch(@subsession_id, query_function)
    assert_received :request
    %{id: @subsession_id} = Result.fetch(@subsession_id, query_function)
    refute_received :request
  end
end
