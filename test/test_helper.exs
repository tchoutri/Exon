alias Exon.Types.Client
ExUnit.start

Mix.Task.run "ecto.drop", ~w( -r Exon.Repo --quiet)
Mix.Task.run "ecto.create", ~w(-r Exon.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Exon.Repo --quiet)

Exon.Server.new_item("Test1", "This is a comment", %Client{})
Exon.Server.new_item("Test2", "This is a test comment", %Client{})
Exon.Server.new_item("Test3", "This is another test comment", %Client{})

hpass = Comeonin.Pbkdf2.hashpwsalt("hunter2")
Exon.Repo.insert %Exon.User{username: "nixon", hashed_password: hpass}
