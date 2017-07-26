defmodule Coach.Play.Postgres.CreateUser do
  @type username :: String.t
  defstruct [:host, :port, :creator, :user, permissions: []]

  @type permission :: {:connection_limit, pos_integer}
  | :create_db
  | :create_role
  | :echo
  | :encrypted
  | :inherit
  | :interactive
  | :login
  | :no_create_db
  | :no_create_role
  | :no_inherit
  | :no_login
  | :no_replication
  | :password_prompt
  | :replication
  | :role
  | :superuser
  | :unencrypted

  def new() do
    %__MODULE__{}
  end

  def user(%__MODULE__{} = commandable, username) do
    %__MODULE__{commandable | user: username}
  end

  def connection_limit(%__MODULE__{} = commandable, limit) do
    add_permission(commandable, {:connection_limit, limit})
  end

  def create_db(%__MODULE__{} = commandable) do
    add_permission(commandable, :create_db)
  end

  def create_role(%__MODULE__{} = commandable) do
    add_permission(commandable, :create_role)
  end

  def echo(%__MODULE__{} = commandable) do
    add_permission(commandable, :echo)
  end

  def encrypted(%__MODULE__{} = commandable) do
    add_permission(commandable, :encrypted)
  end

  def inherit(%__MODULE__{} = commandable) do
    add_permission(commandable, :inherit)
  end

  def interactive(%__MODULE__{} = commandable) do
    add_permission(commandable, :interactive)
  end

  def login(%__MODULE__{} = commandable) do
    add_permission(commandable, :login)
  end

  def no_createdb(%__MODULE__{} = commandable) do
    add_permission(commandable, :no_create_db)
  end

  def no_create_role(%__MODULE__{} = commandable) do
    add_permission(commandable, :no_create_role)
  end

  def no_inherit(%__MODULE__{} = commandable) do
    add_permission(commandable, :no_inherit)
  end

  def no_login(%__MODULE__{} = commandable) do
    add_permission(commandable, :no_login)
  end

  def no_replication(%__MODULE__{} = commandable) do
    add_permission(commandable, :no_replication)
  end

  def password_prompt(%__MODULE__{} = commandable) do
    add_permission(commandable, :password_prompt)
  end

  def replication(%__MODULE__{} = commandable) do
    add_permission(commandable, :replication)
  end

  def role(%__MODULE__{} = commandable, role) do
    add_permission(commandable, {:role, role})
  end

  def superuser(%__MODULE__{} = commandable) do
    add_permission(commandable, :superuser)
  end

  def unencrypted(%__MODULE__{} = commandable) do
    add_permission(commandable, :unencrypted)
  end

  def add_permission(%__MODULE__{} = commandable, perm) do
    %__MODULE__{commandable | permissions: [perm | commandable.permissions]}
  end

  def host(%__MODULE__{} = commandable, host) do
    %__MODULE__{commandable | host: host}
  end

  def port(%__MODULE__{} = commandable, port) do
    %__MODULE__{commandable | port: port}
  end

  def creator(%__MODULE__{} = commandable, creator) do
    %__MODULE__{commandable | creator: creator}
  end
end

defimpl Commandable, for: Coach.Play.Postgres.CreateUser do
  @mod Coach.Play.Postgres.CreateUser

  alias Coach.Cmd.Shell

  def to_cmd(%@mod{user: user, permissions: permissions, host: host, port: port, creator: creator}) do
    permissions = :lists.reverse(permissions)

    connection_limit = Proplist.get_value(permissions, :connection_limit)
    create_db = Proplist.get_value(permissions, :create_db)
    create_role = Proplist.get_value(permissions, :create_role)
    echo = Proplist.get_value(permissions, :echo)
    encrypted = Proplist.get_value(permissions, :encrypted)
    inherit = Proplist.get_value(permissions, :inherit)
    interactive = Proplist.get_value(permissions, :interactive)
    login = Proplist.get_value(permissions, :login)
    no_create_db = Proplist.get_value(permissions, :no_create_db)
    no_create_role = Proplist.get_value(permissions, :no_create_role)
    no_inherit = Proplist.get_value(permissions, :no_inherit)
    no_login = Proplist.get_value(permissions, :no_login)
    no_replication = Proplist.get_value(permissions, :no_replication)
    password_prompt = Proplist.get_value(permissions, :password_prompt)
    replication = Proplist.get_value(permissions, :replication)
    role = Proplist.get_value(permissions, :role)
    superuser = Proplist.get_value(permissions, :superuser)
    unencrypted = Proplist.get_value(permissions, :unencrypted)

    Shell.new()
    |> Shell.with_command("createuser")
    |> Shell.with_flag("--connection-limit", connection_limit, if: connection_limit)
    |> Shell.with_flag("--createdb", if: create_db)
    |> Shell.with_flag("--createrole", if: create_role)
    |> Shell.with_flag("--echo", if: echo)
    |> Shell.with_flag("--encrypted", if: encrypted)
    |> Shell.with_flag("--inherit", if: inherit)
    |> Shell.with_flag("--interactive", if: interactive)
    |> Shell.with_flag("--login", if: login)
    |> Shell.with_flag("--no-createdb", if: no_create_db)
    |> Shell.with_flag("--no-createrole", if: no_create_role)
    |> Shell.with_flag("--no-inherit", if: no_inherit)
    |> Shell.with_flag("--no-login", if: no_login)
    |> Shell.with_flag("--no-replication", if: no_replication)
    |> Shell.with_flag("--pwprompt", if: password_prompt)
    |> Shell.with_flag("--replication", if: replication)
    |> Shell.with_flag("--role", role, if: role)
    |> Shell.with_flag("--superuser", if: superuser)
    |> Shell.with_flag("--unencrypted", if: unencrypted)
    |> Shell.with_flag("--host", host, if: host)
    |> Shell.with_flag("--port", port, if: port)
    |> Shell.with_flag("--username", creator, if: creator)
    |> Shell.with_value(user)
  end
end
