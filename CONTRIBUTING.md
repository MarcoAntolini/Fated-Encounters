# Contributing to Fated Encounters

Thanks for helping improve the mod. This guide covers local setup, change expectations, and how to report issues or open pull requests.

## Before you start

- Read the [README](README.md) so you understand once-per-run guarantees and config options.
- Join the [Hades II Modding Discord](https://discord.gg/KuMbyrN) for general Hell2Modding help (not required for GitHub contributions).
- Use [GitHub Issues](https://github.com/MarcoAntolini/Fated-Encounters/issues) for bugs and feature requests (templates provided).
- For small typos or docs-only fixes, a PR without a prior issue is fine.

## Development setup

1. **Requirements:** A legal copy of Hades II, [Hell2Modding](https://thunderstore.io/c/hades-ii/p/Hell2Modding/Hell2Modding/) (via r2modman is easiest), and this mod’s Thunderstore dependencies (see `thunderstore.toml`).
2. **Clone** this repository and open it in your editor (VS Code + [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) extension recommended).
3. **Symlink for live reload** — link this repo’s `src` folder into your r2modman profile so edits apply without rebuilding the package every time:

   ```powershell
   New-Item -ItemType SymbolicLink `
     -Path "$env:APPDATA\r2modmanPlus-local\HadesII\profiles\Default\ReturnOfModding\plugins\MarcoAntolini-Fated-Encounters" `
     -Target "C:\path\to\Fated-Encounters\src"
   ```

   Adjust the profile path if you use a non-default profile. See the [mod template / dev environment](https://sgg-modding.github.io/Hades2ModWiki/docs/creating-mods/development-environment) on the Hades II Mod Wiki.

4. **First-time symlink setup:** Copy `icon.png`, `LICENSE`, and a `manifest.json` from a `tcli build` output into `src` if r2modman expects them (see wiki). Add those copies to `.gitignore` paths already listed for `src/`.

5. **Test in-game** with your change loaded; enable `debugLog` in config when debugging guarantee logic.

## Making changes

- **Scope:** Keep PRs focused. Match existing Lua style and naming in `src/`.
- **Config:** New user-facing options need defaults in `src/config.lua` (defaults + `descript`), README option table updates, and a Chalk `version` bump when merging new keys into existing `.cfg` files.
- **Changelog:** Add a bullet under a new `## [Unreleased]` section at the top of [CHANGELOG.md](CHANGELOG.md) (create the section if missing). Maintainers fold that into a versioned release.
- **API:** Document public fields for other mods in [`src/def.lua`](src/def.lua).
- **Do not** commit secrets, local `.cfg` files, or `build/` artifacts.

## Pull requests

1. Fork and branch from `main`.
2. Fill out the [pull request template](.github/pull_request_template.md).
3. Ensure the mod still loads with r2modman and your described test steps pass.
4. Open the PR; link any related issue.

Maintainers may request changes or handle versioning and Thunderstore releases.

## Releases (maintainers)

Releases use the GitHub Actions **Release** workflow with a semver tag (e.g. `0.2.1`). That updates `thunderstore.toml`, builds the package, and publishes to Thunderstore. README images under `./images/` are rewritten to GitHub raw URLs during the workflow—keep `images/icon.png` in sync with root `icon.png`.

## Questions

Open a [GitHub Discussion](https://github.com/MarcoAntolini/Fated-Encounters/discussions) if enabled, or an issue labeled as a question. For gameplay/mod-loader help, the community Discord is often faster.
