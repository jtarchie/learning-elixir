defmodule IntegrationTest do
    use ExUnit.Case, async: true

    @spec fly(list(String.t)) :: String.t
    defp fly(args) do
        {output, code} = System.cmd "fly", args
        assert code == 0
        output
    end
    
    test "a user can login to a target" do
        {username, password} = {System.get_env("USERNAME"), System.get_env("PASSWORD")}
        assert username != nil
        assert password != nil
        output = fly(["-t", "testing", "login", "-c", "https://ci.concourse.ci", "-n", "main", "-u", username, "-p", password])
        assert String.contains?(output, "target saved")
    end
end