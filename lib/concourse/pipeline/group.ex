defmodule Concourse.Pipeline.Group do
  defstruct [
    :name,
    :jobs,
    :resources
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          jobs: list(String.t()),
          resources: list(String.t())
        }
end
