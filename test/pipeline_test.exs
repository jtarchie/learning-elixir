defmodule PipelineTest do
  use ExUnit.Case
  doctest Concourse.Pipeline

  test "required fields for resources" do
    resource = %{}

    assert_raise KeyError, ~r/key "name"/, fn ->
      Concourse.Pipeline.resources([resource])
    end

    resource = %{"name" => "test"}

    assert_raise KeyError, ~r/key "type"/, fn ->
      Concourse.Pipeline.resources([resource])
    end
  end

  test "required fields for resource types" do
    resource_type = %{}

    assert_raise KeyError, ~r/key "name"/, fn ->
      Concourse.Pipeline.resource_types([resource_type])
    end

    resource_type = %{"name" => "test"}

    assert_raise KeyError, ~r/key "type"/, fn ->
      Concourse.Pipeline.resource_types([resource_type])
    end
  end

  test "required fields for jobs" do
    job = %{}

    assert_raise KeyError, ~r/key "name"/, fn ->
      Concourse.Pipeline.jobs([job])
    end
  end
end
