defmodule FinopstechFormat.ApplicationTest do
  # async: false, because the tests replace the German locale data in Localize
  use ExUnit.Case, async: false

  alias FinopstechFormat.Application

  test "the shipped German locale data matches the CLDR data version of Localize" do
    locale_data = Application.locale_file() |> File.read!() |> :erlang.binary_to_term()

    assert Map.get(locale_data, :version) == Localize.version()
  end

  test "load_locale!/0 replaces fallback data that Localize stored under :de" do
    {:ok, english} = Localize.Locale.load(:en)
    :ok = Localize.Locale.store(:de, english)
    assert FinopstechFormat.month_name(3) == "March"

    assert Application.load_locale!() == :ok
    assert FinopstechFormat.month_name(3) == "März"
  end
end
