# Pulumi Components Demo

A Pulumi component resource package demonstrating how to build reusable infrastructure components in TypeScript with multi-language SDK generation.

## Table of Contents

- [Pulumi Components Demo](#pulumi-components-demo)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Components](#components)
    - [Azure Storage (`components-demo:index:StorageAccountWithContainer`)](#azure-storage-components-demoindexstorageaccountwithcontainer)
  - [Repository Structure](#repository-structure)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
    - [Option 1: Manual Setup with pnpm](#option-1-manual-setup-with-pnpm)
    - [Option 2: Manual Setup with Scripts](#option-2-manual-setup-with-scripts)
    - [What's Next?](#whats-next)
  - [Development Workflow](#development-workflow)
    - [Using pnpm Scripts (Recommended)](#using-pnpm-scripts-recommended)
    - [Using Build Scripts (Alternative)](#using-build-scripts-alternative)
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
    - [Key Files](#key-files)
  - [Architecture](#architecture)
    - [Build Process Flow](#build-process-flow)
    - [Component Resource Lifecycle](#component-resource-lifecycle)
  - [pnpm Workspace](#pnpm-workspace)
  - [Troubleshooting](#troubleshooting)
    - [SDK Generation Issues](#sdk-generation-issues)
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

### Azure Storage (`components-demo:index:StorageAccountWithContainer`)

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
├── PulumiPlugin.yaml            # Pulumi plugin metadata
├── package.json                 # Root package with build scripts
├── pnpm-workspace.yaml          # pnpm workspace configuration
├── tsconfig.json                # TypeScript configuration
├── index.ts                     # Provider entry point
├── components/
│   └── azure-storage/           # Azure Storage component
│       ├── package.json         # Component package definition
│       ├── index.ts             # Component exports
│       └── storageAccountWithContainer.ts  # Component implementation
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
    ├── setup.sh                 # Automated setup script
    ├── build.sh                 # Build the project
    ├── generate_schema.sh       # Generate Pulumi schema
    ├── generate_sdk.sh          # Generate SDK for specific language
    └── common.sh                # Shared utilities and color definitions
```

## Prerequisites

- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/) (v3.0+)
- Node.js 18+ and npm
- pnpm 10.28+ (automatically installed by setup script)
- Go 1.21+ (for Go SDK and Go examples)
- Azure CLI (for running examples)

## Quick Start

### Option 1: Manual Setup with pnpm

```bash
# 1. Install pnpm (if not already installed)
npm install -g pnpm

# 2. Install dependencies
pnpm install

# 3. Build and generate everything
pnpm gen
```

### Option 2: Manual Setup with Scripts

```bash
# 1. Install pnpm (if not already installed)
npm install -g pnpm

# 2. Install dependencies
pnpm install

# 3. Build the provider
./scripts/build.sh

# 4. Generate schema
./scripts/generate_schema.sh

# 5. Generate SDKs
./scripts/generate_sdk.sh -l nodejs
./scripts/generate_sdk.sh -l go
```

### What's Next?

After setup, you can:

1. **Explore the Component**:

   - Browse [components/azure-storage/storageAccountWithContainer.ts](components/azure-storage/storageAccountWithContainer.ts#L1)
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

# Clean build artifacts
pnpm clean

# Generate schema from provider
pnpm gen:schema

# Generate Node.js SDK only
pnpm gen:sdk:nodejs

# Generate Go SDK only
pnpm gen:sdk:go

# Generate all SDKs
pnpm gen:sdk

# Complete build: clean, build, schema, and SDKs
pnpm gen
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
```

**Build Script Features:**

- Colored terminal output for better visibility
- Debug mode with verbose logging (`-d` flag)
- Automatic cleanup of previous artifacts
- Error handling and validation

## Usage

### Node.js/TypeScript

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure-native";
import * as components from "@pulumi/components-demo";

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
  "github.com/neovasili/components-demo/sdk/go/componentsdemo/azure"
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
    storage, err := azure.NewStorageAccountWithContainer(ctx, "demo-storage", &azure.StorageAccountWithContainerArgs{
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
           super("components-demo:index:MyComponent", name, {}, opts);
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
| `pnpm build` | Compile TypeScript to JavaScript |
| `pnpm clean` | Remove build artifacts and SDKs |
| `pnpm gen:schema` | Generate Pulumi schema from provider |
| `pnpm gen:sdk:nodejs` | Generate Node.js/TypeScript SDK |
| `pnpm gen:sdk:go` | Generate Go SDK |
| `pnpm gen:sdk` | Generate all SDKs |
| `pnpm gen` | Full build: clean, compile, schema, and SDKs |

## Build Scripts Reference

| Script | Options | Description |
| -------- | --------- | ------------- |
| `./scripts/setup.sh` | - | Automated setup: install dependencies, build, generate SDKs |
| `./scripts/build.sh` | `-d` (debug) | Compile TypeScript provider and components |
| `./scripts/generate_schema.sh` | `-d` (debug) | Generate Pulumi package schema |
| `./scripts/generate_sdk.sh` | `-l <language>` `-d` (debug) | Generate SDK for specific language |

## Project Files

### Configuration Files

- **`PulumiPlugin.yaml`**: Defines the Pulumi plugin name, version, and runtime
- **`package.json`**: Root package configuration with scripts and dependencies
- **`pnpm-workspace.yaml`**: Defines workspace packages (`components/*`)
- **`tsconfig.json`**: TypeScript compiler configuration
- **`.gitignore`**: Git ignore patterns (node_modules, dist, bin, etc.)

### Key Files

- **`index.ts`**: Main entry point that exports all components
- **`schema/schema.json`**: Generated Pulumi schema for SDK generation
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
2. Provider Entry Point (index.ts)
         ↓
3. TypeScript Compilation (tsc → dist/)
         ↓
4. Schema Generation (pulumi package get-schema → schema/schema.json)
         ↓
5. SDK Generation (pulumi package gen-sdk)
         ↓
6. Language-specific SDKs (sdk/nodejs, sdk/go)
         ↓
7. Examples consume SDKs
```

### Component Resource Lifecycle

1. **Component Definition**: TypeScript class extends `pulumi.ComponentResource`
2. **Registration**: Component registered with unique type (e.g., `components-demo:index:StorageAccountWithContainer`)
3. **Schema Definition**: Input/output properties defined in schema.json
4. **SDK Generation**: Pulumi CLI generates type-safe bindings
5. **Usage**: Developers use generated SDKs in their infrastructure code

## pnpm Workspace

This monorepo uses pnpm workspaces as defined in [pnpm-workspace.yaml](pnpm-workspace.yaml#L1):

```yaml
packages:
  - "components/*"
  - "provider"
  # - "examples/*"  # Examples are kept separate
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
- Examples are intentionally excluded from workspace for realistic usage testing

## Troubleshooting

### SDK Generation Issues

If SDK generation fails:

1. Ensure the provider is built: `pnpm build` or `./scripts/build.sh`
2. Verify schema is valid: `cat schema/schema.json | jq .`
3. Check Pulumi CLI version: `pulumi version` (v3.0+ required)
4. Try debug mode: `./scripts/generate_sdk.sh -l nodejs -d`

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

## Local Development Tools

The `.dev/` directory contains utilities for local development:

- **`local_install_sdk.sh`**: Install SDKs locally for testing

  ```bash
  ./.dev/local_install_sdk.sh -l nodejs
  ./.dev/local_install_sdk.sh -l go
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
- **Go**: 1.21+ (for Go SDK)
- **TypeScript**: ^5.9.3

## License

Apache 2.0
