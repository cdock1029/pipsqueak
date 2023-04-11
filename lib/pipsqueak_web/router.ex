defmodule PipsqueakWeb.Router do
  use PipsqueakWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PipsqueakWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PipsqueakWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/nodes", NodeLive.Index, :index
    live "/nodes/new", NodeLive.Index, :new
    live "/nodes/:id/edit", NodeLive.Index, :edit

    live "/nodes/:id", NodeLive.Show, :show
    live "/nodes/:id/show/edit", NodeLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", PipsqueakWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pipsqueak, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PipsqueakWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
