defmodule FinopstechFormat.Cldr do
  @moduledoc """
  CLDR backend for `FinopstechFormat` (German locale only).

  The locale data is committed under `priv/cldr/locales/` so builds don't need to
  download it. After updating ex_cldr, commit the regenerated file as well.
  """
  use Cldr,
    otp_app: :finopstech_format,
    locales: ["de"],
    default_locale: "de",
    providers: [Cldr.Number, Cldr.Calendar, Cldr.DateTime]
end
