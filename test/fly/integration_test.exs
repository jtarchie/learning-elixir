defmodule IntegrationTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  setup do
    home = System.get_env("HOME")

    on_exit(fn ->
      System.put_env("HOME", home)
    end)

    {:ok, path} = Briefly.create(directory: true)
    System.put_env("HOME", path)

    {:ok, home: path}
  end

  @spec fly(list(String.t())) :: String.t()
  defp fly(args) do
    case System.get_env("FLY_CLI") do
      "go" ->
        {output, code} = System.cmd("fly", args)
        assert code == 0
        output

      _ ->
        capture_io(fn ->
          Concourse.Fly.main(args)
        end)
    end
  end

  test "a user can login to a target" do
    output = fly(["-t", "testing", "login", "-c", "http://localhost:8080", "-n", "main"])
    assert String.contains?(output, "target saved")
  end
end
