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
          serial: boolean,
          build_logs_to_retain: pos_integer(),
          serial_groups: [String.t()],
          max_in_flight: pos_integer() | nil,
          public: boolean,
          disable_manual_trigger: boolean,
          interruptible: boolean,
          on_failure: Concourse.Pipeline.Job.steps(),
          on_success: Concourse.Pipeline.Job.steps(),
          ensure: Concourse.Pipeline.Job.steps()
        }

  defmodule Aggregate do
    defstruct [
      :aggregate,
      :on_failure,
      :on_success,
      :ensure,
      :try,
      :timeout,
      :attempts,
      :tags
    ]

    @type t :: %Concourse.Pipeline.Job.Aggregate{
            aggregate: Concourse.Pipeline.Job.steps(),
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
      :do,
      :on_failure,
      :on_success,
      :ensure,
      :try,
      :timeout,
      :attempts,
      :tags
    ]

    @type t :: %Concourse.Pipeline.Job.Do{
            do: Concourse.Pipeline.Job.steps(),
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
            privileged: boolean(),
            params: %{required(String.t()) => String.t()},
            input_mapping: %{required(String.t()) => String.t()},
            output_mapping: %{required(String.t()) => String.t()},
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
                params: %{required(String.t()) => String.t()},
                version: %{required(String.t()) => String.t()}
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
              inputs: [Concourse.Pipeline.Job.Task.Config.Mapping],
              outputs: [Concourse.Pipeline.Job.Task.Config.Mapping],
              caches: [String.t()],
              params: %{required(String.t()) => String.t()}
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
            params: %{required(String.t()) => String.t()},
            get_params: %{required(String.t()) => String.t()},
            on_failure: Concourse.Pipeline.Job.steps(),
            on_success: Concourse.Pipeline.Job.steps(),
            ensure: Concourse.Pipeline.Job.steps(),
            try: Concourse.Pipeline.Job.steps(),
            timeout: String.t() | nil,
            attempts: pos_integer(),
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
      config: Task.config(step["config"]),
      privileged: Map.get(step, "privileged", false),
      params: Map.get(step, "params", %{}),
      image: step["image"],
      input_mapping: Map.get(step, "input_mapping", %{}),
      output_mapping: Map.get(step, "output_mapping", %{}),
      on_failure: step["on_failure"],
      on_success: step["on_success"],
      ensure: step["ensure"],
      try: step["try"],
      timeout: step["timeout"],
      attempts: step["attempts"],
      tags: Map.get(step, "tags", [])
    }
  end

  defp step(%{"get" => get} = step) do
    %Get{
      get: get,
      resource: step["resource"],
      version: step["version"],
      passed: Map.get(step, "passed", []),
      params: Map.get(step, "params", %{}),
      trigger: step["trigger"],
      on_failure: step["on_failure"],
      on_success: step["on_success"],
      ensure: step["ensure"],
      try: step["try"],
      timeout: step["timeout"],
      attempts: step["attempts"],
      tags: Map.get(step, "tags", [])
    }
  end

  defp step(%{"put" => put} = step) do
    %Put{
      put: put,
      resource: step["resource"],
      params: Map.get(step, "params", %{}),
      get_params: Map.get(step, "get_params", %{}),
      on_failure: step["on_failure"],
      on_success: step["on_success"],
      ensure: step["ensure"],
      try: step["try"],
      timeout: step["timeout"],
      attempts: step["attempts"],
      tags: Map.get(step, "tags", [])
    }
  end

  defp step(%{"aggregate" => steps} = step) do
    %Aggregate{
      aggregate: plan(steps),
      on_failure: step["on_failure"],
      on_success: step["on_success"],
      ensure: step["ensure"],
      try: step["try"],
      timeout: step["timeout"],
      attempts: step["attempts"],
      tags: Map.get(step, "tags", [])
    }
  end

  defp step(%{"do" => steps} = step) do
    %Do{
      do: plan(steps),
      on_failure: step["on_failure"],
      on_success: step["on_success"],
      ensure: step["ensure"],
      try: step["try"],
      timeout: step["timeout"],
      attempts: step["attempts"],
      tags: Map.get(step, "tags", [])
    }
  end
end
