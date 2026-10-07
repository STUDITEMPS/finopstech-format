# FinopstechFormat

Preconfigured German formatting of numbers, dates and times for the FinOpsTech apps.
A thin wrapper around [Localize](https://hex.pm/packages/localize) (Unicode CLDR) that
offers exactly the formats we use. Version **0.1.0**, versioned with
[Semantic Versioning](https://semver.org) (see [Versioning](#versioning)); changes not yet
released are listed under "Unreleased" in [CHANGELOG.md](CHANGELOG.md).

## Installation

```elixir
def deps do
  [
    {:finopstech_format, git: "git@github.com:STUDITEMPS/finopstech_format.git", tag: "v0.2.0"}
  ]
end
```

Apps don't configure anything for the formatting itself: the library always formats German
(independent of `LANG` and of the Localize default locale) and brings the German locale data
along (see [Locale data](#locale-data)). Localize needs `gettext ~> 1.0`; apps that still get
`gettext ~> 0.26` through `timex` declare `{:gettext, "~> 1.0", override: true}` (all
FinOpsTech apps already do).

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

## Locale data

Localize only bundles `en`. A locale that is neither bundled nor in its cache is not
downloaded by default (`:allow_runtime_locale_download` is `false`), and Localize then falls
back through the parent locales to English — silently. In `:dev`/`:test` it generates
missing locales from CLDR sources instead, so the problem would only show in production.

So the German locale data is committed under `priv/localize/locales/de.etf`, and
`FinopstechFormat.Application` stores it in Localize when the app starts
(`Localize.Locale.store/2`):

- no `config :localize`, no `mix localize.download_locales` in the apps, no network access at
  build time or runtime; works in `mix test`, dev, CI and releases (Heroku slug), since the
  file is read with `Application.app_dir/2`,
- it always overwrites `:de`: if something requested `:de` before this app started, Localize
  stored the English fallback data under `:de`,
- the start fails if the file doesn't match the CLDR data version of the installed Localize
  (`Localize.version/0`), instead of formatting in English. Localize is therefore pinned to
  an exact version in `mix.exs`.

Updating Localize:

1. Raise the version in `mix.exs`, `mix deps.get`.
2. `mix localize.download_locales de` (downloads into Localize's own `priv` cache, verified
   against the hash manifest of the package) and copy the file into this repository:
   `cp deps/localize/priv/localize/locales/de.etf priv/localize/locales/de.etf`, then delete
   it from `deps/` again.
3. `mix test` (checks the data version and all formats).

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
- `mix format --check-formatted`, `mix compile --warnings-as-errors`, `mix credo --strict` and
  `mix test` must pass.
