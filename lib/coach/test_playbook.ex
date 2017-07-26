defmodule Coach.DummyModule do
  def my_func(a) do
    IO.inspect(a)
  end
end

defmodule Coach.TestPlaybook do
  use Coach.Playbook
  alias Coach.DummyModule
  alias Coach.TestPlaybook2
  alias Coach.Play.Postgres

  defplay :test_bash do
    shell "echo hi there"
    Postgres.create_user user: "dev", permissions: [:superuser]
  end

  defplay :test_delete do
    delete file: {:home, "delete_this"}
  end

  defplay :services do
    service action: :stop, service: "redis", services: ["rabbitmq", "postgresql"]
  end

  defplay :test_copy do
    change_shell shell: "/bin/bash", user: "cj"
    copy from: {:home, ".bashrc"}, to: {:tmp, ".bashrc"}, chown: "cjpoll"
  end

  defplay :do_thing do
    copy from: "mix.exs", to: "mix.exs.bak"
    copy from: "mix.exs.bak", to: "mix.exs.bak1"

    download from: URI.parse("http://google.com"), to: {:home, "goog"}, unless_downloaded: true
    extract from: {:tmp, "confluent.tar.gz"}, to: {:home, "confluent"}, strip_components: 1

    shell command: "echo", args: ["hello", "world"]
    shell "echo hello world | grep hello"

    git_clone repo: "git@github.com:cjpoll/coach", to: {:tmp, {:system, "COACH_CLONE_NAME"}}
    play :do_other_thing # Knows to use this same module
  end

  defplay :do_other_thing do
    # These two are NOT equivalent
    play TestPlaybook2, :do_thing # Handles aliases correctly!
    apply TestPlaybook2, :do_thing, [] # Handles aliases correctly!

    apply DummyModule, :my_func, ["Hello world!"] # Handles aliases correctly!
  end
end

defmodule Coach.TestPlaybook2 do
  use Coach.Playbook

  defplay :do_thing do
    install package: "ack", on: :mac
    install package: "ack-grep", on: :debian # Turns into a noop function on mac
    install packages: ["ack", "perl", "redis"], on: :mac
    install package: "ack", package: "perl", package: "redis", on: :mac # This works too

    mkdir {:home, "confluent"}
    touch {:home, "confluent/afile"}
  end
end
