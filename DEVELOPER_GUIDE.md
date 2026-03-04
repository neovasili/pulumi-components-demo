# Developer Guide

This document contains repository development and maintenance workflows.

## Prerequisites

- Pulumi CLI (`pulumi version`)
- Node.js 18+ and pnpm 10.28+
- Go 1.25+
- `jq`
- Azure credentials/CLI only if running Azure examples

## Local Setup

```bash
pnpm install
pnpm gen
```

`pnpm gen` runs build + schema generation + SDK generation + post-build steps.

## Build and Generation Commands

### Preferred (`pnpm` scripts)

```bash
pnpm build
pnpm gen:schema
pnpm gen:sdk:nodejs
pnpm gen:sdk:go
pnpm gen
```

Debug variants:

```bash
pnpm build:debug
pnpm gen:schema:debug
pnpm gen:sdk:debug
pnpm gen:debug
```

### Script-level commands

```bash
./scripts/build.sh
./scripts/generate_schema.sh
./scripts/generate_sdk.sh -l nodejs
./scripts/generate_sdk.sh -l go
./scripts/post_build.sh
```

`generate_sdk.sh` also works for other Pulumi languages (for example `-l python`, `-l dotnet`, `-l java`) if your release pipeline publishes those SDKs.

## Local Plugin Installation

For local testing as a Pulumi plugin:

```bash
pnpm local:install
```

This uses `scripts/local_install.sh` and installs from a local tarball.

Notes:
- default target platform is `darwin-arm64` in `scripts/local_install.sh`
- plugin tarballs for multiple platforms are built with:

```bash
bash scripts/build_plugin_tarballs.sh
```

## Running Examples

### Node.js example

```bash
cd examples/nodejs
pnpm install
pulumi stack init dev
pulumi config set azure-native:location eastus
pulumi preview
```

### Go example

```bash
cd examples/go
go mod download
pulumi stack init dev
pulumi config set azure-native:location eastus
pulumi preview
```

## Adding a New Component

1. Add a new TypeScript component under `components/<name>/`.
2. Export it from that component package `index.ts`.
3. Re-export it from root [`index.ts`](/Users/juan.manuel.ruiz/workspace/personal/pulumi-components-demo/index.ts).
4. Register it in [`plugin/provider.ts`](/Users/juan.manuel.ruiz/workspace/personal/pulumi-components-demo/plugin/provider.ts) `components: [...]`.
5. Run `pnpm gen` to regenerate schema + SDKs.
6. Verify generated SDK signatures and docs.
7. Validate with examples (at least one language before merge).

## Release Workflow

Release is automated by `.github/workflows/release.yml` + `semantic-release`:

1. semantic-release calculates version.
2. `scripts/prepare-release.mjs` updates versions and runs `pnpm gen`.
3. plugin tarballs are generated (`scripts/build_plugin_tarballs.sh`).
4. npm package is published from `sdk/nodejs`.
5. Go module tag is created and pushed with `scripts/tag_go_module.sh`.
6. GitHub release uploads plugin tarballs from `release-artifacts/`.

## Troubleshooting

### Schema generation fails

- Ensure provider compiles first: `pnpm build`
- Ensure Pulumi CLI is available: `pulumi version`
- Re-run with debug: `pnpm gen:schema:debug`

### SDK generation fails

- Ensure `schema/schema.json` exists and is valid JSON
- Re-run with debug: `./scripts/generate_sdk.sh -l nodejs -d`

### Plugin not found during preview/up

- Confirm plugin name/version match `PulumiPlugin.yaml`
- Confirm plugin executable exists: `bin/pulumi-resource-pulumi-components-demo`
- Reinstall plugin locally: `pnpm local:install`

### Node SDK package metadata looks wrong

- Re-run post build: `./scripts/post_build.sh`
- Check `sdk/nodejs/package.json` fields (`name`, `main`, `types`, `pulumi`)
