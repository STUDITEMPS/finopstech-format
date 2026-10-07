defmodule FinopstechFormat.Application do
  @moduledoc """
  Loads the German locale data shipped with this library into Localize.

  Localize only bundles `en`. Without downloads (disabled by default) a missing locale
  silently falls back to its parent chain and finally to English, so the German data is
  committed under `priv/localize/locales/de.etf` and stored in Localize on start. Apps
  don't need to configure Localize or download anything.
  """
  use Application

  @locale :de

  @impl Application
  def start(_type, _args) do
    :ok = load_locale!()
    Supervisor.start_link([], strategy: :one_for_one, name: FinopstechFormat.Supervisor)
  end

  @doc """
  Stores the shipped locale data in Localize.

  Always overwrites: if something requested `:de` before this app started, Localize
  has stored the data of its fallback locale (English) under `:de`.

  Raises if the shipped data doesn't match the CLDR data version of the installed
  Localize, instead of formatting in English.
  """
  @spec load_locale!() :: :ok
  def load_locale! do
    locale_data = locale_file() |> File.read!() |> :erlang.binary_to_term()
    check_version!(Map.get(locale_data, :version))
    Localize.Locale.store(@locale, locale_data)
  end

  @doc "Path of the shipped locale data."
  @spec locale_file() :: Path.t()
  def locale_file, do: Application.app_dir(:finopstech_format, "priv/localize/locales/#{@locale}.etf")

  defp check_version!(version) do
    if version != Localize.version() do
      raise "#{locale_file()} has CLDR data version #{inspect(version)}, " <>
              "but Localize expects #{inspect(Localize.version())}. " <>
              "Regenerate it with `mix localize.download_locales de` (see README)."
    end
  end
end
