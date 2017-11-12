require Concourse.Pipeline

defmodule PipelineTest do
  use ExUnit.Case
  doctest Concourse.Pipeline
  alias Concourse.Pipeline

  test "supports valid pipeline" do
    filename = Path.join([__DIR__, "fixtures", "pipeline.yml"])

    assert Concourse.Pipeline.parse(filename) == %Pipeline{
             resources: [
               %Pipeline.Resource{
                 name: "10s",
                 type: "time",
                 source: %{"interval" => "10s"}
               },
               %Pipeline.Resource{
                 name: "git",
                 type: "git",
                 source: %{"uri" => "https://github.com/concourse/concourse"}
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
                       image_resource: %Pipeline.ImageResource{
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
