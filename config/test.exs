import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :yocoin, YocoinWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "gf3Nu3p1V//dNV/oomVIxNRK2PptwQg/540w4xALUf1fTZOKkQEXVscvn1w2lGFG",
  server: false

# In test we don't send emails.
config :yocoin, Yocoin.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
