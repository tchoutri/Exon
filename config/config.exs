# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :exon, Exon.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "pTEqPRlBiTLe53T5uNg0vBi7Mf+PN91JNY00+W8THtVZuUg4cCosML9Nea+9iWvM",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Exon.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time [$level] $message\n",
  metadata: [:request_id]

config :aeacus, Aeacus,
  repo: Exon.Repo,
  model: Exon.User,
  # Optional, The following are the default options
  crypto: Comeonin.Pbkdf2,
  identity_field: :username,
  password_field: :hashed_password,
  error_message: "Invalid identity or password."

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
