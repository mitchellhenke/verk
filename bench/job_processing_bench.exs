defmodule LastWorker do
  def perform() do
    send(:benchmarking_process, :done)
  end
end

defmodule ExampleWorker do
  def perform() do
  end
end

defmodule Verk.JobProcessingBench do
  { :ok, _ } = Application.ensure_all_started(:tzdata)

  Verk.Supervisor.start_link
  Verk.Queue.clear("benchmark")
  Process.register(self, :benchmarking_process)
  Enum.each(1..100000, fn(_) ->
    {:ok, _ } = Verk.enqueue %Verk.Job{queue: :benchmark, class: "ExampleWorker", args: []}
  end)

  IO.inspect "wait"
  :timer.sleep(2000)
  Verk.enqueue %Verk.Job{queue: :benchmark, class: "LastWorker", args: []}

  start = :erlang.monotonic_time(:micro_seconds)
  Verk.add_queue(:benchmark, 200)

  receive do
    :done -> IO.puts "#{(:erlang.monotonic_time(:micro_seconds) - start)/1000.0} ms"
  end
end
