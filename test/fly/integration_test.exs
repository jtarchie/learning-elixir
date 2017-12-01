defmodule IntegrationTest do
    use ExUnit.Case, async: true
    import ExUnit.CaptureIO

    @spec fly(list(String.t)) :: String.t
    defp fly(args) do
        case System.get_env("FLY_CLI") do
            "go" ->
                {output, code} = System.cmd "fly", args
                assert code == 0
                output
            _ ->
                capture_io(fn ->
                    Concourse.Fly.main args
                end)
            end
    end
    
    test "a user can login to a target" do
        output = fly(["-t", "testing", "login", "-c", "http://localhost:8080", "-n", "main"])
        assert String.contains?(output, "target saved")
    end
end