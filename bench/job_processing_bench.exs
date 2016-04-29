defmodule Verk.JobProcessingBench do
  use Benchfella

   setup_all do
     { :ok, _ } = Application.ensure_all_started(:tzdata)

     Verk.Supervisor.start_link
     Verk.add_queue(:benchmark, 100)
     {:ok, []}
   end

  bench "Verk", [jobs: jobs] do
    Enum.each(jobs, fn(job) ->
      Verk.enqueue(job)
    end)

    check_job_queue
  end

  defp check_job_queue do
    Verk.Queue.count(:benchmark)
    |> check_job_queue
  end

  defp check_job_queue({:ok, 0}) do
    :ok
  end

  defp check_job_queue(_) do
    :timer.sleep(100)
    check_job_queue
  end

  defp jobs do
    Enum.map(1..100000, fn(x) ->
      %Verk.Job{queue: :benchmark, class: "ExampleWorker", args: [x, 1]}
    end)
  end
end


defmodule ExampleWorker do
  def perform(a, b) do
    a + b
  end
end
