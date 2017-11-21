require Concourse.Pipeline

defmodule ValidTest do
  use ExUnit.Case
  doctest Concourse.Pipeline

  test "supports valid pipeline" do
    filename = Path.join([__DIR__, "..", "fixtures", "pipeline.yml"])
    pipeline = Concourse.Pipeline.Parser.parse(filename)
    assert Concourse.Pipeline.Validator.valid?(pipeline) == :ok
  end

  test "validates all jobs appear in groups" do
    pipeline = %Concourse.Pipeline{
      groups: [
        %Concourse.Pipeline.Group{
          name: "test-group",
          jobs: [],
          resources: []
        }
      ],
      jobs: [
        %Concourse.Pipeline.Job{
          name: "test-job"
        }
      ]
    }

    assert Concourse.Pipeline.Validator.valid?(pipeline) ==
             {:error, [
               "job 'test-job' belongs to no group"
             ]}
  end

  test "validates all groups have valid jobs and resources" do
    pipeline = %Concourse.Pipeline{
      groups: [
        %Concourse.Pipeline.Group{
          name: "test-group",
          jobs: ["test-job"],
          resources: ["test-resource"]
        }
      ]
    }

    assert Concourse.Pipeline.Validator.valid?(pipeline) ==
             {:error, [
               "group 'test-group' has unknown job 'test-job'",
               "group 'test-group' has unknown resource 'test-resource'"
             ]}
  end
end
