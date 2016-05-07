defmodule LastWorker do
  def perform() do
    send(:benchmarking_process, :done)
  end
end

defmodule ExampleWorker do
  def perform(a, b) do
    a + b
  end
end
defmodule Verk.JobProcessingBench do
  { :ok, _ } = Application.ensure_all_started(:tzdata)

  Verk.Supervisor.start_link
  Verk.add_queue(:benchmark, 75)
  Verk.Queue.clear("benchmark")
  Process.register(self, :benchmarking_process)
  jobs = Enum.map(1..1000, fn(x) ->
    %Verk.Job{queue: :benchmark, class: "ExampleWorker", args: [x, 1]}
  end)

  start = :erlang.monotonic_time(:micro_seconds)
  Enum.each(jobs, fn(job) ->
    Verk.enqueue(job)
  end)

  last_job = %Verk.Job{queue: :benchmark, class: "LastWorker", args: []}
  Verk.enqueue(last_job)

  receive do
    :done -> IO.puts "#{(:erlang.monotonic_time(:micro_seconds) - start)/1000.0} ms"
  end
end
