defmodule Portfolio.Blog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blogs" do
    field :title, :string
    field :slug, :string
    field :content, :string
    field :format, :string, default: "markdown"
    field :rendered_html, :string
    field :excerpt, :string
    field :published, :boolean, default: false
    field :published_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(blog, attrs) do
    blog
    |> cast(attrs, [
      :title,
      :slug,
      :content,
      :format,
      :rendered_html,
      :excerpt,
      :published,
      :published_at
    ])
    |> validate_required([:title, :content, :format])
    |> validate_inclusion(:format, ["markdown"])
    |> validate_length(:title, min: 1, max: 200)
    |> validate_length(:slug, min: 1, max: 200)
    |> unique_constraint(:slug)
  end
end
