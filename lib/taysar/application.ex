defmodule Taysar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    %{ host: db_host, path: "/" <> db_name, userinfo: db_userinfo } = URI.parse(System.get_env("DATABASE_URL"))
    [ db_username, db_password ] = String.split(db_userinfo, ":")

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Taysar.Worker.start_link(arg)
      # {Taysar.Worker, arg},
      Postgrex.child_spec(
        name: Postgrex,
        hostname: db_host,
        username: db_username,
        password: db_password,
        database: db_name
      ),
      Plug.Adapters.Cowboy.child_spec(
        scheme: :http,
        plug: Taysar.Router,
        options: [port: if( System.get_env("PORT"), do: String.to_integer( System.get_env("PORT") ), else: 8085 )]
      ),
      Taysar.Sitemap,
      Taysar.Stats,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Taysar.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
