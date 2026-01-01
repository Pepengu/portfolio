defmodule PortfolioWeb.BlogLive.FormComponent do
  use PortfolioWeb, :live_component

  alias Portfolio.Blogs

  def label(assigns) do
    ~H"""
    <label for={@for} class="label">
      <span class="label-text">
        {@children || String.capitalize(String.replace(@for, "_", " "))}
      </span>
    </label>
    """
  end

  def error(assigns) do
    ~H"""
    <div :for={msg <- @children} class="text-red-600 text-sm mt-1">
      {msg}
    </div>
    """
  end

  def translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-6">
        <h2 class="text-2xl font-bold">{@title}</h2>
        <p class="text-sm text-gray-600 mt-1">
          Use this form to manage blog records in your database.
        </p>
      </div>

      <.form
        for={@form}
        id="blog-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="space-y-4">
          <.input field={@form[:title]} type="text" label="Title" />
          <.input field={@form[:slug]} type="text" label="Slug" />
          <.input
            field={@form[:format]}
            type="select"
            label="Format"
            options={Portfolio.ContentProcessor.supported_formats()}
          />
          <.input field={@form[:content]} type="textarea" label="Content" rows="20" />
          <.input field={@form[:excerpt]} type="textarea" label="Excerpt" rows="3" />
          <.input field={@form[:published]} type="checkbox" label="Published" />
          <.input field={@form[:published_at]} type="datetime-local" label="Published At" />

          <div class="flex justify-end">
            <.button type="submit" phx-disable-with="Saving...">Save Blog</.button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{blog: blog} = assigns, socket) do
    changeset = Blogs.change_blog(blog)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"blog" => blog_params}, socket) do
    blog_params =
      if blog_params["slug"] == "" && blog_params["title"] != "" do
        Map.put(blog_params, "slug", Blogs.generate_slug(blog_params["title"]))
      else
        blog_params
      end

    changeset =
      socket.assigns.blog
      |> Blogs.change_blog(blog_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"blog" => blog_params}, socket) do
    save_blog(socket, socket.assigns.action, blog_params)
  end

  defp save_blog(socket, :edit, blog_params) do
    case Blogs.update_blog(socket.assigns.blog, blog_params) do
      {:ok, blog} ->
        notify_parent({:saved, blog})

        {:noreply,
         socket
         |> put_flash(:info, "Blog updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_blog(socket, :new, blog_params) do
    case Blogs.create_blog(blog_params) do
      {:ok, blog} ->
        notify_parent({:saved, blog})

        {:noreply,
         socket
         |> put_flash(:info, "Blog created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
