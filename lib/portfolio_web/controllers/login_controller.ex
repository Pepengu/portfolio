defmodule PortfolioWeb.LoginController do
  use PortfolioWeb, :controller

  alias Portfolio.Auth

  def new(conn, _params) do
    render(conn, :new, changeset: %{})
  end

  def create(conn, %{"admin" => %{"username" => username, "password" => password}}) do
    case Auth.authenticate(username, password) do
      {:ok, user} ->
        conn
        |> put_session(:admin_user, user)
        |> put_flash(:info, "Successfully logged in.")
        |> redirect(to: "/admin/blogs")

      {:error, :admin_not_configured} ->
        conn
        |> put_flash(
          :error,
          "Admin authentication not configured. Please set ADMIN_PASSWORD environment variable."
        )
        |> render(:new, changeset: %{username: username})

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Invalid username or password.")
        |> render(:new, changeset: %{username: username})
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Successfully logged out.")
    |> redirect(to: "/")
  end
end
