import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure-native";

export interface StorageAccountWithContainerArgs {
  /**
   * The Azure resource group name where the storage account will be created
   */
  resourceGroupName: pulumi.Input<string>;

  /**
   * The Azure location for the storage account
   */
  location: pulumi.Input<string>;

  /**
   * The name of the blob container to create
   */
  containerName: pulumi.Input<string>;

  /**
   * The SKU for the storage account (defaults to Standard_LRS)
   */
  sku?: pulumi.Input<string>;

  /**
   * Tags to apply to the storage account
   */
  tags?: pulumi.Input<{ [key: string]: pulumi.Input<string> }>;
}

export class StorageAccountWithContainer extends pulumi.ComponentResource {
  public readonly storageAccountName: pulumi.Output<string>;
  public readonly storageAccountId: pulumi.Output<string>;
  public readonly containerName: pulumi.Output<string>;
  public readonly primaryBlobEndpoint: pulumi.Output<string>;

  constructor(
    name: string,
    args: StorageAccountWithContainerArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("pulumi-components-demo:index:StorageAccountWithContainer", name, {}, opts);

    // Create the storage account
    const storageAccount = new azure.storage.StorageAccount(
      `${name}-sa`,
      {
        accountName: name,
        resourceGroupName: args.resourceGroupName,
        location: args.location,
        sku: {
          name: args.sku || "Standard_LRS",
        },
        kind: "StorageV2",
        tags: args.tags,
      },
      { parent: this },
    );

    // Create the blob container
    const container = new azure.storage.BlobContainer(
      `${name}-container`,
      {
        resourceGroupName: args.resourceGroupName,
        accountName: storageAccount.name,
        containerName: args.containerName,
      },
      { parent: this },
    );

    // Set outputs
    this.storageAccountName = storageAccount.name;
    this.storageAccountId = storageAccount.id;
    this.containerName = container.name;
    this.primaryBlobEndpoint = storageAccount.primaryEndpoints.apply(
      (endpoints) => endpoints.blob,
    );

    this.registerOutputs({
      storageAccountName: this.storageAccountName,
      storageAccountId: this.storageAccountId,
      containerName: this.containerName,
      primaryBlobEndpoint: this.primaryBlobEndpoint,
    });
  }
}
