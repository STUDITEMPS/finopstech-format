defmodule FinopstechFormat do
  @moduledoc """
  Preconfigured German formatting of numbers, dates and times for the FinOpsTech apps.

  A thin wrapper around CLDR (`ex_cldr_numbers`, `ex_cldr_dates_times`) with the
  formats we use everywhere. All functions return `nil` for `nil`.

  `DateTime` values are shifted to `Europe/Berlin` before formatting. This requires a
  time zone database, e.g. `config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase`.
  `NaiveDateTime` values are taken as local time.
  """

  alias FinopstechFormat.Cldr

  @time_zone "Europe/Berlin"

  @type date :: Date.t() | DateTime.t() | NaiveDateTime.t()
  @type month :: %{year: integer(), month: pos_integer(), __struct__: Shared.Month}
  @type time :: Time.t() | DateTime.t() | NaiveDateTime.t()

  @type number_like :: integer() | float() | Decimal.t() | String.t()

  @doc """
  Formats a number with a dot as thousands separator, a comma as decimal separator
  and `fraction_digits` decimal places, rounding half up.

      iex> FinopstechFormat.number(1234.5)
      "1.234,50"

      iex> FinopstechFormat.number(-1_234_567, 0)
      "-1.234.567"
  """
  @spec number(number_like() | nil, non_neg_integer()) :: String.t() | nil
  def number(number, fraction_digits \\ 2)
  def number(nil, _fraction_digits), do: nil

  def number(number, fraction_digits) when is_integer(fraction_digits) and fraction_digits >= 0 do
    number
    |> to_decimal()
    |> Cldr.Number.to_string!(fractional_digits: fraction_digits, rounding_mode: :half_up)
  end

  @doc """
  Formats a date.

  Styles:
    * `:default` – `"24.09.2026"`
    * `:short` – `"24.09."` (without year)

  Accepts `Date`, `DateTime` (shifted to Europe/Berlin) and `NaiveDateTime`.

      iex> FinopstechFormat.date(~D[2026-09-24])
      "24.09.2026"

      iex> FinopstechFormat.date(~D[2026-09-24], :short)
      "24.09."
  """
  @spec date(date() | nil, :default | :short) :: String.t() | nil
  def date(date, style \\ :default)
  def date(nil, _style), do: nil
  def date(date, :default), do: format_date(date, format: :yMMdd)
  def date(date, :short), do: format_date(date, format: :MMdd)

  @doc """
  Returns the German name of a month.

  Styles: `:long` (`"September"`) and `:short` (`"Sept."`).
  Accepts a month number (1–12) or anything with a `:month` field (`Date`, month structs).

      iex> FinopstechFormat.month_name(3)
      "März"

      iex> FinopstechFormat.month_name(~D[2026-09-24], :short)
      "Sep"
  """
  @spec month_name(date() | nil, :long | :short) :: String.t() | nil
  def month_name(month, style \\ :long)
  def month_name(nil, _style), do: nil
  def month_name(month, style) when month in 1..12, do: month_name(Date.new!(2026, month, 1), style)

  def month_name(%{year: year, month: month, __struct__: Shared.Month}, style),
    do: month_name(Date.new!(year, month, 1), style)

  def month_name(datetime, :long), do: format_date(datetime, format: :MMMM)
  def month_name(datetime, :short), do: format_date(datetime, format: :MMM)

  @doc """
  Formats a month with its year, e.g. `"September 2026"` (`:long`) or `"Sept. 2026"` (`:short`).
  Accepts `Date` or anything with `:year` and `:month` fields.

      iex> FinopstechFormat.month(~D[2026-09-01])
      "September 2026"
  """
  @spec month(date() | month() | nil, :long | :short) :: String.t() | nil
  def month(datetime, style \\ :long)
  def month(nil, _style), do: nil
  def month(month, style) when month in 1..12, do: month(Date.new!(2026, month, 1), style)
  def month(%{year: year, month: month, __struct__: Shared.Month}, style), do: month(Date.new!(year, month, 1), style)
  def month(datetime, :short), do: format_date(datetime, format: :yMMM)
  def month(datetime, :long), do: format_date(datetime, format: :yMMMM)

  @doc """
  Formats a time as `"14:30"`.
  Accepts `Time`, `DateTime` (shifted to Europe/Berlin) and `NaiveDateTime`.

      iex> FinopstechFormat.time(~T[14:30:59])
      "14:30"
  """
  @spec time(time() | nil) :: String.t() | nil
  def time(nil), do: nil
  def time(%DateTime{} = time), do: Cldr.Time.to_string!(to_local(time), format: :Hm)
  def time(%NaiveDateTime{} = time), do: Cldr.Time.to_string!(time, format: :Hm)
  def time(%Time{} = time), do: Cldr.Time.to_string!(time, format: :Hm)

  @doc """
  Formats a point in time as `"24.09.2026, 14:30"`.
  `DateTime` values are shifted to Europe/Berlin, `NaiveDateTime` values are taken as local time.

      iex> FinopstechFormat.datetime(~N[2026-09-24 14:30:00])
      "24.09.2026, 14:30"
  """
  @spec datetime(DateTime.t() | NaiveDateTime.t() | nil) :: String.t() | nil
  @dt_format "dd.MM.y, HH:mm"
  def datetime(nil), do: nil
  def datetime(%DateTime{} = datetime), do: Cldr.DateTime.to_string!(to_local(datetime), format: @dt_format)
  def datetime(%NaiveDateTime{} = datetime), do: Cldr.DateTime.to_string!(datetime, format: @dt_format)

  defp format_date(%DateTime{} = date, opts), do: Cldr.Date.to_string!(to_local(date), opts)
  defp format_date(%NaiveDateTime{} = date, opts), do: Cldr.Date.to_string!(date, opts)
  defp format_date(%Date{} = date, opts), do: Cldr.Date.to_string!(date, opts)

  defp to_local(%DateTime{} = datetime), do: DateTime.shift_zone!(datetime, @time_zone)

  # CLDR doesn't round floats exactly (e.g. 0.005 becomes "0,00"); going through the
  # shortest decimal representation of the float gives correct half-up rounding.
  defp to_decimal(number) when is_float(number), do: Decimal.from_float(number)
  defp to_decimal(number) when is_binary(number), do: Decimal.new(number)
  defp to_decimal(number), do: number
end
