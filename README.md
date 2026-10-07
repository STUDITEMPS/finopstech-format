# FinopstechFormat

Preconfigured German formatting of numbers, dates and times for the FinOpsTech apps.
A thin wrapper around [CLDR](https://github.com/elixir-cldr) (`ex_cldr_numbers`,
`ex_cldr_dates_times`) that offers exactly the formats we use. Version **0.1.0**, versioned
with [Semantic Versioning](https://semver.org) (see [Versioning](#versioning)); changes not
yet released are listed under "Unreleased" in [CHANGELOG.md](CHANGELOG.md).

## Installation

```elixir
def deps do
  [
    {:finopstech_format, github: "STUDITEMPS/finopstech_format"}
  ]
end
```

`DateTime` values are shifted to `Europe/Berlin`, which needs a time zone database
(all FinOpsTech apps already configure it):

```elixir
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase
```

## Usage

| Function | Example | Result |
|---|---|---|
| `number/2` | `FinopstechFormat.number(1234.5)` | `"1.234,50"` |
| | `FinopstechFormat.number(1234.5, 0)` | `"1.235"` |
| `percent/2` | `FinopstechFormat.percent(0.125)` | `"13 %"` |
| | `FinopstechFormat.percent(0.125, fraction_digits: 1)` | `"12,5 %"` |
| | `FinopstechFormat.percent(1, fraction_digits: 1, sign: false)` | `"100,0"` |
| `date/2` | `FinopstechFormat.date(~D[2026-09-24])` | `"24.09.2026"` |
| | `FinopstechFormat.date(~D[2026-09-24], :short)` | `"24.09."` |
| `month_name/2` | `FinopstechFormat.month_name(3)` | `"März"` |
| | `FinopstechFormat.month_name(9, :short)` | `"Sep"` |
| `month/2` | `FinopstechFormat.month(~D[2026-09-24])` | `"September 2026"` |
| `time/1` | `FinopstechFormat.time(~T[14:30:59])` | `"14:30"` |
| `datetime/1` | `FinopstechFormat.datetime(~U[2026-09-24 12:30:00Z])` | `"24.09.2026, 14:30"` |

Notes:

- All functions return `nil` for `nil`.
- `number/2` accepts integers, floats, `Decimal`s and strings and rounds half up.
- `percent/2` takes a factor (`0.125` = 12,5 %); the percent sign is preceded by a non-breaking space (CLDR). Options: `fraction_digits:` (default `0`), `sign: false` returns only the value.
- `date/2`, `time/1` and `datetime/1` shift `DateTime` values to Europe/Berlin (including
  daylight saving time); `NaiveDateTime` values are taken as local time.
- `month_name/2` and `month/2` accept anything with `:month` (and `:year`) fields, e.g.
  `Date` or month structs.

## Versioning

The library follows [Semantic Versioning](https://semver.org). Each release is an annotated git
tag `vX.Y.Z` on `main`, and `version` in `mix.exs` matches the tag. Changes are listed in
[CHANGELOG.md](CHANGELOG.md).

- `0.x`: Breaking changes bump the minor version (`0.1.0` → `0.2.0`), everything else the
  patch version. A change of the formatted output counts as breaking.
- `1.0.0`: once the API is considered stable; from then on, breaking changes bump the major
  version.

Release steps:

1. Update `version` in `mix.exs` and move the "Unreleased" entries in `CHANGELOG.md` to a new
   version section.
2. Commit, then tag: `git tag -a vX.Y.Z -m "vX.Y.Z"` and `git push origin main vX.Y.Z`.
3. Apps update the `tag:` of their dependency and run `mix deps.update finopstech_format`
   (and `mix deps.unlock --unused`).

## Development

- Compatible with Elixir ≥ 1.18. CI tests Elixir 1.18/OTP 27 and 1.20/OTP 29.
- The German CLDR locale data is committed under `priv/cldr/locales/de.json`, so builds
  don't download it. After updating `ex_cldr`, run `mix compile` and commit the regenerated
  file from `_build/*/lib/finopstech_format/priv/cldr/locales/` into `priv/`.
- `mix format --check-formatted`, `mix compile --warnings-as-errors`, `mix credo --strict` and
  `mix test` must pass.
