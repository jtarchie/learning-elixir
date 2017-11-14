defmodule Concourse.Pipeline.ImageResource do
  defstruct [:type, :source, :platform]

  @type t :: %Concourse.Pipeline.ImageResource{
          type: String.t(),
          source: map(),
          platform: String.t()
        }
end
