defmodule PortfolioWeb.BlogController do
  use PortfolioWeb, :controller

  alias Portfolio.Blogs

  def show(conn, %{"slug" => slug}) do
    # Allow admins to view unpublished posts
    blog =
      if admin_logged_in?(conn) do
        Blogs.get_blog_by_slug_admin!(slug)
      else
        Blogs.get_blog_by_slug!(slug)
      end

    render(conn, :show, blog: blog)
  end

  defp admin_logged_in?(conn) do
    not is_nil(get_session(conn, :admin_user))
  end
end
