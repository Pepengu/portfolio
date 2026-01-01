defmodule PortfolioWeb.Plugs.Auth do
  @moduledoc """
  Authentication plug for admin routes.
  """

  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :admin_user) do
      nil ->
        conn
        |> put_flash(:error, "You must be logged in to access this page.")
        |> redirect(to: "/admin/login")
        |> halt()

      user ->
        assign(conn, :current_admin, user)
    end
  end
end
