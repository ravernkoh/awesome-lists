defmodule Awesome.Lists do
  @moduledoc """
  CRUD for lists and collaborative stuffs
  """

  import Ecto.Changeset, only: [put_assoc: 3]
  alias Awesome.Repo
  alias Awesome.Accounts.User
  alias Awesome.Lists.{List, Author, Item}

  @doc """
  Returns author for user. If doesn't exist, create
  the author.
  """
  def get_author(%User{} = user) do
    case Repo.preload(user, :author).author do
      nil -> create_author(user)
      author -> author
    end
  end

  defp create_author(user) do
    user
    |> Ecto.build_assoc(:author)
    |> Repo.insert!()
  end

  @doc """
  Returns a list of all the lists with
  `author` preloaded.
  """
  def list_lists() do
    List
    |> Repo.all()
    |> Repo.preload([author: :user])
  end

  @doc """
  Creates a new item in a list.
  """
  def create_item(author, list, attrs) do
    author
    |> Ecto.build_assoc(:contributions)
    |> Item.changeset(attrs)
    |> put_assoc(:list, list)
    |> Repo.insert()
  end

  @doc """
  Finds a list with the correct slug, or
  raises an error if not found.
  """
  def get_list!(slug) do
    List
    |> Repo.get_by!(slug: slug)
    |> Repo.preload([[items: [author: :user]], [author: :user]])
  end

  @doc """
  Returns an empty list changeset.
  """
  def change_list(list \\ %List{}) do
    List.changeset(list, %{})
  end

  @doc """
  Returns an empty item changeset.
  """
  def change_item(item \\ %Item{}) do
    Item.changeset(item, %{})
  end

  @doc """
  Creates a list with the author as the owner.
  """
  def create_list(%Author{} = author, attrs) do
    author
    |> Ecto.build_assoc(:lists)
    |> List.changeset(attrs)
    |> Repo.insert()
  end
end
