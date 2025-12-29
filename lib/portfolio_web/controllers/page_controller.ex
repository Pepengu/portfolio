defmodule PortfolioWeb.PageController do
  use PortfolioWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def blogs(conn, _params) do
    render(conn, :blogs)
  end

  def projects(conn, _params) do
    render(conn, :projects)
  end

  def about(conn, _params) do
    render(conn, :about)
  end

  def contact(conn, _params) do
    render(conn, :contact)
  end
end
