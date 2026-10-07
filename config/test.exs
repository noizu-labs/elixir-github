import Config

# Print only warnings and errors during test
config :logger, level: :warning

if File.exists?("config/test.secret.exs"), do: import_config("test.secret.exs")
