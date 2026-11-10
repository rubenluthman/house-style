# Changelog

## [Unreleased]

- Limited the CI prose check to repositories that take outside contributions (they have a `CONTRIBUTING.md`); other repositories keep failing locally when `vale` is missing.

## [0.2.1] - 2026-11-10

- Reworded the standard house style paragraph; repositories must replace their copy.
- Documented the CI prose check and the local skip-with-notice behavior in the README.

## [0.2.0] - 2026-11-06

- Added the `Filler` rule for vague filler and stock figures of speech, split out of `Promotional`.
- `Dashes` now flags em dashes in Swift string literals and Markdown code spans.
- Reworded the standard house style paragraph; repositories must replace their copy.

## [0.1.1] - 2026-11-06

- `Dashes` now uses the `raw` scope, so em dashes in Swift string literals and Markdown code spans are flagged.
- Added Swift fixtures for strings and comments.

## [0.1.0] - 2026-11-06

- Added the `HouseStyle` Vale style with `Promotional` and `Dashes` rules.
- Added the standard house style paragraph for contributor documents.
