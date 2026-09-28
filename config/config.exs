import Config

if config_env() == :test do
  config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase
end
