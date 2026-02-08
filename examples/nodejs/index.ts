import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure-native";
import * as components from "@neovasili/pulumi-components-demo";

// Create a resource group
const resourceGroup = new azure.resources.ResourceGroup("demo-rg", {
  location: "eastus",
});

// Create a storage account with container using the component
const storage = new components.StorageAccountWithContainer("neovasilidemo", {
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
