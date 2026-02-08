# Pulumi Components Demo

A Pulumi component resource package demonstrating how to build reusable infrastructure components in TypeScript with multi-language SDK generation.

## Table of Contents

- [Pulumi Components Demo](#pulumi-components-demo)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Components](#components)
    - [Azure Storage (`pulumi-components-demo:index:StorageAccountWithContainer`)](#azure-storage-pulumi-components-demoindexstorageaccountwithcontainer)
  - [Repository Structure](#repository-structure)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
    - [Option 1: pnpm Workflow (Recommended)](#option-1-pnpm-workflow-recommended)
    - [Option 2: Scripted Workflow](#option-2-scripted-workflow)
    - [Option 3: Local Plugin Install](#option-3-local-plugin-install)
    - [What's Next?](#whats-next)
  - [Development Workflow](#development-workflow)
    - [Using pnpm Scripts (Recommended)](#using-pnpm-scripts-recommended)
    - [Using Build Scripts (Alternative)](#using-build-scripts-alternative)
    - [Post-build Steps](#post-build-steps)
  - [Usage](#usage)
    - [Node.js/TypeScript](#nodejstypescript)
    - [Go](#go)
  - [Running Examples](#running-examples)
    - [Node.js Example](#nodejs-example)
    - [Go Example](#go-example)
  - [Adding New Components](#adding-new-components)
  - [Package Scripts Reference](#package-scripts-reference)
  - [Build Scripts Reference](#build-scripts-reference)
  - [Project Files](#project-files)
    - [Configuration Files](#configuration-files)
    - [Runtime Files](#runtime-files)
    - [Generated Artifacts](#generated-artifacts)
  - [Architecture](#architecture)
    - [Build Process Flow](#build-process-flow)
    - [Component Resource Lifecycle](#component-resource-lifecycle)
  - [pnpm Workspace](#pnpm-workspace)
  - [Troubleshooting](#troubleshooting)
    - [SDK Generation Issues](#sdk-generation-issues)
    - [Local Plugin Install Issues](#local-plugin-install-issues)
    - [Build Errors](#build-errors)
    - [Example Not Finding SDK](#example-not-finding-sdk)
    - [Component Provider Not Found](#component-provider-not-found)
  - [Local Development Tools](#local-development-tools)
  - [Contributing](#contributing)
    - [Adding Components](#adding-components)
    - [Updating Schema](#updating-schema)
    - [Testing](#testing)
    - [Code Quality](#code-quality)
    - [Submitting Changes](#submitting-changes)
  - [Version Information](#version-information)
  - [License](#license)

## Overview

This repository demonstrates how to create Pulumi component resources that:

- Encapsulate infrastructure patterns as reusable components
- Generate SDKs for **Node.js/TypeScript** and **Go**
- Follow Pulumi best practices for component resource development
- Use pnpm workspace for efficient monorepo management

## Components

### Azure Storage (`pulumi-components-demo:index:StorageAccountWithContainer`)

A reusable component that creates an Azure Storage Account (StorageV2) with a Blob Container in a single resource.

**Input Properties:**

- `resourceGroupName` (required): Azure resource group name
- `location` (required): Azure region/location
- `containerName` (required): Name for the blob container
- `sku` (optional): Storage account SKU (default: `Standard_LRS`)
- `tags` (optional): Key-value tags for the storage account

**Output Properties:**

- `storageAccountName`: The generated storage account name
- `storageAccountId`: The Azure resource ID
- `containerName`: The created container name
- `primaryBlobEndpoint`: The primary blob storage endpoint URL

**Implementation Details:**

- Creates a StorageV2 account with configurable SKU
- Automatically provisions a blob container within the account
- All child resources are properly parented to the component
- Supports custom tagging for resource organization

## Repository Structure

```shell
.
├── .dev/                        # Local development scripts
│   ├── local_install.sh         # Install plugin into Pulumi cache (dev)
│   ├── local_install_sdk.sh     # Local SDK install helper (dev)
│   └── test.sh                  # Sanity checks for plugin install
├── bin/                         # Runtime binaries and install helpers
│   ├── postinstall.cjs          # Postinstall hook (links plugin into PULUMI_HOME)
│   └── pulumi-resource-pulumi-components-demo
├── plugin/
│   └── provider.ts              # Provider host entrypoint
├── PulumiPlugin.yaml            # Pulumi plugin metadata
├── go.mod                       # Go module for SDK post-build
├── package.json                 # Root package with build scripts
├── pnpm-workspace.yaml          # pnpm workspace configuration
├── tsconfig.json                # TypeScript configuration
├── index.ts                     # Provider entry point
├── components/
│   └── azure-storage/           # Azure Storage component
│       ├── package.json         # Component package definition
│       ├── index.ts             # Component exports
│       └── StorageAccountWithContainer.ts  # Component implementation
├── schema/
│   └── schema.json              # Pulumi package schema for SDK generation
├── sdk/                         # Auto-generated SDKs
│   ├── nodejs/                  # Node.js/TypeScript SDK
│   └── go/                      # Go SDK
├── examples/
│   ├── nodejs/                  # Node.js usage example
│   │   ├── index.ts
│   │   ├── package.json
│   │   ├── Pulumi.yaml
│   │   └── tsconfig.json
│   └── go/                      # Go usage example
│       ├── main.go
│       ├── go.mod
│       └── Pulumi.yaml
└── scripts/                     # Build automation scripts
    ├── build.sh                 # Build the project
    ├── generate_schema.sh       # Generate Pulumi schema
    ├── generate_sdk.sh          # Generate SDK for specific language
  ├── local_install.sh          # Create and install plugin tarball
  ├── post_build.sh             # Post-build steps for SDKs and plugin
  └── common.sh                # Shared utilities and color definitions
```

## Prerequisites

- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/) (v3.0+)
- Node.js 18+ and npm
- pnpm 10.28+
- Go 1.25+ (for Go SDK and Go examples)
- Azure CLI (for running examples)
- jq (required by local install scripts)

## Quick Start

### Option 1: pnpm Workflow (Recommended)

```bash
# 1. Install dependencies
pnpm install

# 2. Build and generate everything (includes post-build steps)
pnpm gen
```

During `pnpm install`, the postinstall hook links the plugin binary into `PULUMI_HOME/bin` for local usage.

### Option 2: Scripted Workflow

```bash
# 1. Install dependencies
pnpm install

# 2. Build the provider
./scripts/build.sh

# 3. Generate schema
./scripts/generate_schema.sh

# 4. Generate SDKs
./scripts/generate_sdk.sh -l nodejs
./scripts/generate_sdk.sh -l go

# 5. Run post-build steps (Go module, Node SDK build)
./scripts/post_build.sh
```

### Option 3: Local Plugin Install

If you want to test the provider as a local Pulumi plugin:

```bash
# Build everything first
pnpm gen

# Install plugin into Pulumi using a tarball (recommended)
pnpm local:install

# Alternative: direct install into Pulumi cache (dev)
./.dev/local_install.sh
```

Note: `./scripts/local_install.sh` targets `darwin-arm64` by default. Update `OS_ARCH` if you need a different platform.

### What's Next?

After setup, you can:

1. **Explore the Component**:

  - Browse [components/azure-storage/StorageAccountWithContainer.ts](components/azure-storage/StorageAccountWithContainer.ts#L1)
  - Review [schema/schema.json](schema/schema.json#L1) to see the generated schema

2. **Try an Example**:

   ```bash
   cd examples/nodejs
   pnpm install
   pulumi stack init dev
   pulumi config set azure-native:location eastus
   pulumi preview
   ```

3. **Use in Your Project**:

   - Copy the generated SDK from `sdk/nodejs` or `sdk/go`
   - Import and use the component in your infrastructure code

## Development Workflow

### Using pnpm Scripts (Recommended)

```bash
# Build all TypeScript files
pnpm build

# Build with debug logging
pnpm build:debug

# Clean build artifacts
pnpm clean

# Generate schema from provider
pnpm gen:schema

# Generate schema with debug logging
pnpm gen:schema:debug

# Generate Node.js SDK only
pnpm gen:sdk:nodejs

# Generate Go SDK only
pnpm gen:sdk:go

# Generate SDKs with debug logging
pnpm gen:sdk:debug

# Complete build: build, schema, SDKs, and post-build steps
pnpm gen

# Full debug pipeline
pnpm gen:debug

# Install local plugin via tarball
pnpm local:install
```

### Using Build Scripts (Alternative)

The `scripts/` directory contains individual bash scripts for more granular control:

```bash
# Build the provider
./scripts/build.sh

# Build with debug output
./scripts/build.sh -d

# Generate Pulumi schema
./scripts/generate_schema.sh

# Generate SDK for a specific language
./scripts/generate_sdk.sh -l nodejs
./scripts/generate_sdk.sh -l go

# Generate with debug output
./scripts/generate_sdk.sh -l nodejs -d

# Run post-build steps
./scripts/post_build.sh

# Install local plugin via tarball
./scripts/local_install.sh
```

**Build Script Features:**

- Colored terminal output for better visibility
- Debug mode with verbose logging (`-d` flag)
- Automatic cleanup of previous artifacts
- Error handling and validation

### Post-build Steps

The post-build script performs additional tasks needed for the SDKs and plugin runtime:

- Copies the root go.mod into sdk/go/pulumicomponentsdemo and updates the module path
- Runs go mod tidy for the Go SDK
- Patches Node SDK package.json main/types fields and builds the Node SDK
- Copies package.json into dist/plugin for runtime metadata

## Usage

### Node.js/TypeScript

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure-native";
import * as components from "@neovasili/pulumi-components-demo";

// Create a resource group
const resourceGroup = new azure.resources.ResourceGroup("demo-rg", {
  location: "eastus",
});

// Create a storage account with container using the component
const storage = new components.StorageAccountWithContainer("demo-storage", {
  resourceGroupName: resourceGroup.name,
  location: resourceGroup.location,
  containerName: "mycontainer",
  sku: "Standard_LRS",
  tags: {
    environment: "demo",
    purpose: "example",
  },
});

// Export the outputs
export const storageAccountName = storage.storageAccountName;
export const storageAccountId = storage.storageAccountId;
export const containerName = storage.containerName;
export const primaryBlobEndpoint = storage.primaryBlobEndpoint;
```

### Go

```go
package main

import (
  "github.com/neovasili/pulumi-components-demo/sdk/go/pulumicomponentsdemo"
  "github.com/pulumi/pulumi-azure-native-sdk/resources/v2"
  "github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
  pulumi.Run(func(ctx *pulumi.Context) error {
    // Create a resource group
    resourceGroup, err := resources.NewResourceGroup(ctx, "demo-rg", &resources.ResourceGroupArgs{
      Location: pulumi.String("eastus"),
    })
    if err != nil {
      return err
    }

    // Create storage with component
    storage, err := pulumicomponentsdemo.NewStorageAccountWithContainer(ctx, "demo-storage", &pulumicomponentsdemo.StorageAccountWithContainerArgs{
      ResourceGroupName: resourceGroup.Name,
      Location:          resourceGroup.Location,
      ContainerName:     pulumi.String("mycontainer"),
      Sku:               pulumi.String("Standard_LRS"),
      Tags: pulumi.StringMap{
        "environment": pulumi.String("demo"),
        "purpose":     pulumi.String("example"),
      },
    })
    if err != nil {
      return err
    }

    // Export outputs
    ctx.Export("storageAccountName", storage.StorageAccountName)
    ctx.Export("storageAccountId", storage.StorageAccountId)
    ctx.Export("containerName", storage.ContainerName)
    ctx.Export("primaryBlobEndpoint", storage.PrimaryBlobEndpoint)

    return nil
  })
}
```

## Running Examples

### Node.js Example

```bash
cd examples/nodejs
pnpm install
pulumi stack init dev
pulumi config set azure-native:location eastus
pulumi preview  # Preview changes
pulumi up       # Deploy infrastructure
```

### Go Example

```bash
cd examples/go
go mod download
pulumi stack init dev
pulumi config set azure-native:location eastus
pulumi preview  # Preview changes
pulumi up       # Deploy infrastructure
```

## Adding New Components

To add a new component to this package:

1. **Create the component directory:**

   ```bash
   mkdir -p components/my-component
   ```

2. **Add package.json:**

   ```json
   {
     "name": "@components-demo/my-component",
     "version": "0.1.0",
     "description": "My custom component",
     "main": "dist/index.js",
     "types": "dist/index.d.ts",
     "scripts": {
       "build": "tsc",
       "clean": "rm -rf dist/"
     },
     "dependencies": {
       "@pulumi/pulumi": "^3.0.0"
     },
     "devDependencies": {
       "@types/node": "^20.0.0",
       "typescript": "^5.0.0"
     }
   }
   ```

3. **Implement your component:**
   Create `components/my-component/myComponent.ts`:

   ```typescript
   import * as pulumi from "@pulumi/pulumi";

   export interface MyComponentArgs {
       // Define your component args
   }

   export class MyComponent extends pulumi.ComponentResource {
       constructor(name: string, args: MyComponentArgs, opts?: pulumi.ComponentResourceOptions) {
           super("pulumi-components-demo:index:MyComponent", name, {}, opts);
           // Implementation
           this.registerOutputs({});
       }
   }
   ```

4. **Export from component index.ts:**

   Create `components/my-component/index.ts`:

   ```typescript
   export { MyComponent, MyComponentArgs } from "./myComponent";
   ```

5. **Update root index.ts:**

   ```typescript
   export { MyComponent, MyComponentArgs } from "./components/my-component";
   ```

6. **Update schema.json:**

   Add your component's resource definition to `schema/schema.json`

7. **Rebuild and regenerate SDKs:**

   ```bash
   # Using pnpm (recommended)
   pnpm gen
   
   # Or using individual scripts
   ./scripts/build.sh
   ./scripts/generate_schema.sh
   ./scripts/generate_sdk.sh -l nodejs
   ./scripts/generate_sdk.sh -l go
   ```

## Package Scripts Reference

| Script | Description |
| -------- | ------------- |
| `pnpm build` | Build TypeScript provider and components |
| `pnpm build:debug` | Build with verbose output |
| `pnpm clean` | Remove build artifacts and SDKs |
| `pnpm gen:schema` | Generate Pulumi schema |
| `pnpm gen:schema:debug` | Generate schema with verbose output |
| `pnpm gen:sdk:nodejs` | Generate Node.js/TypeScript SDK |
| `pnpm gen:sdk:nodejs:debug` | Generate Node.js SDK with verbose output |
| `pnpm gen:sdk:go` | Generate Go SDK |
| `pnpm gen:sdk:go:debug` | Generate Go SDK with verbose output |
| `pnpm gen:sdk` | Generate all SDKs |
| `pnpm gen:sdk:debug` | Generate all SDKs with verbose output |
| `pnpm gen` | Build, generate schema/SDKs, and run post-build steps |
| `pnpm gen:debug` | Full debug pipeline |
| `pnpm local:install` | Install local plugin via tarball |
| `pnpm postbuild` | Lifecycle script: runs post-build steps |
| `pnpm postinstall` | Lifecycle script: links plugin binary into PULUMI_HOME |

## Build Scripts Reference

| Script | Options | Description |
| -------- | --------- | ------------- |
| `./scripts/build.sh` | `-d` (debug) | Compile TypeScript provider and components |
| `./scripts/generate_schema.sh` | `-d` (debug) | Generate Pulumi package schema |
| `./scripts/generate_sdk.sh` | `-l <language>` `-d` (debug) | Generate SDK for specific language |
| `./scripts/post_build.sh` | `-d` (debug) | Post-build steps for SDKs and plugin runtime |
| `./scripts/local_install.sh` | `-d` (debug) | Package and install local plugin via tarball |

## Project Files

### Configuration Files

- **`PulumiPlugin.yaml`**: Defines the Pulumi plugin name, version, and runtime
- **`package.json`**: Root package configuration with scripts and dependencies
- **`pnpm-workspace.yaml`**: Defines workspace packages (`components/**`, `examples/*`)
- **`tsconfig.json`**: TypeScript compiler configuration
- **`.gitignore`**: Git ignore patterns (node_modules, dist, bin, etc.)
- **`go.mod`**: Go module used during post-build for the SDK

### Runtime Files

- **`index.ts`**: Main entry point that exports all components
- **`schema/schema.json`**: Generated Pulumi schema for SDK generation
- **`plugin/provider.ts`**: Provider host that registers component resources
- **`bin/pulumi-resource-pulumi-components-demo`**: Plugin binary entrypoint
- **`bin/postinstall.cjs`**: Postinstall hook to link the plugin into PULUMI_HOME

### Generated Artifacts

- **`dist/`**: Compiled JavaScript output (generated by TypeScript)
- **`sdk/`**: Generated SDKs for different languages (auto-generated)

## Architecture

This project uses Pulumi's component resource model to create reusable infrastructure patterns:

- **Component Resources**: Encapsulate multiple cloud resources into logical units
- **Schema-based SDKs**: Auto-generate strongly-typed SDKs from JSON schema
- **Remote Components**: Components are invoked remotely via the Pulumi provider protocol
- **Multi-language Support**: Same component logic generates idiomatic SDKs for different languages

### Build Process Flow

```shell
1. TypeScript Components (components/azure-storage/*.ts)
         ↓
2. Provider Entry Point (index.ts + plugin/provider.ts)
         ↓
3. TypeScript Compilation (tsc → dist/)
         ↓
4. Schema Generation (pulumi package get-schema → schema/schema.json)
         ↓
5. SDK Generation (pulumi package gen-sdk)
         ↓
6. Post-build Steps (go.mod patching, Node SDK build)
         ↓
7. Language-specific SDKs (sdk/nodejs, sdk/go)
         ↓
8. Examples consume SDKs
```

### Component Resource Lifecycle

1. **Component Definition**: TypeScript class extends `pulumi.ComponentResource`
2. **Registration**: Component registered with unique type (e.g., `pulumi-components-demo:index:StorageAccountWithContainer`)
3. **Schema Definition**: Input/output properties defined in schema.json
4. **SDK Generation**: Pulumi CLI generates type-safe bindings
5. **Usage**: Developers use generated SDKs in their infrastructure code

## pnpm Workspace

This monorepo uses pnpm workspaces as defined in [pnpm-workspace.yaml](pnpm-workspace.yaml#L1):

```yaml
packages:
  - "components/**"
  - "examples/*"
```

**Benefits:**

- **Shared dependencies**: Common packages deduplicated across workspace
- **Workspace protocol**: Components can reference each other using `workspace:*`
- **Efficient installations**: pnpm's content-addressable storage saves disk space
- **Isolated component packages**: Each component maintains its own package.json
- **Fast operations**: Shared node_modules with symlinks

**Workspace Structure:**

- Each component in `components/` is a separate pnpm workspace package
- Components can have independent versions and dependencies
- Examples are included as workspace packages for easier local testing

## Troubleshooting

### SDK Generation Issues

If SDK generation fails:

1. Ensure the provider is built: `pnpm build` or `./scripts/build.sh`
2. Verify schema is valid: `cat schema/schema.json | jq .`
3. Check Pulumi CLI version: `pulumi version` (v3.0+ required)
4. Try debug mode: `./scripts/generate_sdk.sh -l nodejs -d`

### Local Plugin Install Issues

If `pulumi plugin install` or local installation fails:

1. Ensure build artifacts exist: `pnpm gen`
2. Verify the tarball exists: `/tmp/pulumi-resource-pulumi-components-demo-v0.1.0-darwin-arm64.tar.gz`
3. Check Pulumi plugin list: `pulumi plugin ls`
4. Re-run the installer: `pnpm local:install`

### Build Errors

```bash
# Clean everything and rebuild
pnpm clean
pnpm build

# Or use scripts
./scripts/build.sh -d
```

### Example Not Finding SDK

For Node.js examples:

```bash
cd examples/nodejs
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

For Go examples:

```bash
cd examples/go
go mod tidy
go mod download
```

### Component Provider Not Found

If Pulumi can't find the component provider:

1. Verify `PulumiPlugin.yaml` exists in the root
2. Check that `dist/` folder contains compiled JavaScript
3. Ensure the package is properly built: `pnpm build`
4. Verify the binary is present: `bin/pulumi-resource-pulumi-components-demo`
5. Run `pnpm install` to trigger the postinstall hook that links the binary into `PULUMI_HOME`

## Local Development Tools

The `.dev/` directory contains utilities for local development:

- **`local_install.sh`**: Install plugin into Pulumi cache (dev)
- **`local_install_sdk.sh`**: Install SDKs locally for testing
- **`test.sh`**: Verify plugin is installed in Pulumi

  ```bash
  ./.dev/local_install.sh
  ./.dev/local_install_sdk.sh -l nodejs
  ./.dev/local_install_sdk.sh -l go
  ./.dev/test.sh
  ```

You can also install the plugin via the scripted tarball approach:

```bash
./scripts/local_install.sh
```

## Contributing

Contributions are welcome! Please follow these guidelines:

### Adding Components

1. Create a new component directory under `components/`
2. Follow the existing component structure (package.json, index.ts, component implementation)
3. Implement component by extending `pulumi.ComponentResource`
4. Use proper TypeScript types for input/output properties
5. Register outputs using `this.registerOutputs()`

### Updating Schema

1. Add resource definitions to `schema/schema.json`
2. Include all input properties with descriptions
3. Mark required inputs in `requiredInputs` array
4. Set `isComponent: true` for component resources

### Testing

1. Add examples in `examples/` for each new component
2. Test with both Node.js and Go examples
3. Verify SDK generation works for all languages
4. Ensure examples can successfully preview/deploy

### Code Quality

- Follow existing TypeScript code style
- Add JSDoc comments for public APIs
- Use consistent naming conventions
- Keep components focused and single-purpose

### Submitting Changes

1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commit messages
4. Run `pnpm gen` to rebuild everything
5. Test examples to ensure they work
6. Submit a pull request

## Version Information

- **Package Version**: 0.1.0
- **Pulumi Version**: ^3.219.0 (minimum)
- **Node.js**: 18+ required
- **pnpm**: 10.28.0+
- **Go**: 1.25+ (for Go SDK)
- **TypeScript**: ^5.9.3

## License

Apache 2.0
