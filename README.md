# house-style

A [Vale](https://vale.sh) style package for wording and punctuation checks. Repositories load it at a tagged release, so every project applies the same rules and a rule change reaches them from one place.

## Rules

| Rule | Checks | Reason |
| :--- | :--- | :--- |
| `HouseStyle.Promotional` | Promotional and generic AI phrasing, such as "seamless" or "cutting-edge" | Claims of quality without evidence tell the reader nothing. Name the property or behavior instead. |
| `HouseStyle.Dashes` | The em dash (U+2014) in Markdown and Swift, including code spans and string literals | House typography uses a spaced en dash ( – ), as in Swedish and British usage. |

Rules live only in `HouseStyle/*.yml`. `Promotional` skips code spans, fenced blocks and Swift string literals, and checks Swift comments. `Dashes` uses the `raw` scope, so it also covers code and string literals; write the escape `\u{2014}` in Swift when the character itself is needed. Consumers need no config beyond the pin and `BasedOnStyles = HouseStyle` for the file types they check.

## Use in a repository

Pin a release in `.vale.ini`, then run `vale sync`:

```ini
StylesPath = .vale/styles
MinAlertLevel = error
Packages = https://github.com/rubenluthman/house-style/releases/download/v0.1.1/HouseStyle.zip

[*.md]
BasedOnStyles = HouseStyle
```

Add `.vale/styles/HouseStyle` to `.gitignore`; `vale sync` restores it. Run `vale --output=JSON .` or plain `vale .` in `verify_commit.sh`. Add local rules only for file types this package does not cover.

## House style paragraph

Copy the paragraph below verbatim into `CONTRIBUTING.md` (or `docs/` when the repository has none).

<!-- house-style-paragraph:start -->
This project follows a shared house style for wording and punctuation. It flags promotional or generic phrasing, because claims of quality without evidence tell the reader nothing, and it flags the em dash, because the house typography uses a spaced en dash as in Swedish and British usage. The checks run through [Vale](https://vale.sh) with the [house-style](https://github.com/rubenluthman/house-style) package, and each rule's message states its reason.
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
