defmodule Concourse.Pipeline do
  require YamlElixir

  defstruct [
    :jobs,
    :resources,
    :resource_types,
    :groups
  ]

  @type t :: %__MODULE__{
          jobs: list(Concourse.Pipeline.Job.t()),
          resources: list(Concourse.Pipeline.Resource.t()),
          groups: list(Concourse.Pipeline.Group.t()),
          resource_types: list(Concourse.Pipeline.ResourceType.t())
        }

  @spec parse(String.t()) :: __MODULE__.t()
  def parse(filename) do
    filename = String.to_charlist(filename)
    payload = YamlElixir.read_from_file(filename)

    %Concourse.Pipeline{
      jobs: jobs(payload["jobs"]),
      resources: resources(payload["resources"]),
      groups: groups(payload["groups"])
    }
  end

  @spec groups(list(map()) | nil) :: list(Concourse.Pipeline.Group.t())
  defp groups([group | groups]) do
    [
      %Concourse.Pipeline.Group{
        name: group["name"],
        jobs: Map.get(group, "jobs", []),
        resources: Map.get(group, "resources", [])
      }
      | groups(groups)
    ]
  end

  defp groups(_), do: []

  @spec resources(list(map()) | nil) :: list(Concourse.Pipeline.Resource.t())
  defp resources([resource | resources]) do
    [
      %Concourse.Pipeline.Resource{
        name: resource["name"],
        type: resource["type"],
        source: resource["source"],
        check_every: resource["check_every"],
        tags: Map.get(resource, "tags", []),
        webhook_token: resource["webhook_token"]
      }
      | resources(resources)
    ]
  end

  defp resources(_), do: []

  @spec jobs(list(map()) | nil) :: list(Concourse.Pipeline.Job.t())
  defp jobs([job | jobs]) do
    [
      %Concourse.Pipeline.Job{
        name: job["name"],
        plan: Concourse.Pipeline.Job.plan(job["plan"]),
        serial: Map.get(job, "serial", false),
        build_logs_to_retain: job["build_logs_to_retain"],
      }
      | jobs(jobs)
    ]
  end

  defp jobs(_), do: []
end
