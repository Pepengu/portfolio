defmodule Portfolio.Auth do
  @moduledoc """
  Simple authentication context for admin access.
  Uses environment variables for credentials.
  """

  @doc """
  Authenticates admin credentials using environment variables.
  """
  def authenticate(username, password) do
    admin_username = System.get_env("ADMIN_USERNAME") || "admin"
    admin_password = System.get_env("ADMIN_PASSWORD")

    cond do
      admin_password == nil ->
        {:error, :admin_not_configured}

      username == admin_username && password == admin_password ->
        {:ok, %{username: username, role: :admin}}

      true ->
        {:error, :invalid_credentials}
    end
  end

  @doc """
  Returns the admin username.
  """
  def admin_username do
    System.get_env("ADMIN_USERNAME") || "admin"
  end

  @doc """
  Checks if admin authentication is configured.
  """
  def admin_configured? do
    System.get_env("ADMIN_PASSWORD") != nil
  end
end
