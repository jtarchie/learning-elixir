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
end
