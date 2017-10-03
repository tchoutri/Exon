# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Exon.Repo.insert!(%Exon.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Exon.Database
alias Exon.Accounts.User
alias Exon.Structs.Client
alias Exon.Repo

Repo.insert! %User{username: "anon", password_hash: "."}

populate = fn ->
  add_new_user "Fred", "carabistouilles$8080"
  client = %Client{username: "Fred"}


  add_new_item "Thingy", "First of the Name", %Client{}
  add_new_item "Thingster", "Lying around… not doing much…", %Client{}
  add_new_item "Photon cannon", "Hey listen, the feds might or might not be looking for this stuff…", client

end

case Mix.env do
  :dev  -> populate.()
  :test -> populate.()
  _    -> nil
end
