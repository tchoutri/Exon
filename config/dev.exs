use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :exon, Exon.Endpoint,
  http: [port: 4000, ip: {127,0,0,1}],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
               cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :exon, Exon.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

config :exon,
  port: 8878,
  bindto: '0.0.0.0'

config :exon, Exon.Repo,
  adapter: Sqlite.Ecto,
  database: "priv/dev.sqlite3"

