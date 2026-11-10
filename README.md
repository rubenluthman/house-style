# house-style

A [Vale](https://vale.sh) style package for wording and punctuation checks. Repositories load it at a tagged release, so every project applies the same rules and a rule change reaches them from one place.

## Rules

| Rule | Checks | Reason |
| :--- | :--- | :--- |
| `HouseStyle.Promotional` | Promotional and generic phrasing, such as "seamless" or "cutting-edge" | Claims of quality without evidence tell the reader nothing. Name the property or behavior instead. |
| `HouseStyle.Filler` | Vague filler and stock figures of speech, such as "delve" or "testament to" | Padding delays the fact the sentence is there to state. |
| `HouseStyle.Dashes` | The em dash (U+2014) in Markdown and Swift, including code spans and string literals | House typography uses a spaced en dash ( – ), as in Swedish and British usage. |

Rules live only in `HouseStyle/*.yml`. `Promotional` skips code spans, fenced blocks and Swift string literals, and checks Swift comments. `Dashes` uses the `raw` scope, so it also covers code and string literals; write the escape `\u{2014}` in Swift when the character itself is needed. Consumers need no config beyond the pin and `BasedOnStyles = HouseStyle` for the file types they check.

## Use in a repository

Pin a release in `.vale.ini`, then run `vale sync`:

```ini
StylesPath = .vale/styles
MinAlertLevel = error
Packages = https://github.com/rubenluthman/house-style/releases/download/v0.2.1/HouseStyle.zip

[*.md]
BasedOnStyles = HouseStyle
```

Add `.vale/styles/HouseStyle` to `.gitignore`; `vale sync` restores it. Run `vale sync` again whenever the pinned release changes, not only when the style folder is missing; otherwise a version bump keeps running the old cached rules. The pattern: compare the `Packages` line in `.vale.ini` with a `.pin` stamp that `verify_commit.sh` writes inside `.vale/styles/HouseStyle/` after each successful sync, and resync when they differ. Run `vale --output=JSON .` or plain `vale .` in `verify_commit.sh`. Add local rules only for file types this package does not cover. List `vale` as a verification dependency in the repository's `AGENTS.md`.

### CI and local runs

A repository that takes outside contributions (it has a `CONTRIBUTING.md` at the root or in `docs/`) runs the prose check in CI, on changes to the prose file types the repository checks (for example `**.md`), plus `.vale.ini`. The workflow installs a pinned Vale release and checks its SHA-256 before running it.

Where CI runs the check, the local `verify_commit.sh` skips the Vale step with a notice when `vale` is missing, pointing contributors to [vale.sh/docs/install](https://vale.sh/docs/install). It fails on a missing `vale` only when the `CI` environment variable is set. Any other repository keeps failing locally when `vale` is missing.

## House style paragraph

Copy the paragraph below verbatim into `CONTRIBUTING.md` (or `docs/` when the repository has none).

<!-- house-style-paragraph:start -->
This project follows a shared house style for wording and punctuation. It asks for concrete properties instead of claims of quality, and for facts instead of filler. Parenthetical breaks require a spaced en dash ( – ) instead of an em dash, following Swedish and British typographic standards. [Vale](https://vale.sh) enforces these checks via the [house-style](https://github.com/rubenluthman/house-style) package, and each rule's message gives its reason.
<!-- house-style-paragraph:end -->

## Development

```bash
./scripts/verify_commit.sh   # fixture tests; needs vale and jq
./scripts/build_release.sh   # writes dist/HouseStyle.zip
```

Fixtures in `tests/` use the placeholder `@@EMDASH@@`, which the script replaces with U+2014 in a temporary copy, so the repository never contains an em dash.

## Releasing

1. Update `CHANGELOG.md`, run `verify_commit.sh`, commit, and tag `vX.Y.Z`.
2. Run `build_release.sh` and attach `dist/HouseStyle.zip` to the GitHub release for that tag.

The archive holds one top-level `HouseStyle/` folder, as Vale's [packages documentation](https://docs.vale.sh/keys/packages) requires.

## License

MIT
