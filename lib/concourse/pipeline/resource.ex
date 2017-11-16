defmodule Concourse.Pipeline.Resource do
  defstruct [:name, :type, :source]

  @type t :: %Concourse.Pipeline.Resource{
          name: String.t() | nil,
          type: String.t() | nil,
          source: map() | nil
        }
end
