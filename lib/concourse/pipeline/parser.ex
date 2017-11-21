defmodule Concourse.Pipeline.Parser do
  require YamlElixir

  @spec parse(String.t()) :: Concourse.Pipeline.t()
  def parse(filename) do
    filename = String.to_charlist(filename)
    payload = YamlElixir.read_from_file(filename)

    %Concourse.Pipeline{
      jobs: Concourse.Pipeline.jobs(payload["jobs"]),
      resources: Concourse.Pipeline.resources(payload["resources"]),
      groups: Concourse.Pipeline.groups(payload["groups"]),
      resource_types: Concourse.Pipeline.resource_types(payload["resource_types"])
    }
  end
end
