defmodule Concourse.Pipeline.Resource do
  defstruct [:name, :type, :source]

  @type t :: %Concourse.Pipeline.Resource{
          name: String.t(),
          type: String.t(),
          source: map()
        }
end
