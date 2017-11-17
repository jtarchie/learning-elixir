defmodule Concourse.Pipeline.Resource do
  defstruct [
    :name,
    :type,
    :source,
    :check_every,
    :tags,
    :webhook_token
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          type: String.t(),
          source: map(),
          check_every: String.t() | nil,
          tags: list(String.t()),
          webhook_token: String.t() | nil
        }
end
