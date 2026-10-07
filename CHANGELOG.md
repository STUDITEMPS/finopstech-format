# Changelog

All notable changes to this library. The format follows [Keep a Changelog](https://keepachangelog.com),
versions follow [Semantic Versioning](https://semver.org).

## [Unreleased]

## [0.2.0] - 2026-10-07

### Changed

- Formats with [Localize](https://hex.pm/packages/localize) (pinned to 1.3.0) instead of
  `ex_cldr_numbers`/`ex_cldr_dates_times`; ex_cldr is only supported until the end of 2027.
  The formatted output is unchanged.
- The German locale data is committed under `priv/localize/locales/de.etf` and loaded into
  Localize by `FinopstechFormat.Application` on start. Apps need no Localize configuration and
  no download; the start fails if the data doesn't match the installed Localize.
- Requires `gettext ~> 1.0` (a dependency of Localize). Apps that get `gettext ~> 0.26` through
  `timex` override it (`{:gettext, "~> 1.0", override: true}`).

### Removed

- The CLDR backend `FinopstechFormat.Cldr` and its locale data under `priv/cldr/`.

## [0.1.0]

First version: `number/2`, `percent/2`, `date/2`, `month_name/2`, `month/2`, `time/1` and
`datetime/1` with German formats on top of ex_cldr; `DateTime` values are shifted to
Europe/Berlin.
