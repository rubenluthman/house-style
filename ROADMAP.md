# Roadmap

## Active

- `Headings` flags two listed names joined by a slash, such as `React/Swift setup`, because each exception must match the whole space-separated word; 0.3.6 accepted it (`HouseStyle/Headings.yml`).

## Icebox

- Rules for more file types, such as TypeScript or Kotlin comments, once a repository that loads the package needs them. The package covers Markdown and Swift.
- Decide whether to tighten `Headings` `threshold` from Vale's default `0.8` (`HouseStyle/Headings.yml:1-8`) – today 5+ word headings with one miscased word such as ``## How to configure Custom settings`` pass, while `1.0` would also flag any 5+ word heading with a single unlisted proper noun (only viable after fixing the colon-after-exception bug).
