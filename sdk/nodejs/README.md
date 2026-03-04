# Pulumi Components Demo

Pulumi component resources authored in TypeScript and distributed through generated SDKs for multiple Pulumi languages.

## Core Goal: Author in TypeScript, Distribute in Any Pulumi Language

This repository follows Pulumi's package model for *remote component resources*:
- implementation is written once in TypeScript
- a provider plugin hosts that implementation
- Pulumi schema is generated from the provider
- language SDKs are generated from the schema
- SDKs + provider plugin are published so consumers in each language can use the same components

### Quick Summary: What You Need

To build this kind of repository correctly, you need all of the following:
1. TypeScript `ComponentResource` implementations (the source of truth).
2. A provider host entrypoint that registers those components.
3. A `pulumi-resource-<package-name>` executable (provider binary wrapper).
4. `PulumiPlugin.yaml` metadata with matching name/version/runtime.
5. A generated Pulumi schema (`schema/schema.json`).
6. Generated language SDKs (`pulumi package gen-sdk`).
7. A release flow that publishes:
   - language SDK artifacts (npm, and optionally PyPI/NuGet/Maven/Go module tags)
   - provider plugin tarballs for supported OS/arch targets.

### Required Repository Structure (Detailed)

```text
.
├── components/                         # TypeScript component implementations
│   └── <component>/*.ts
├── plugin/provider.ts                  # Provider host: registers components with Pulumi
├── bin/pulumi-resource-pulumi-components-demo
│                                        # Executable Pulumi plugin entrypoint
├── PulumiPlugin.yaml                   # Plugin metadata (name/version/runtime)
├── index.ts                            # Exports public TS components
├── schema/schema.json                  # Generated package schema (do not hand-author)
├── sdk/
│   ├── nodejs/                         # Generated Node.js SDK
│   ├── go/                             # Generated Go SDK
│   └── <other-languages>/              # Optional: python, dotnet, java
├── dist/                               # Compiled JS for provider runtime
└── scripts/                            # Build/generation/release automation
```

Why this matters:
- `components/` is implementation.
- `plugin/provider.ts` makes components discoverable by Pulumi tooling.
- `schema/schema.json` is the language-neutral contract.
- `sdk/*` is generated, language-specific surface area.
- plugin executable + metadata are what Pulumi engine runs during deployments.

### Provider and Provider Binary: Why They Are Necessary

Pulumi deploys components through a provider plugin process. Even if components are "just TypeScript", non-Node consumers cannot execute your TypeScript directly.

In this repo:
- [`plugin/provider.ts`](/Users/juan.manuel.ruiz/workspace/personal/pulumi-components-demo/plugin/provider.ts) starts `componentProviderHost(...)` and registers component classes.
- [`bin/pulumi-resource-pulumi-components-demo`](/Users/juan.manuel.ruiz/workspace/personal/pulumi-components-demo/bin/pulumi-resource-pulumi-components-demo) is the executable Pulumi looks for (`pulumi-resource-<name>`). It resolves runtime files and `exec`s Node on `dist/plugin/provider.js`.
- [`PulumiPlugin.yaml`](/Users/juan.manuel.ruiz/workspace/personal/pulumi-components-demo/PulumiPlugin.yaml) declares plugin `name`, `version`, and `runtime`.

Without these pieces:
- `pulumi package get-schema` cannot introspect your components.
- deployments from generated SDKs (Go/Python/.NET/Java/etc.) cannot load the provider implementation.

### Schema Generation: Why It Is Necessary

Pulumi schema is the canonical API contract for your package:
- resource tokens (`pkg:index:Resource`)
- inputs/outputs
- types, descriptions, defaults, required fields
- language-specific generation hints

This repo generates schema with:
- `pulumi package get-schema . > schema/schema.json`
- then patches metadata like Go import paths and plugin download URL.

Why schema is mandatory:
- SDK generation depends on it.
- consistent cross-language behavior depends on it.
- plugin discovery/download metadata is carried through it.

If schema and implementation drift apart, generated SDKs become misleading or broken.

### SDK Generation: Why It Is Necessary

`pulumi package gen-sdk` transforms schema into idiomatic SDKs for each language. In this repo, scripts currently generate Node.js and Go SDKs; the same schema can generate other Pulumi-supported SDKs (Python/.NET/Java) when you add publish steps.

What generation gives you:
- language-native types and constructors
- compile-time validation in each ecosystem
- consistent resource token mapping to the same provider implementation

Important rule: treat `sdk/*` as generated artifacts. Regenerate from schema instead of hand-editing generated files.

### npm Package Release (Detailed)

For this repository, npm publication is done from the generated Node SDK (`sdk/nodejs`), not from the root workspace package.

Release flow in this repo:
1. `semantic-release` computes next version.
2. `scripts/prepare-release.mjs` updates versions and runs full generation (`pnpm gen`).
3. Node SDK metadata is patched in post-build to become publishable as `@neovasili/pulumi-components-demo`.
4. `npm publish` is run from `sdk/nodejs`.
5. Plugin tarballs are built and attached to GitHub release assets for Pulumi plugin installation.
6. Go module path version is tagged (`sdk/go/pulumicomponentsdemo/vX.Y.Z`) for Go consumers.

Why npm release still matters in a multi-language package:
- Node users consume directly from npm.
- versioning discipline for npm artifacts usually drives schema + plugin + SDK version alignment for every language.

### Additional Critical Requirements People Commonly Miss

1. **Strict name/version alignment**: keep package name and version synchronized across `package.json`, `PulumiPlugin.yaml`, schema, generated SDKs, and plugin tarball names.
2. **Stable token design**: once published, changing resource tokens is a breaking API change across all languages.
3. **Plugin distribution for non-Node languages**: generated SDKs must point to a reachable `pluginDownloadURL`/server so Pulumi can install the provider binary.
4. **Cross-platform plugin artifacts**: build provider tarballs per target OS/arch used by your consumers.
5. **Generated docs quality**: descriptions/JSDoc on component args and outputs directly shape generated SDK docs.
6. **Automated release**: generate schema/SDKs/plugins in CI to avoid local-machine drift.
7. **Language ecosystem publishing is separate**: SDK generation alone does not publish to PyPI/NuGet/Maven. Add explicit packaging/publish steps for each ecosystem you support.

## Component Included in This Repository

- `pulumi-components-demo:index:StorageAccountWithContainer`: creates an Azure Storage Account and Blob Container as a single reusable component.

## Repository Development

All contributor and maintenance workflows were moved to:
- [`DEVELOPER_GUIDE.md`](/Users/juan.manuel.ruiz/workspace/personal/pulumi-components-demo/DEVELOPER_GUIDE.md)

## References (Mandatory Read)

- Pulumi Components: https://www.pulumi.com/docs/iac/concepts/components/
- Pulumi Package Schema: https://www.pulumi.com/docs/iac/using-pulumi/pulumi-packages/schema/
- `pulumi package get-schema`: https://www.pulumi.com/docs/iac/cli/commands/pulumi_package_get-schema/
- `pulumi package gen-sdk`: https://www.pulumi.com/docs/iac/cli/commands/pulumi_package_gen-sdk/
- Pulumi Packages (overview): https://www.pulumi.com/docs/iac/guides/building-extending/packages/
- Authoring/Publishing Packages: https://www.pulumi.com/docs/iac/using-pulumi/extending-pulumi/publishing-packages/
- Pulumi Plugins (distribution/runtime concepts): https://www.pulumi.com/docs/iac/concepts/plugins/

## License

Apache 2.0
