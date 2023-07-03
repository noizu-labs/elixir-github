import Config

# Print only warnings and errors during test
config :logger, level: :warning

import_config "test.secret.exs"
