defmodule IracingStatsWeb.PageSVG do
  @path System.find_executable("gnuplot")
  @options [:exit_status, :binary, args: ["-", "scripts/best_laps.gp"]]

  def chart(%{points: points}) do
    Port.open({:spawn_executable, @path}, @options)
    |> send_gp_data(points)
    |> receive_xml
  end

  defp send_gp_data(port, points) do
    Port.command(port, "$Data << EOD\n")
    Enum.each(points, fn {x, y} -> Port.command(port, "#{x} #{y}\n") end)
    Port.command(port, "EOD\n")
    Port.command(port, "exit\n")
    port
  end

  defp receive_xml(port, acc \\ "") do
    receive do
      {^port, {:data, data}} ->
        receive_xml(port, acc <> data)

      {^port, {:exit_status, 0}} ->
        acc
    after
      5000 -> raise("No message received from gnuplot")
    end
  end
end
