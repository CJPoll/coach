defmodule Coach.TestPlaybook do
  use Coach.Playbook

  defplay :do_thing do
    copy from: "mix.exs", to: "mix.exs.bak"
    copy from: "mix.exs.bak", to: "mix.exs.bak1"

    shell command: "echo", args: ["hello", "world"]

    git_clone repo: "git@github.com:cjpoll/coach", to: {:tmp, {:system, "COACH_CLONE_NAME"}}
    play :do_other_thing
  end

  defplay :do_other_thing do
    copy from: "mix.exs", to: {:tmp, "mix.exs.bak"}
    download from: URI.parse("http://google.com"), to: {:home, "goog"}, unless_downloaded: true

    play :"Elixir.Coach.TestPlaybook2", :do_thing
  end
end

defmodule Coach.TestPlaybook2 do
  use Coach.Playbook

  defplay :do_thing do
    mkdir {:priv, ""}
    touch {:priv, "hello"}
  end
end
