defmodule FinopstechFormatTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest FinopstechFormat

  describe "number/2" do
    for {number, fraction_digits, expected} <- [
          {1234.5, 2, "1.234,50"},
          {-1234.5, 2, "-1.234,50"},
          {1234, 2, "1.234,00"},
          {5, 2, "5,00"},
          {-5, 2, "-5,00"},
          {0, 2, "0,00"},
          {0.0, 2, "0,00"},
          {0, 0, "0"},
          {1000, 2, "1.000,00"},
          {-1_234_567, 0, "-1.234.567"},
          {23.0, 2, "23,00"},
          {23.333333333333332, 2, "23,33"},
          {0.30000000000000004, 2, "0,30"},
          {2.675, 2, "2,68"},
          {1.005, 2, "1,01"},
          {0.125, 2, "0,13"},
          {0.005, 2, "0,01"},
          {-0.005, 2, "-0,01"},
          {-0.001, 2, "-0,00"},
          {-0.004, 2, "-0,00"},
          {99.995, 2, "100,00"},
          {-99.995, 2, "-100,00"},
          {99_999.999, 2, "100.000,00"},
          {66.6666666, 0, "67"},
          {0.5, 0, "1"},
          {0.4, 0, "0"},
          {2.5, 0, "3"},
          {-2.5, 0, "-3"},
          {0.05, 1, "0,1"},
          {12.345, 1, "12,3"},
          {7.25, 3, "7,250"},
          {1_000_000_000, 2, "1.000.000.000,00"},
          {1.0e9, 2, "1.000.000.000,00"},
          {123_456_789.987, 2, "123.456.789,99"},
          {1.0e15, 2, "1.000.000.000.000.000,00"}
        ] do
      test "#{inspect(number)} with #{fraction_digits} fraction digits" do
        assert FinopstechFormat.number(unquote(number), unquote(fraction_digits)) == unquote(expected)
      end
    end

    test "defaults to two fraction digits" do
      assert FinopstechFormat.number(1234.5) == "1.234,50"
    end

    test "formats decimals and strings" do
      assert FinopstechFormat.number(Decimal.new("1234.567")) == "1.234,57"
      assert FinopstechFormat.number(Decimal.new("5.00"), 1) == "5,0"
      assert FinopstechFormat.number("12.345", 1) == "12,3"
    end

    test "returns nil for nil" do
      assert FinopstechFormat.number(nil) == nil
    end
  end

  describe "date/2" do
    test "formats dates" do
      assert FinopstechFormat.date(~D[2026-01-05]) == "05.01.2026"
      assert FinopstechFormat.date(~D[2026-01-05], :short) == "05.01."
    end

    test "formats naive datetimes by their date" do
      assert FinopstechFormat.date(~N[2026-09-24 23:59:59]) == "24.09.2026"
    end

    test "uses the local date in Europe/Berlin for datetimes" do
      assert FinopstechFormat.date(~U[2026-09-24 22:30:00Z]) == "25.09.2026"
      assert FinopstechFormat.date(~U[2026-12-31 23:30:00Z], :short) == "01.01."
    end

    test "returns nil for nil" do
      assert FinopstechFormat.date(nil) == nil
    end
  end

  describe "month_name/2" do
    test "returns German month names" do
      assert Enum.map(1..12, &FinopstechFormat.month_name/1) ==
               ~w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember)
    end

    test "returns abbreviated month names" do
      assert FinopstechFormat.month_name(3, :short) == "Mär"
      assert FinopstechFormat.month_name(9, :short) == "Sep"
    end

    test "accepts anything with a month field" do
      assert FinopstechFormat.month_name(~D[2026-05-17]) == "Mai"
      assert FinopstechFormat.month_name(Shared.Month.new!(2026, 10)) == "Oktober"
    end

    test "returns nil for nil" do
      assert FinopstechFormat.month_name(nil) == nil
    end
  end

  describe "month/2" do
    test "formats month and year" do
      assert FinopstechFormat.month(~D[2026-03-31]) == "März 2026"
      assert FinopstechFormat.month(Shared.Month.new!(2026, 9), :short) == "Sept. 2026"
    end

    test "returns nil for nil" do
      assert FinopstechFormat.month(nil) == nil
    end
  end

  describe "time/1" do
    test "formats times without seconds" do
      assert FinopstechFormat.time(~T[07:05:59]) == "07:05"
      assert FinopstechFormat.time(~N[2026-09-24 23:45:00]) == "23:45"
    end

    test "uses the local time in Europe/Berlin for datetimes" do
      assert FinopstechFormat.time(~U[2026-01-15 12:00:00Z]) == "13:00"
      assert FinopstechFormat.time(~U[2026-07-15 12:00:00Z]) == "14:00"
    end

    test "returns nil for nil" do
      assert FinopstechFormat.time(nil) == nil
    end
  end

  describe "datetime/1" do
    test "formats naive datetimes as local time" do
      assert FinopstechFormat.datetime(~N[2026-09-24 14:30:59]) == "24.09.2026, 14:30"
    end

    test "shifts datetimes to Europe/Berlin" do
      assert FinopstechFormat.datetime(~U[2026-09-24 22:30:00Z]) == "25.09.2026, 00:30"
    end

    test "handles the daylight saving time changes" do
      # 29.03.2026: 02:00 CET -> 03:00 CEST
      assert FinopstechFormat.datetime(~U[2026-03-29 00:59:00Z]) == "29.03.2026, 01:59"
      assert FinopstechFormat.datetime(~U[2026-03-29 01:00:00Z]) == "29.03.2026, 03:00"
      # 25.10.2026: 03:00 CEST -> 02:00 CET
      assert FinopstechFormat.datetime(~U[2026-10-25 00:30:00Z]) == "25.10.2026, 02:30"
      assert FinopstechFormat.datetime(~U[2026-10-25 01:30:00Z]) == "25.10.2026, 02:30"
    end

    test "returns nil for nil" do
      assert FinopstechFormat.datetime(nil) == nil
    end
  end
end
