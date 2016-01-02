ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Exon.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Exon.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Exon.Repo)

