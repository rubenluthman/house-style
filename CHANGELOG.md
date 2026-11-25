# Changelog

## [Unreleased]

## [0.3.9] - 2026-11-25

- `Headings` again accepts listed names joined by a slash, such as `React/Swift setup`.

## [0.3.8] - 2026-11-25

- `Headings` again accepts a listed name, acronym or CamelCase word next to brackets, quotes, `.`, `;`, `?` or `!`, as in `Apple native (SwiftUI)` or `Why Swift?`, which 0.3.7 flagged.

## [0.3.7] - 2026-11-24

- `Headings` expects a capital after a colon that follows an acronym or listed name (`API: Overview`), and accepts headings that start with a number (`2026 release notes`), single letters before punctuation (`Option A, option B`) and `I` contractions.
- `Headings` now flags Title Case words that only contain a listed name, such as `State Machines`.
- `Promotional` also catches `game changer`, `state of the art`, `cutting edge`, `world class`, `best in class`, `ground-breaking` and `blazingly`.

## [0.3.6] - 2026-11-23

- `Headings` no longer allows `Offentlig`; a repository that uses the name adds it to its own `TokenIgnores`.

## [0.3.5] - 2026-11-19

- `Headings` allows `Mac`.

## [0.3.4] - 2026-11-13

- `Headings` no longer flags single capital letters (`Option A and option B`) and allows `Wi-Fi`, `Linux`, `Markdown` and `Python`.
- `Promotional` and `Filler` now catch word forms such as `delves`, `testaments to`, `game-changers`, `revolutionizes` and `robust solutions`.
- Corrected the README `TokenIgnores` advice: one alternation entry when one name starts another.

## [0.3.3] - 2026-11-13

- No changes from 0.3.2. The `v0.3.3` tag has no release download; pin 0.3.4 or later.

## [0.3.2] - 2026-11-13

- Documented `TokenIgnores` in a repository's own `.vale.ini` as the one place to allow its own names in headings; the rules are unchanged from 0.3.1.
- `verify_commit.sh` now fails on home-directory paths and access tokens in tracked files.

## [0.3.1] - 2026-11-11

- Corrected the README guidance for names in headings: wrap the one heading in an inline `vale HouseStyle.Headings` NO/YES comment pair instead of using a vocabulary.
- Documented that vocabulary files should not be used with `Headings`, because Vale then flags headings that contain a comma.

## [0.3.0] - 2026-11-10

- Added the `Headings` rule: Markdown headings use sentence case (`error` level), with the first word after a colon capitalized.
- Limited the CI prose check to repositories that take outside contributions (they have a `CONTRIBUTING.md`); other repositories keep failing locally when `vale` is missing.
- Reworded the standard house style paragraph; repositories must replace their copy.

## [0.2.1] - 2026-11-10

- Reworded the standard house style paragraph; repositories must replace their copy.
- Documented the CI prose check and the local skip-with-notice behavior in the README.

## [0.2.0] - 2026-11-06

- Added the `Filler` rule for vague filler and stock figures of speech, split out of `Promotional`.
- Reworded the standard house style paragraph; repositories must replace their copy.

## [0.1.1] - 2026-11-06

- `Dashes` now uses the `raw` scope, so em dashes in Swift string literals and Markdown code spans are flagged.
- Added Swift fixtures for strings and comments.

## [0.1.0] - 2026-11-06

- Added the `HouseStyle` Vale style with `Promotional` and `Dashes` rules.
- Added the standard house style paragraph for contributor documents.
