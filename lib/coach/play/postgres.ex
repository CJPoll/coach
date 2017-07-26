defmodule Coach.Play.Postgres do
  alias Coach.Play.Postgres.CreateUser

  def create_user(opts) do
    new_user = Proplist.get_value(opts, :user)
    host = Proplist.get_value(opts, :host)
    port = Proplist.get_value(opts, :port)
    creator = Proplist.get_value(opts, :creator)
    permissions = Proplist.get_value(opts, :permissions)

    cmd =
      CreateUser.new()
      |> CreateUser.user(new_user)
      |> CreateUser.host(host)
      |> CreateUser.port(port)
      |> CreateUser.creator(creator)

    Enum.reduce(permissions, cmd, fn(permission, cmd) ->
      CreateUser.add_permission(cmd, permission)
    end)
  end
end
