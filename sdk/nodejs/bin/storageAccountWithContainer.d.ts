import * as pulumi from "@pulumi/pulumi";
export declare class StorageAccountWithContainer extends pulumi.ComponentResource {
    /**
     * Returns true if the given object is an instance of StorageAccountWithContainer.  This is designed to work even
     * when multiple copies of the Pulumi SDK have been loaded into the same process.
     */
    static isInstance(obj: any): obj is StorageAccountWithContainer;
    readonly containerName: pulumi.Output<string>;
    readonly primaryBlobEndpoint: pulumi.Output<string>;
    readonly storageAccountId: pulumi.Output<string>;
    readonly storageAccountName: pulumi.Output<string>;
    /**
     * Create a StorageAccountWithContainer resource with the given unique name, arguments, and options.
     *
     * @param name The _unique_ name of the resource.
     * @param args The arguments to use to populate this resource's properties.
     * @param opts A bag of options that control this resource's behavior.
     */
    constructor(name: string, args: StorageAccountWithContainerArgs, opts?: pulumi.ComponentResourceOptions);
}
/**
 * The set of arguments for constructing a StorageAccountWithContainer resource.
 */
export interface StorageAccountWithContainerArgs {
    /**
     * The name of the blob container to create
     */
    containerName: pulumi.Input<string>;
    /**
     * The Azure location for the storage account
     */
    location: pulumi.Input<string>;
    /**
     * The Azure resource group name where the storage account will be created
     */
    resourceGroupName: pulumi.Input<string>;
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
