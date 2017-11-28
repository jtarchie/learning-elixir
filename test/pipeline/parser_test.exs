require Concourse.Pipeline

defmodule ParserTest do
  use ExUnit.Case, async: true
  doctest Concourse.Pipeline
  alias Concourse.Pipeline

  test "parses a valid pipeline" do
    filename = Path.join([__DIR__, "..", "fixtures", "pipeline.yml"])

    assert Concourse.Pipeline.Parser.parse(filename) == %Pipeline{
             resource_types: [
               %Pipeline.ResourceType{
                 name: "pr",
                 type: "docker-image",
                 privileged: false,
                 tags: [],
                 source: %{
                   "repository" => "jtarchie/pr"
                 }
               }
             ],
             groups: [
               %Pipeline.Group{
                 name: "all",
                 jobs: ["previous-job", "hello-world"],
                 resources: ["10s", "git"]
               },
               %Pipeline.Group{
                 name: "nothing",
                 jobs: [],
                 resources: []
               }
             ],
             resources: [
               %Pipeline.Resource{
                 name: "10s",
                 type: "time",
                 source: %{"interval" => "10s"},
                 check_every: nil,
                 tags: [],
                 webhook_token: nil
               },
               %Pipeline.Resource{
                 name: "git",
                 type: "git",
                 source: %{"uri" => "https://github.com/concourse/concourse"},
                 check_every: "10m",
                 tags: ["linux"],
                 webhook_token: "abcdef"
               }
             ],
             jobs: [
               %Pipeline.Job{
                 name: "previous-job",
                 plan: [
                   %Pipeline.Job.Get{
                     get: "git",
                     params: %{},
                     passed: [],
                     tags: []
                   }
                 ],
                 disable_manual_trigger: true,
                 interruptible: true,
                 public: true,
                 serial: true,
                 serial_groups: ["a"]
               },
               %Pipeline.Job{
                 name: "hello-world",
                 plan: [
                   %Pipeline.Job.Aggregate{
                     aggregate: [
                       %Pipeline.Job.Get{
                         get: "10s",
                         trigger: true,
                         params: %{},
                         passed: [],
                         tags: []
                       },
                       %Pipeline.Job.Get{
                         get: "git",
                         params: %{"depth" => 1},
                         passed: ["previous-job"],
                         tags: ["windows"]
                       }
                     ],
                     tags: []
                   },
                   %Pipeline.Job.Task{
                     task: "do work",
                     input_mapping: %{},
                     output_mapping: %{},
                     params: %{},
                     privileged: false,
                     tags: [],
                     config: %Pipeline.Job.Task.Config{
                       image_resource: %Pipeline.Job.Task.Config.ImageResource{
                         type: "docker-image",
                         source: %{
                           "repository" => "ubuntu"
                         }
                       },
                       platform: "linux",
                       run: %{
                         path: "echo",
                         args: ["Hello, world!"]
                       }
                     }
                   },
                   %Pipeline.Job.Do{
                     do: [
                       %Pipeline.Job.Put{
                         put: "10s",
                         get_params: %{},
                         params: %{},
                         tags: []
                       }
                     ],
                     tags: []
                   }
                 ],
                 disable_manual_trigger: false,
                 interruptible: false,
                 public: false,
                 serial: false,
                 serial_groups: []
               }
             ]
           }
  end
end
