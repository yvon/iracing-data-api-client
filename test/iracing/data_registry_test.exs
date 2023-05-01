defmodule Iracing.DataRegistryTest do
  use ExUnit.Case, async: true

  setup do
    pid = self()

    %{
      perform_request: fn options ->
        send(pid, {:request, options})
        Iracing.FakeClient.request(options)
      end
    }
  end

  test "caches authentication", %{perform_request: perform_request} do
    cookies = Iracing.DataRegistry.authenticate(perform_request)
    assert_received {:request, _}
    ^cookies = Iracing.DataRegistry.authenticate(perform_request)
    refute_received {:request, _}
    assert cookies == ["auth-token=42"]
  end

  test "caches request to profile", %{perform_request: perform_request} do
    Iracing.DataRegistry.get("/data/member/profile", [], perform_request)
    assert_received {:request, method: :get, url: "MEMBER_PROFILE"}
    Iracing.DataRegistry.get("/data/member/profile", [], perform_request)
    refute_received {:request, method: :get, url: "MEMBER_PROFILE"}
  end
end
