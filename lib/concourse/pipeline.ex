defmodule Concourse.Pipeline do
  require YamlElixir

  defstruct [:jobs, :resources]

  @type t :: %Concourse.Pipeline{
          jobs: list(Concourse.Pipeline.Job.t()),
          resources: list(Concourse.Pipeline.Resource.t())
        }

  @spec parse(String.t()) :: nil | Concourse.Pipeline.t()
  def parse(filename) do
    payload = YamlElixir.read_from_file(filename)

    case payload do
       map when is_map(map) ->
        %Concourse.Pipeline{
          jobs: jobs(payload["jobs"]),
          resources: resources(payload["resources"])
        }

      _ ->
        nil
    end
  end

  @spec pipeline(map()) :: Concourse.Pipeline.t()
  defp pipeline(payload) do
  end

  @spec resources(any()) :: list(Concourse.Pipeline.Resource.t())
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

  defp resources(_), do: []

  @spec jobs(any()) :: list(Concourse.Pipeline.Job.t())
  defp jobs([job | jobs]) do
    [
      %Concourse.Pipeline.Job{
        name: job["name"],
        plan: Concourse.Pipeline.Job.plan(job["plan"])
      }
      | jobs(jobs)
    ]
  end

  defp jobs(_), do: []
end
