defmodule Concourse.Pipeline do
  require YamlElixir

  defstruct [:jobs, :resources]

  def parse(filename) do
    payload = YamlElixir.read_from_file(filename)
    pipeline(payload)
  end

  defp pipeline(payload) do
    %Concourse.Pipeline{
      jobs: jobs(payload["jobs"]),
      resources: resources(payload["resources"])
    }
  end

  defp resources(nil), do: []
  defp resources([]), do: []

  defp resources([resource | resources]) do
    [
      %Concourse.Pipeline.Resource{
        name: resource["name"],
        type: resource["type"],
        source: resource["source"]
      }
      | resources(resources)
    ]
  end

  defp jobs(nil), do: []
  defp jobs([]), do: []

  defp jobs([job | jobs]) do
    [
      %Concourse.Pipeline.Job{
        name: job["name"],
        plan: Concourse.Pipeline.Job.plan(job["plan"])
      }
      | jobs(jobs)
    ]
  end
end
