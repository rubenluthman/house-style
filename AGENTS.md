# AGENTS.md

Vale style package (`HouseStyle/`) loaded by other repositories through Vale's `Packages` key.

- Word lists live only in `HouseStyle/*.yml`. Every rule needs a `message` stating its reason.
- The house style paragraph lives only in `README.md`, between the `house-style-paragraph` markers.
- Never write a literal em dash in any file; fixtures use `@@EMDASH@@`.
- Verify with `./scripts/verify_commit.sh` (needs `vale`, `jq`). Release zip: `./scripts/build_release.sh`.
- Tags are immutable; repositories pin them. Add words by releasing a new tag.
