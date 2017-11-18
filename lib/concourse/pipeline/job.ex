defmodule Concourse.Pipeline.Job do
  defstruct [
    :name,
    :plan,
    :serial,
    :build_logs_to_retain,
    :serial_groups,
    :max_in_flight,
    :public,
    :disable_manual_trigger,
    :interruptible,
    :on_success,
    :on_failure,
    :ensure
  ]

  @type step ::
          Concourse.Pipeline.Job.Aggregate.t()
          | Concourse.Pipeline.Job.Do.t()
          | Concourse.Pipeline.Job.Put.t()
          | Concourse.Pipeline.Job.Get.t()
          | Concourse.Pipeline.Job.Task.t()

  @type steps :: list(step)

  @type t :: %Concourse.Pipeline.Job{
          name: String.t(),
          plan: steps(),
          serial: boolean | nil,
          build_logs_to_retain: pos_integer() | nil,
          serial_groups: [String.t()] | nil,
          max_in_flight: pos_integer() | nil,
          public: boolean | nil,
          disable_manual_trigger: boolean | nil,
          interruptible: boolean | nil,
          on_failure: Concourse.Pipeline.Job.steps(),
          on_success: Concourse.Pipeline.Job.steps(),
          ensure: Concourse.Pipeline.Job.steps()
        }

  defmodule Aggregate do
    defstruct [
      :steps,
      :on_failure,
      :on_success,
      :ensure,
      :try,
      :timeout,
      :attempts,
      :tags
    ]

    @type t :: %Concourse.Pipeline.Job.Aggregate{
            steps: Concourse.Pipeline.Job.steps(),
            on_failure: Concourse.Pipeline.Job.steps(),
            on_success: Concourse.Pipeline.Job.steps(),
            ensure: Concourse.Pipeline.Job.steps(),
            try: Concourse.Pipeline.Job.steps(),
            timeout: String.t() | nil,
            attempts: pos_integer() | nil,
            tags: list(String.t())
          }
  end

  defmodule Do do
    defstruct [
      :steps,
      :on_failure,
      :on_success,
      :ensure,
      :try,
      :timeout,
      :attempts,
      :tags
    ]

    @type t :: %Concourse.Pipeline.Job.Do{
            steps: Concourse.Pipeline.Job.steps(),
            on_failure: Concourse.Pipeline.Job.steps(),
            on_success: Concourse.Pipeline.Job.steps(),
            ensure: Concourse.Pipeline.Job.steps(),
            try: Concourse.Pipeline.Job.steps(),
            timeout: String.t() | nil,
            attempts: pos_integer() | nil,
            tags: list(String.t())
          }
  end

  defmodule Task do
    defstruct [
      :task,
      :config,
      :privileged,
      :params,
      :image,
      :input_mapping,
      :output_mapping,
      :on_failure,
      :on_success,
      :ensure,
      :try,
      :timeout,
      :attempts,
      :tags,
      :file
    ]

    @type t :: %Concourse.Pipeline.Job.Task{
            task: String.t(),
            config: Concourse.Pipeline.Job.Task.Config.t(),
            privileged: boolean() | nil,
            params: %{required(String.t()) => String.t()} | nil,
            input_mapping: %{required(String.t()) => String.t()} | nil,
            output_mapping: %{required(String.t()) => String.t()} | nil,
            on_failure: Concourse.Pipeline.Job.steps(),
            on_success: Concourse.Pipeline.Job.steps(),
            ensure: Concourse.Pipeline.Job.steps(),
            try: Concourse.Pipeline.Job.steps(),
            timeout: String.t() | nil,
            attempts: pos_integer() | nil,
            tags: list(String.t()),
            file: String.t() | nil
          }

    defmodule Config do
      defstruct [
        :image_resource,
        :platform,
        :run,
        :rootfs_uri,
        :inputs,
        :outputs,
        :caches,
        :params
      ]

      defmodule ImageResource do
        defstruct [
          :type,
          :source,
          :params,
          :version
        ]

        @type t :: %Concourse.Pipeline.Job.Task.Config.ImageResource{
                type: String.t(),
                source: map(),
                params: %{required(String.t()) => String.t()} | nil,
                version: %{required(String.t()) => String.t()} | nil
              }
      end

      defmodule Mapping do
        defstruct [
          :name,
          :path
        ]

        @type t :: %__MODULE__{
                name: String.t(),
                path: String.t() | nil
              }
      end

      @type t :: %Concourse.Pipeline.Job.Task.Config{
              image_resource: Concourse.Pipeline.Job.Task.Config.ImageResource.t(),
              platform: String.t(),
              run: %{
                path: String.t(),
                args: list(String.t())
              },
              rootfs_uri: String.t() | nil,
              inputs: [Concourse.Pipeline.Job.Task.Config.Mapping] | nil,
              outputs: [Concourse.Pipeline.Job.Task.Config.Mapping] | nil,
              caches: [String.t()] | nil,
              params: %{required(String.t()) => String.t()} | nil
            }
    end

    def config(%{
          "image_resource" => image_resource,
          "platform" => platform,
          "run" => run
        }) do
      %Config{
        platform: platform,
        image_resource: %Concourse.Pipeline.Job.Task.Config.ImageResource{
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
    defstruct [
      :get,
      :resource,
      :version,
      :passed,
      :params,
      :trigger,
      :on_failure,
      :on_success,
      :ensure,
      :try,
      :timeout,
      :attempts,
      :tags
    ]

    @type t :: %__MODULE__{
            get: String.t(),
            resource: String.t() | nil,
            version: %{required(String.t()) => String.t()} | nil,
            passed: [String.t()] | nil,
            params: %{required(String.t()) => String.t()} | nil,
            trigger: boolean(),
            on_failure: Concourse.Pipeline.Job.steps(),
            on_success: Concourse.Pipeline.Job.steps(),
            ensure: Concourse.Pipeline.Job.steps(),
            try: Concourse.Pipeline.Job.steps(),
            timeout: String.t() | nil,
            attempts: pos_integer() | nil,
            tags: list(String.t())
          }
  end

  defmodule Put do
    defstruct [
      :put,
      :resource,
      :params,
      :get_params,
      :on_failure,
      :on_success,
      :ensure,
      :try,
      :timeout,
      :attempts,
      :tags
    ]

    @type t :: %__MODULE__{
            put: String.t(),
            resource: String.t() | nil,
            params: %{required(String.t()) => String.t()} | nil,
            get_params: %{required(String.t()) => String.t()} | nil,
            on_failure: Concourse.Pipeline.Job.steps(),
            on_success: Concourse.Pipeline.Job.steps(),
            ensure: Concourse.Pipeline.Job.steps(),
            try: Concourse.Pipeline.Job.steps(),
            timeout: String.t() | nil,
            attempts: pos_integer() | nil,
            tags: list(String.t())
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
