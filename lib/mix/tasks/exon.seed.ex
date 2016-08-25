defmodule Mix.Tasks.Exon.Seed do  
  use Mix.Task
  import Exon.Database

  @shortdoc "Populates the database in dev environment"
  def run(_) do
    Mix.Task.run "app.start", []
    seed(Mix.env)
  end

  def seed(:dev) do
	record(:ok, "Thingy", "First of the Name", "anon")

	record(:ok, "Thingster", "Lying around", "anon")
    # Let me dream!
    record(:ok, "Photon cannon", "Hey listen, the feds might or might not be looking for this stuff, so… take care, hun!",
                "Fred")

    add_new_user("Fred", "carabistouilles$8080")
  end

  def seed(:prod) do
	nil
  end
end
