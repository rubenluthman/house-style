# Roadmap

## Active

- read: the release workflow publishes immutable tags without running rule tests or archive checks – push a `vX.Y.Z` tag without local hooks or before CI finishes on `main`, and `release.yml` uploads `dist/HouseStyle.zip` without running `scripts/test_rules.sh` or `scripts/commit-checks scan-archive`, contradicting `README.md:55` (`.github/workflows/release.yml:5-8,18-80`; `.github/workflows/rules.yml:3-20`; `README.md:55`).
- read: lightweight release tags are not blocked before publishing – create a tag without `-a` and push `vX.Y.Z`, and neither `.githooks/pre-push` nor `release.yml` rejects it, publishing an immutable tag that fails `verify_commit.sh` and commit-checks CI on later commits until allowlisted (`.github/workflows/release.yml:23-41`; `.githooks/pre-push:3`; `.commit-checks.json:7-33`).
- read: the `rules` workflow `paths` filter skips the repo-wide em-dash scan on workflow and config files – edit only `.github/workflows/release.yml`, `.commit-checks.json`, `.githooks/*`, `.gitignore`, or `LICENSE`, and CI runs neither `rules.yml` nor Vale (`AGENTS.md:7`; `.github/workflows/rules.yml:6-20`; `.vale.ini`).
- read: local release builds zip the live `HouseStyle/` directory instead of tracked files – place an untracked or gitignored file inside `HouseStyle/` and run `scripts/build_release.sh`, and `dist/HouseStyle.zip` bundles it (`scripts/build_release.sh:5`).
- read: `scripts/test_rules.sh` never tests consumer `vale sync` loading of `dist/HouseStyle.zip` – a broken archive passes local tests (`scripts/build_release.sh`).
- `README.md` says the CI-backed local Vale skip applies to `CONTRIBUTING.md` "at the root or in `docs/`" and points to `vale.sh/docs/install`, whereas `commit-checks` checks root `CONTRIBUTING.md` only and prints `(brew install vale)` (`README.md:35,37`).
- `README.md` Development section omits running `scripts/install-hooks.sh` (needed for the pre-push hook it describes) and installing `gitleaks` (required by `scripts/verify_commit.sh`) (`README.md:49-55`; `AGENTS.md:9`).
- `README.md` Releasing steps omit updating the pinned release tag example and pushing `main` with the annotated tag (`README.md:25,61-62`).
- `CHANGELOG.md` repeats the `0.1.1` `Dashes` change under `0.2.0` even though `v0.1.1..v0.2.0` did not touch `HouseStyle/Dashes.yml` (`CHANGELOG.md:47,52`).

## Icebox

- Rules for more file types, such as TypeScript or Kotlin comments, once a repository that loads the package needs them. The package covers Markdown and Swift.
- Decide whether to tighten `Headings` `threshold` from Vale's default `0.8` (`HouseStyle/Headings.yml:1-8`) – today 5+ word headings with one miscased word such as ``## How to configure Custom settings`` pass, while `1.0` would also flag any 5+ word heading with a single unlisted proper noun (only viable after fixing the colon-after-exception bug).
