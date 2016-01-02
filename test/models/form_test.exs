defmodule Exon.FormTest do
  use Exon.ModelCase

  alias Exon.Form

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Form.changeset(%Form{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Form.changeset(%Form{}, @invalid_attrs)
    refute changeset.valid?
  end
end
