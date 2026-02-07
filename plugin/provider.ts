import { componentProviderHost } from "@pulumi/pulumi/provider/experimental";

// plugin/provider.ts
// process.stdout.write(`PULUMI_ENGINE=${String(process.env.PULUMI_ENGINE)}\n`);
// process.stdout.write(`PULUMI_MONITOR=${String(process.env.PULUMI_MONITOR)}\n`);
// process.stdout.write(`PULUMI_PROJECT=${String(process.env.PULUMI_PROJECT)}\n`);
// process.stdout.write(`PULUMI_STACK=${String(process.env.PULUMI_STACK)}\n`);

// IMPORTANT: ensure provider packages used by your components are loaded.
import "@pulumi/azure-native";

import { StorageAccountWithContainer } from "../components/azure-storage/StorageAccountWithContainer";

componentProviderHost({
  name: "pulumi-components-demo",
  components: [StorageAccountWithContainer],
});
