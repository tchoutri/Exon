defmodule InternalsTest do
  use ExUnit.Case, async: true
  alias Exon.{Repo,User,Database,Client}

  test "Internals:\tDeleting an item" do
    {:ok, response} = Exon.Server.new_item("Soon-to-be-removed-item", "nothing to say.", %Client{}) |> Poison.decode
    {:ok, data}     = Exon.Server.remove_item(:authed, "#{response["data"]}") |> Poison.decode
      assert data["status"]  == "success"
      assert data["message"] == "Item successfully deleted"
  end

  test "Internals:\tDeleting a user" do
    %User{username: "kennedy", hashed_password: "lol"} |> Repo.insert!
      assert Exon.Database.remove_user("kennedy") == :ok
  end

  test "Internals:\tChanging a user's password" do
    %User{username: "bush", hashed_password: "mdr"} |> Repo.insert!
    hpass = Aeacus.hashpwsalt("ptdr")
      assert Exon.Database.change_passwd("bush", hpass) == :ok
  end

  test "Internals:\tEnsure \"hunter2\" in weak enough" do
    assert Database.add_new_user("Johnson", "hunter2") == {:error, :weak_password}
  end
end
