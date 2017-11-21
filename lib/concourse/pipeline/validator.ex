defmodule Concourse.Pipeline.Validator do
  @spec valid?(Concourse.Pipeline.t()) :: :ok | {:error, list(String.t())}
  def valid?(pipeline) do
    errors =
      validate_groups_jobs(pipeline) ++
        validate_groups_resources(pipeline) ++ validate_jobs_in_groups(pipeline)

    case errors do
      [] -> :ok
      _ -> {:error, errors}
    end
  end

  defp validate_jobs_in_groups(pipeline) do
    jobs_from_groups = pipeline.groups |> Enum.flat_map(& &1.jobs)

    pipeline.jobs
    |> Enum.map(& &1.name)
    |> Enum.filter(fn job -> !Enum.member?(jobs_from_groups, job) end)
    |> Enum.map(fn job -> "job '#{job}' belongs to no group" end)
  end

  defp validate_groups_jobs(pipeline) do
    validate_groups(pipeline, :jobs, "job")
  end

  defp validate_groups_resources(pipeline) do
    validate_groups(pipeline, :resources, "resource")
  end

  defp validate_groups(pipeline, type, name) do
    from_pipeline = Enum.map(Map.get(pipeline, type), & &1.name)

    pipeline.groups
    |> Enum.flat_map(fn group ->
         Map.get(group, type)
         |> Enum.filter(fn from_group -> !Enum.member?(from_pipeline, from_group) end)
         |> Enum.map(fn from_group ->
              "group '#{group.name}' has unknown #{name} '#{from_group}'"
            end)
       end)
  end
end
