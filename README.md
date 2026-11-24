# house-style

A [Vale](https://vale.sh) style package for wording, punctuation, and heading checks. Repositories load it at a tagged release, so every project applies the same rules and a rule change reaches them from one place.

## Rules

| Rule | Checks | Reason |
| :--- | :--- | :--- |
| `HouseStyle.Promotional` | Promotional and generic phrasing, such as `seamless` or `cutting-edge` | Claims of quality without evidence tell the reader nothing. Name the property or behavior instead. |
| `HouseStyle.Filler` | Vague filler and stock figures of speech, such as `delve` or `testament to` | Padding delays the fact the sentence is there to state. |
| `HouseStyle.Dashes` | The em dash (U+2014) in Markdown and Swift, including code spans and string literals | House typography uses a spaced en dash ( – ), as in Swedish and British usage. |
| `HouseStyle.Headings` | Markdown headings that break sentence case, at `error` level | American technical style guides, including Microsoft's and Google's, write headings in sentence case. One convention keeps every document consistent. |

Rules live only in `HouseStyle/*.yml`. `Promotional` and `Filler` skip code spans, fenced blocks and Swift string literals, and check Swift comments. `Dashes` uses the `raw` scope, so it also covers code and string literals; write the escape `\u{2014}` in Swift when the character itself is needed. Consumers need no config beyond the pin and `BasedOnStyles = HouseStyle` for the file types they check.

`Headings` capitalizes the first word and the first word after a colon, and it skips code spans, numbered prefixes like `2.` or `1.2`, acronyms, CamelCase words and file names. It reads only Markdown headings, so body text and commit messages are not affected. This package lists only names shared across projects. A repository allows its own names (a product, a library, a font family) once, in its own `.vale.ini` under `[*.md]`: `TokenIgnores = (\bExample(?: Kit)?\b)`. When one name starts another, write them as one entry with an alternation, as here. Vale then reads each name like a code span and still checks the rest of the heading, so `Example Kit Release Notes` is flagged and `Example Kit overview` passes. For a single heading, the inline comment pair `<!-- vale HouseStyle.Headings = NO -->` before it and `<!-- vale HouseStyle.Headings = YES -->` after it also works. Do not use Vale vocabulary files for this: with any vocabulary present, Vale also flags headings that contain a comma or a capitalized word after a colon. Wrap a version label before a colon in backticks (`` `v1`: Read-only ``) or write "Version 1: Read-only", since Vale reads a bare `v1:` as a miscased word. A heading that starts with a version needs it in backticks (`` `v0.3.6` release notes ``), because Vale reads a bare one as a list number. Wrap the quoted title of a work in backticks to keep its own capitals.

## Use in a repository

Pin a release in `.vale.ini`, then run `vale sync`:

```ini
StylesPath = .vale/styles
MinAlertLevel = error
Packages = https://github.com/rubenluthman/house-style/releases/download/v0.3.6/HouseStyle.zip

[*.md]
BasedOnStyles = HouseStyle
```

Add `.vale/styles/HouseStyle` to `.gitignore`; `vale sync` restores it. Run `vale sync` again whenever the pinned release changes, not only when the style folder is missing; otherwise a version bump keeps running the old cached rules. The pattern: compare the `Packages` line in `.vale.ini` with a `.pin` stamp that the repository's verification script writes inside `.vale/styles/HouseStyle/` after each successful sync, and resync when they differ. Run `vale --output=JSON .` or plain `vale .` in that script. Add local rules only for file types this package does not cover. List `vale` as a verification dependency in the repository's `AGENTS.md`.

### CI and local runs

A repository that takes outside contributions (it has a `CONTRIBUTING.md` at the root) runs the prose check in CI, on changes to the prose file types the repository checks (for example `**.md`), plus `.vale.ini`. The workflow installs a pinned Vale release and checks its SHA-256 before running it.

Where CI runs the check, the local verification script skips the Vale step with a notice when `vale` is missing (the notice says `brew install vale`). It fails on a missing `vale` only when the `CI` environment variable is set. Any other repository keeps failing locally when `vale` is missing.

## House style paragraph

Copy the paragraph below verbatim into `CONTRIBUTING.md` (or `docs/` when the repository has none).

<!-- house-style-paragraph:start -->
This project follows a shared house style for wording, punctuation, and headings. It asks for concrete properties instead of claims of quality, and for facts instead of filler. Parenthetical breaks require a spaced en dash ( – ) instead of an em dash, following Swedish and British typographic standards. Headings use sentence case, as in American technical style guides. [Vale](https://vale.sh) enforces these checks via the [house-style](https://github.com/rubenluthman/house-style) package, and each rule's message gives its reason.
<!-- house-style-paragraph:end -->

## Development

Run `scripts/install-hooks.sh` once after cloning to install the Git hooks. `verify_commit.sh` needs `vale`, `jq` and `gitleaks`.

```bash
./scripts/test_rules.sh      # fixture tests; needs vale and jq
./scripts/verify_commit.sh   # rule tests plus shared commit checks
./scripts/build_release.sh   # writes dist/HouseStyle.zip from tracked files
./scripts/test_archive.sh    # loads dist/HouseStyle.zip with vale sync and checks two rules alert
```

The pre-push hook and CI run the rule tests, so a broken rule fails before it can be tagged.

Fixtures in `tests/` use the placeholder `@@EMDASH@@`, which the script replaces with U+2014 in a temporary copy, so the repository never contains an em dash.

## Releasing

1. Update `CHANGELOG.md` with a `## [X.Y.Z]` section and the pinned version in the `Packages` example under "Use in a repository", run `verify_commit.sh`, and commit.
2. Create an annotated tag with `git tag -a vX.Y.Z` and push `main` and the tag together. Pushing the tag is the release decision: the `release` workflow builds `dist/HouseStyle.zip` from tracked files and publishes the GitHub release with that CHANGELOG section as its notes.

Before publishing, the workflow runs the rule tests, rejects a lightweight tag, checks the archive layout, scans the archive, and loads it with `vale sync` to check that two rules alert. It also fails if the CHANGELOG has no section for the tag or if the release already exists. Run it by hand (`gh workflow run release.yml`) to test it: it runs every step except publishing and uploads the zip as a workflow artifact.

The archive holds one top-level `HouseStyle/` folder, as Vale's [packages documentation](https://docs.vale.sh/keys/packages) requires.

## License

MIT
