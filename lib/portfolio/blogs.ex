defmodule Portfolio.Blogs do
  @moduledoc """
  The Blogs context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Portfolio.Repo
  alias Portfolio.Blog
  alias Portfolio.ContentProcessor

  @doc """
  Returns the list of published blogs.
  """
  def list_published_blogs do
    Blog
    |> where([b], b.published == true)
    |> order_by([b], desc: b.published_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of all blogs (for admin).
  """
  def list_blogs do
    Blog
    |> order_by([b], desc: b.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single blog by slug.
  """
  def get_blog_by_slug!(slug) do
    Blog
    |> where([b], b.slug == ^slug and b.published == true)
    |> Repo.one!()
  end

  @doc """
  Gets a single blog by slug (admin version - includes drafts).
  """
  def get_blog_by_slug_admin!(slug) do
    Blog
    |> where([b], b.slug == ^slug)
    |> Repo.one!()
  end

  @doc """
  Gets a single blog (for admin - includes drafts).
  """
  def get_blog!(id), do: Repo.get!(Blog, id)

  @doc """
  Creates a blog.
  """
  def create_blog(attrs \\ %{}) do
    %Blog{}
    |> Blog.changeset(attrs)
    |> process_content()
    |> Repo.insert()
  end

  @doc """
  Updates a blog.
  """
  def update_blog(%Blog{} = blog, attrs) do
    blog
    |> Blog.changeset(attrs)
    |> process_content()
    |> Repo.update()
  end

  @doc """
  Deletes a blog.
  """
  def delete_blog(%Blog{} = blog) do
    Repo.delete(blog)
  end

  @doc """
  Returns an %Ecto.Changeset{} for tracking blog changes.
  """
  def change_blog(%Blog{} = blog, attrs \\ %{}) do
    Blog.changeset(blog, attrs)
  end

  defp process_content(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} = cs ->
        content_changed = get_change(cs, :content) || get_change(cs, :format)

        if content_changed do
          content = get_field(cs, :content)
          format = get_field(cs, :format) || "markdown"

          if content do
            rendered_html = ContentProcessor.process(content, format)
            put_change(cs, :rendered_html, rendered_html)
          else
            cs
          end
        else
          cs
        end

      invalid_cs ->
        invalid_cs
    end
  end

  @doc """
  Generates a slug from title.
  """
  def generate_slug(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.trim("-")
  end
end
