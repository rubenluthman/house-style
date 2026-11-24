# Roadmap

## Active

- read: `.githooks/pre-push` still lets a lightweight release tag through – create a tag without `-a` and push `vX.Y.Z`, and the hook accepts it, so the tag fails `verify_commit.sh` and commit-checks CI on later commits until allowlisted; `release.yml` already rejects it, and the hook fix belongs to the shared commit-checks package (`.githooks/pre-push:3`; `.commit-checks.json:7-33`).

## Icebox

- Rules for more file types, such as TypeScript or Kotlin comments, once a repository that loads the package needs them. The package covers Markdown and Swift.
- Decide whether to tighten `Headings` `threshold` from Vale's default `0.8` (`HouseStyle/Headings.yml:1-8`) – today 5+ word headings with one miscased word such as ``## How to configure Custom settings`` pass, while `1.0` would also flag any 5+ word heading with a single unlisted proper noun (only viable after fixing the colon-after-exception bug).
