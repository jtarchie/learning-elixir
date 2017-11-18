require Concourse.Pipeline

defmodule PipelineTest do
  use ExUnit.Case
  doctest Concourse.Pipeline
  alias Concourse.Pipeline

  test "supports valid pipeline" do
    filename = Path.join([__DIR__, "fixtures", "pipeline.yml"])

    assert Concourse.Pipeline.parse(filename) == %Pipeline{
             groups: [
               %Pipeline.Group{
                 name: "all",
                 jobs: ["hello-world"],
                 resources: ["10s", "git"]
               },
               %Pipeline.Group{
                name: "nothing",
                jobs: [],
                resources: []
              },
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
                 name: "hello-world",
                 plan: [
                   %Pipeline.Job.Aggregate{
                     steps: [
                       %Pipeline.Job.Get{
                         get: "10s",
                         trigger: true
                       },
                       %Pipeline.Job.Get{
                         get: "git"
                       }
                     ]
                   },
                   %Pipeline.Job.Task{
                     task: "do work",
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
                     steps: [
                       %Pipeline.Job.Put{put: "10s"}
                     ]
                   }
                 ]
               }
             ]
           }
  end
end
