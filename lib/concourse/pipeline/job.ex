defmodule Concourse.Pipeline.Job do
  defstruct [:name, :plan]

  @type step ::
          Concourse.Pipeline.Job.Aggregate.t()
          | Concourse.Pipeline.Job.Do.t()
          | Concourse.Pipeline.Job.Put.t()
          | Concourse.Pipeline.Job.Get.t()
          | Concourse.Pipeline.Job.Task.t()

  @type steps :: list(step)

  @type t :: %Concourse.Pipeline.Job{
          name: String.t(),
          plan: steps()
        }

  defmodule Aggregate do
    defstruct [:steps]

    @type t :: %Concourse.Pipeline.Job.Aggregate{
            steps: Concourse.Pipeline.Job.steps()
          }
  end

  defmodule Do do
    defstruct [:steps]

    @type t :: %Concourse.Pipeline.Job.Do{
            steps: Concourse.Pipeline.Job.steps()
          }
  end

  defmodule Task do
    defstruct [:task, :config, :run]

    defmodule Config do
      defstruct [:image_resource, :platform, :run]

      @type t :: %Concourse.Pipeline.Job.Task.Config{
              image_resource: Concourse.Pipeline.ImageResource.t(),
              platform: String.t(),
              run: %{
                path: String.t(),
                args: list(String.t())
              }
            }
    end

    @type t :: %Concourse.Pipeline.Job.Task{
            task: String.t(),
            config: Concourse.Pipeline.Job.Task.Config.t()
          }

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

    @type t :: %Concourse.Pipeline.Job.Get{
            get: String.t(),
            trigger: boolean()
          }
  end

  defmodule Put do
    defstruct [:put]

    @type t :: %Concourse.Pipeline.Job.Put{
            put: String.t()
          }
  end

  @spec plan(list(map())) :: steps()
  def plan([step | steps]) do
    [
      step(step) | plan(steps)
    ]
  end

  def plan(_), do: []

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
