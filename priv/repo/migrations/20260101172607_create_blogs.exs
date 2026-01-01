defmodule Portfolio.Repo.Migrations.CreateBlogs do
  use Ecto.Migration

  def change do
    create table(:blogs) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :content, :text, null: false
      add :format, :string, default: "markdown", null: false
      add :rendered_html, :text
      add :excerpt, :text
      add :published, :boolean, default: false
      add :published_at, :utc_datetime

      timestamps()
    end

    create unique_index(:blogs, [:slug])
    create index(:blogs, [:published, :published_at])
  end
end
