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

  @type number_like :: integer() | float() | Decimal.t() | String.t()
  @type year_month :: Date.t() | %{required(:year) => integer(), required(:month) => 1..12, optional(any()) => any()}

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
  @spec date(Date.t() | DateTime.t() | NaiveDateTime.t() | nil, :default | :short) :: String.t() | nil
  def date(date, style \\ :default)
  def date(nil, _style), do: nil
  def date(date, :default), do: format_date(date, "dd.MM.y")
  def date(date, :short), do: format_date(date, "dd.MM.")

  @doc """
  Returns the German name of a month.

  Styles: `:long` (`"September"`) and `:short` (`"Sept."`).
  Accepts a month number (1–12) or anything with a `:month` field (`Date`, month structs).

      iex> FinopstechFormat.month_name(3)
      "März"

      iex> FinopstechFormat.month_name(~D[2026-09-24], :short)
      "Sept."
  """
  @spec month_name(1..12 | %{required(:month) => 1..12, optional(any()) => any()} | nil, :long | :short) ::
          String.t() | nil
  def month_name(month, style \\ :long)
  def month_name(nil, _style), do: nil
  def month_name(%{month: month}, style), do: month_name(month, style)

  def month_name(month, style) when month in 1..12 do
    format_date(Date.new!(2000, month, 1), month_pattern(style))
  end

  @doc """
  Formats a month with its year, e.g. `"September 2026"` (`:long`) or `"Sept. 2026"` (`:short`).
  Accepts `Date` or anything with `:year` and `:month` fields.

      iex> FinopstechFormat.month(%{year: 2026, month: 9})
      "September 2026"
  """
  @spec month(year_month() | nil, :long | :short) :: String.t() | nil
  def month(month, style \\ :long)
  def month(nil, _style), do: nil

  def month(%{year: year, month: month}, style) do
    format_date(Date.new!(year, month, 1), month_pattern(style) <> " y")
  end

  @doc """
  Formats a time as `"14:30"`.
  Accepts `Time`, `DateTime` (shifted to Europe/Berlin) and `NaiveDateTime`.

      iex> FinopstechFormat.time(~T[14:30:59])
      "14:30"
  """
  @spec time(Time.t() | DateTime.t() | NaiveDateTime.t() | nil) :: String.t() | nil
  def time(nil), do: nil
  def time(%DateTime{} = datetime), do: datetime |> to_local() |> time()
  def time(%NaiveDateTime{} = datetime), do: datetime |> NaiveDateTime.to_time() |> time()
  def time(%Time{} = time), do: Cldr.Time.to_string!(time, format: "HH:mm")

  @doc """
  Formats a point in time as `"24.09.2026, 14:30"`.
  `DateTime` values are shifted to Europe/Berlin, `NaiveDateTime` values are taken as local time.

      iex> FinopstechFormat.datetime(~N[2026-09-24 14:30:00])
      "24.09.2026, 14:30"
  """
  @spec datetime(DateTime.t() | NaiveDateTime.t() | nil) :: String.t() | nil
  def datetime(nil), do: nil
  def datetime(%DateTime{} = datetime), do: datetime |> to_local() |> datetime()

  def datetime(%NaiveDateTime{} = datetime) do
    date(NaiveDateTime.to_date(datetime)) <> ", " <> time(NaiveDateTime.to_time(datetime))
  end

  defp format_date(%DateTime{} = datetime, pattern), do: datetime |> to_local() |> format_date(pattern)

  defp format_date(%NaiveDateTime{} = datetime, pattern), do: datetime |> NaiveDateTime.to_date() |> format_date(pattern)

  defp format_date(%Date{} = date, pattern), do: Cldr.Date.to_string!(date, format: pattern)

  defp month_pattern(:long), do: "MMMM"
  defp month_pattern(:short), do: "MMM"

  defp to_local(%DateTime{} = datetime) do
    datetime |> DateTime.shift_zone!(@time_zone) |> DateTime.to_naive()
  end

  # CLDR doesn't round floats exactly (e.g. 0.005 becomes "0,00"); going through the
  # shortest decimal representation of the float gives correct half-up rounding.
  defp to_decimal(number) when is_float(number), do: Decimal.from_float(number)
  defp to_decimal(number) when is_binary(number), do: Decimal.new(number)
  defp to_decimal(number), do: number
end
