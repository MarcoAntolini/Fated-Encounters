## Summary

<!-- What does this PR change and why? Link issues: Fixes #123 -->

## Type of change

- [ ] Bug fix
- [ ] New feature
- [ ] Config / documentation only
- [ ] Other (describe below)

## Testing

<!-- How did you verify this in-game or locally? -->

- [ ] Tested with r2modman + symlinked `src` (or imported package)
- [ ] Config / in-game settings UI / README / CHANGELOG updated where needed
- [ ] Existing `.cfg` upgrades cleanly after a Chalk `version` bump or key move (`config_migrate.lua`, if applicable)
- [ ] `debugLog` used for guarantee logic (if applicable)

**Test details:**

<!-- e.g. enabled only Artemis, visited Erebus, confirmed one forced encounter -->

## Changelog

- [ ] Added an entry under `## [Unreleased]` in [CHANGELOG.md](../CHANGELOG.md)

## Checklist

- [ ] PR is focused (no unrelated drive-by changes)
- [ ] New config keys include `descript` text, in-game UI in `src/imgui.lua`, README Settings reference row, and `config_migrate.lua` step if keys moved (if user-facing)
- [ ] [`src/def.lua`](../src/def.lua) updated if public API changed
