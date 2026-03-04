import { componentProviderHost } from "@pulumi/pulumi/provider/experimental";
import * as path from "path";

// IMPORTANT: ensure provider packages used by your components are loaded.
import "@pulumi/azure-native";

import { StorageAccountWithContainer } from "../components/azure-storage/StorageAccountWithContainer";

componentProviderHost({
  name: "pulumi-components-demo",
  // Point the analyzer at the package root that contains tsconfig + sources.
  dirname: path.resolve(__dirname, "..", ".."),
  components: [StorageAccountWithContainer],
});
