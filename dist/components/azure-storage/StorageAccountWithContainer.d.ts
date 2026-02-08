import * as pulumi from "@pulumi/pulumi";
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
    tags?: pulumi.Input<{
        [key: string]: pulumi.Input<string>;
    }>;
}
export declare class StorageAccountWithContainer extends pulumi.ComponentResource {
    readonly storageAccountName: pulumi.Output<string>;
    readonly storageAccountId: pulumi.Output<string>;
    readonly containerName: pulumi.Output<string>;
    readonly primaryBlobEndpoint: pulumi.Output<string>;
    constructor(name: string, args: StorageAccountWithContainerArgs, opts?: pulumi.ComponentResourceOptions);
}
//# sourceMappingURL=StorageAccountWithContainer.d.ts.map