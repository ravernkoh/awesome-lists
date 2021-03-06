defmodule AwesomeWeb.ListTest do
  use AwesomeWeb.FeatureCase, async: true
  import Wallaby.Query, only: [text_field: 1, button: 1, css: 2, link: 1]
  alias Awesome.{Lists, Accounts}

  describe "list listing" do
    setup do
      {:ok, user} = Accounts.register_user(%{
        name: "John Tan",
        email: "john_tan@gmail.com",
        password: "123456",
        password_confirmation: "123456",
      })
      author = Lists.get_author(user)
      {:ok, _} = Lists.create_list(author, %{
        title: "List 1",
        description: "list 1 description",
      })
      {:ok, _} = Lists.create_list(author, %{
        title: "List 2",
        description: "list 2 description",
      })
      {:ok, _} = Lists.create_list(author, %{
        title: "List 3",
        description: "list 3 description",
      })
      :ok
    end

    test "displays content and author correctly", %{session: session} do
      session
      |> visit(list_path(Endpoint, :index))
      |> take_screenshot()
      |> find(css(".card", count: 3))
      |> Enum.with_index()
      |> Enum.each(fn {elem, idx}->
             elem
             |> assert_has(Wallaby.Query.text("List #{idx + 1}"))
             |> assert_has(Wallaby.Query.text("list #{idx + 1} description"))
             |> assert_has(link("John Tan"))
           end)
         end
  end

  describe "list showing" do
    setup do
      {:ok, user} = Accounts.register_user(%{
        name: "John Tan",
        email: "john_tan@gmail.com",
        password: "123456",
        password_confirmation: "123456",
      })
      author = Lists.get_author(user)
      {:ok, _} = Lists.create_list(author, %{
        title: "List 1",
        description: "list 1 description",
        slug: "list1"
      })

      {:ok, user2} = Accounts.register_user(%{
        name: "Sam Lim",
        email: "sam_lim@gmail.com",
        password: "123456",
        password_confirmation: "123456",
      })
      author2 = Lists.get_author(user2)
      {:ok, _} = Lists.create_list(author2, %{
        title: "List 2",
        description: "list 2 description",
        slug: "list2"
      })
      :ok
    end

    test "list details correctly", %{session: session} do
      session
      |> visit(list_path(Endpoint, :index))
      |> click(Wallaby.Query.text("List 1"))
      |> assert_has(Wallaby.Query.text("List 1"))
      |> assert_has(Wallaby.Query.text("list 1 description"))
    end

    test "add if user is owner", %{session: session} do
      session
      |> perform_login("john_tan@gmail.com", "123456")
      |> visit(list_path(Endpoint, :index))
      |> click(Wallaby.Query.text("List 1"))
      |> assert_has(link("Add"))
    end

    test "contribute if user is not owner", %{session: session} do
      session
      |> perform_login("john_tan@gmail.com", "123456")
      |> visit(list_path(Endpoint, :index))
      |> click(Wallaby.Query.text("List 2"))
      |> assert_has(link("Contribute"))
    end

    test "login to contribute if user not logged in", %{session: session} do
      session
      |> visit(list_path(Endpoint, :index))
      |> click(Wallaby.Query.text("List 2"))
      |> assert_has(link("Login to contribute"))
    end
  end

  describe "list creation" do
    setup do
      {:ok, _} = Accounts.register_user(%{
        name: "John Tan",
        email: "john_tan@gmail.com",
        password: "123456",
        password_confirmation: "123456",
      })
      :ok
    end

    test "with invalid data fails", %{session: session} do
      session
      |> perform_login("john_tan@gmail.com", "123456")
      |> visit(list_path(Endpoint, :new))
      |> fill_in(text_field("Title"), with: "a very looooooooooooooooooooooooooooooooooooooooooooooooooooong title")
      |> fill_in(text_field("Description"), with: "an even loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooonger description")
      |> click(button("Create the list"))
      |> assert_has(flash("Oops", :danger))
    end

    test "with valid data succeeds", %{session: session} do
      session
      |> perform_login("john_tan@gmail.com", "123456")
      |> visit(list_path(Endpoint, :new))
      |> fill_in(text_field("Title"), with: "A title")
      |> fill_in(text_field("Description"), with: "A description")
      |> click(button("Create the list"))
      |> assert_has(flash("Created", :success))
    end

    test "is a protected route", %{session: session} do
      session
      |> visit(list_path(Endpoint, :new))
      |> assert_has(flash("need to login", :danger))
    end
  end
end
