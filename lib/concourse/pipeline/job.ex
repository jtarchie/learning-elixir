defmodule Concourse.Pipeline.Job do
  defstruct [:name, :plan]

  defmodule Aggregate do
    defstruct [:steps]
  end

  defmodule Do do
    defstruct [:steps]
  end

  defmodule Task do
    defstruct [:task, :config, :run]

    defmodule Config do
      defstruct [:image_resource, :platform, :run]
    end

    def config(%{
          "image_resource" => image_resource,
          "platform" => platform,
          "run" => run
        }) do
      %Config{
        platform: platform,
        image_resource: %Concourse.Pipeline.ImageResource{
          type: image_resource["type"],
          source: image_resource["source"]
        },
        run: %{
          path: run["path"],
          args: run["args"]
        }
      }
    end
  end

  defmodule Get do
    defstruct [:get, :trigger]
  end

  defmodule Put do
    defstruct [:put]
  end

  def plan(nil), do: []
  def plan([]), do: []

  def plan([step | steps]) do
    [
      step(step) | plan(steps)
    ]
  end

  defp step(%{"task" => task} = step) do
    %Task{
      task: task,
      config: Task.config(step["config"])
    }
  end

  defp step(%{"get" => get} = step) do
    %Get{
      get: get,
      trigger: step["trigger"]
    }
  end

  defp step(%{"put" => put}) do
    %Put{
      put: put
    }
  end

  defp step(%{"aggregate" => steps}) do
    %Aggregate{steps: plan(steps)}
  end

  defp step(%{"do" => steps}) do
    %Do{steps: plan(steps)}
  end
end
