defmodule PortfolioWeb.BlogLive.Index do
  use PortfolioWeb, :live_view

  alias Portfolio.Blogs
  alias Portfolio.Blog

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(:current_admin, session["admin_user"])
     |> stream(:blogs, Blogs.list_blogs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Blog")
    |> assign(:blog, Blogs.get_blog!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Blog")
    |> assign(:blog, %Blog{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Blogs")
    |> assign(:blog, nil)
  end

  @impl true
  def handle_info({PortfolioWeb.BlogLive.FormComponent, {:saved, blog}}, socket) do
    {:noreply, stream_insert(socket, :blogs, blog)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    blog = Blogs.get_blog!(id)
    {:ok, _} = Blogs.delete_blog(blog)

    {:noreply, stream_delete(socket, :blogs, blog)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Blogs
      <:subtitle>
        Logged in as: {@current_admin.username}
      </:subtitle>
      <:actions>
        <.link navigate={~p"/admin/blogs/new"} class="btn btn-primary">
          New Blog
        </.link>
        <.link href={~p"/admin/logout"} method="delete" class="btn btn-outline btn-error ml-2">
          Logout
        </.link>
      </:actions>
    </.header>

    <.live_component
      :if={@live_action in [:new, :edit]}
      module={PortfolioWeb.BlogLive.FormComponent}
      id={@blog.id || :new}
      title={@page_title}
      action={@live_action}
      blog={@blog}
      patch={~p"/admin/blogs"}
    />

    <.table
      :if={@live_action == :index}
      id="blogs"
      rows={@streams.blogs}
      row_click={fn {_id, blog} -> JS.navigate(~p"/admin/blogs/#{blog}/edit") end}
    >
      <:col :let={{_id, blog}} label="Title">{blog.title}</:col>
      <:col :let={{_id, blog}} label="Format">{blog.format}</:col>
      <:col :let={{_id, blog}} label="Published">{blog.published}</:col>
      <:col :let={{_id, blog}} label="Created">{blog.inserted_at}</:col>
      <:action :let={{_id, blog}}>
        <.link navigate={~p"/admin/blogs/#{blog}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, blog}}>
        <.link
          phx-click={JS.push("delete", value: %{id: blog.id}) |> hide("##{id}")}
          phx-value-id={blog.id}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>
    """
  end
end
