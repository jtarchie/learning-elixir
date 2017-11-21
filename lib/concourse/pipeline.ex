defmodule Concourse.Pipeline do
  defstruct jobs: [],
            resources: [],
            resource_types: [],
            groups: []

  @type t :: %__MODULE__{
          jobs: list(Concourse.Pipeline.Job.t()),
          resources: list(Concourse.Pipeline.Resource.t()),
          groups: list(Concourse.Pipeline.Group.t()),
          resource_types: list(Concourse.Pipeline.ResourceType.t())
        }

  @spec resource_types(list(map()) | nil) :: list(Concourse.Pipeline.ResourceType.t())
  def resource_types([resource_type | resource_types]) do
    [
      %Concourse.Pipeline.ResourceType{
        name: Map.fetch!(resource_type, "name"),
        type: Map.fetch!(resource_type, "type"),
        source: Map.get(resource_type, "source", %{}),
        privileged: Map.get(resource_type, "privileged", false),
        tags: Map.get(resource_type, "tags", [])
      }
      | resource_types(resource_types)
    ]
  end

  def resource_types([]), do: []
  def resource_types(nil), do: []

  @spec groups(list(map()) | nil) :: list(Concourse.Pipeline.Group.t())
  def groups([group | groups]) do
    [
      %Concourse.Pipeline.Group{
        name: group["name"],
        jobs: Map.get(group, "jobs", []),
        resources: Map.get(group, "resources", [])
      }
      | groups(groups)
    ]
  end

  def groups([]), do: []
  def groups(nil), do: []

  @spec resources(list(map()) | nil) :: list(Concourse.Pipeline.Resource.t())
  def resources([resource | resources]) do
    [
      %Concourse.Pipeline.Resource{
        name: Map.fetch!(resource, "name"),
        type: Map.fetch!(resource, "type"),
        source: resource["source"],
        check_every: resource["check_every"],
        tags: Map.get(resource, "tags", []),
        webhook_token: resource["webhook_token"]
      }
      | resources(resources)
    ]
  end

  def resources([]), do: []
  def resources(nil), do: []

  @spec jobs(list(map()) | nil) :: list(Concourse.Pipeline.Job.t())
  def jobs([job | jobs]) do
    [
      %Concourse.Pipeline.Job{
        name: Map.fetch!(job, "name"),
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

  def jobs([]), do: []
  def jobs(nil), do: []
end
