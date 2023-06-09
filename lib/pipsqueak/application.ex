defmodule Pipsqueak.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PipsqueakWeb.Telemetry,
      # Start the Ecto repository
      Pipsqueak.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Pipsqueak.PubSub},
      # Start Finch
      {Finch, name: Pipsqueak.Finch},
      # Start the Endpoint (http/https)
      PipsqueakWeb.Endpoint
      # Start a worker by calling: Pipsqueak.Worker.start_link(arg)
      # {Pipsqueak.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pipsqueak.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PipsqueakWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
