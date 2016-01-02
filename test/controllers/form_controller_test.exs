defmodule Exon.FormControllerTest do
  use Exon.ConnCase

  alias Exon.Form
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, form_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing forms"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, form_path(conn, :new)
    assert html_response(conn, 200) =~ "New form"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, form_path(conn, :create), form: @valid_attrs
    assert redirected_to(conn) == form_path(conn, :index)
    assert Repo.get_by(Form, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, form_path(conn, :create), form: @invalid_attrs
    assert html_response(conn, 200) =~ "New form"
  end

  test "shows chosen resource", %{conn: conn} do
    form = Repo.insert! %Form{}
    conn = get conn, form_path(conn, :show, form)
    assert html_response(conn, 200) =~ "Show form"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, form_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    form = Repo.insert! %Form{}
    conn = get conn, form_path(conn, :edit, form)
    assert html_response(conn, 200) =~ "Edit form"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    form = Repo.insert! %Form{}
    conn = put conn, form_path(conn, :update, form), form: @valid_attrs
    assert redirected_to(conn) == form_path(conn, :show, form)
    assert Repo.get_by(Form, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    form = Repo.insert! %Form{}
    conn = put conn, form_path(conn, :update, form), form: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit form"
  end

  test "deletes chosen resource", %{conn: conn} do
    form = Repo.insert! %Form{}
    conn = delete conn, form_path(conn, :delete, form)
    assert redirected_to(conn) == form_path(conn, :index)
    refute Repo.get(Form, form.id)
  end
end
