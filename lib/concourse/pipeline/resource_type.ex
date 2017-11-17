defmodule Concourse.Pipeline.ResourceType do
  defstruct [
    :name,
    :type,
    :source,
    :privileged,
    :tags
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          type: String.t(),
          source: map(),
          privileged: boolean() | nil,
          tags: list(String.t())
        }
end
