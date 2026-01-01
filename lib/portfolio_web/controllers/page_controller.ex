defmodule PortfolioWeb.PageController do
  use PortfolioWeb, :controller

  alias Portfolio.Blogs

  def home(conn, _params) do
    render(conn, :home)
  end

  def blogs(conn, _params) do
    blogs = Blogs.list_published_blogs()
    render(conn, :blogs, blogs: blogs)
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
