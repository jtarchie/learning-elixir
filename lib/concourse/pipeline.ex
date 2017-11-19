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
      groups: groups(payload["groups"]),
      resource_types: resource_types(payload["resource_types"])
    }
  end

  @spec resource_types(list(map()) | nil) :: list(Concourse.Pipeline.ResourceType.t())
  defp resource_types([type | types]) do
    [
      %Concourse.Pipeline.ResourceType{
        name: type["name"],
        type: type["type"],
        source: Map.get(type, "source", %{}),
        privileged: Map.get(type, "privileged", false),
        tags: Map.get(type, "tags", [])
      }
      | resource_types(types)
    ]
  end

  defp resource_types(_), do: []

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
        serial_groups: job["serial_groups"] || [],
        max_in_flight: job["max_in_flight"],
        public: Map.get(job, "public", false),
        disable_manual_trigger: Map.get(job, "disable_manual_trigger", false),
        interruptible: Map.get(job, "interruptible", false),
        on_success: job["on_success"],
        on_failure: job["on_failure"],
        ensure: job["ensure"]
      }
      | jobs(jobs)
    ]
  end

  defp jobs(_), do: []
end
