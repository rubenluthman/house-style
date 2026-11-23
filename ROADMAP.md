# Roadmap

## Active

- Run the fixture tests in `scripts/verify_commit.sh` before every push and in CI. Today they run only when someone starts the script by hand: the hooks and the CI workflow run only the shared commit checks, whose Vale step skips this repository because its `.vale.ini` pins no package. Every repository that pins a tag gets these rules, so a broken rule should fail here first.
- Build `HouseStyle.zip` and publish the GitHub release in a workflow when a `v*` tag is pushed. The manual upload step is how `v0.3.3` shipped with no download.

## Icebox

- Rules for more file types, such as TypeScript or Kotlin comments, once a repository that loads the package needs them. The package covers Markdown and Swift.
