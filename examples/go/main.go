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

		// Create a storage account with container using the component
		storage, err := pulumicomponentsdemo.NewStorageAccountWithContainer(ctx, "neovasilidemo", &pulumicomponentsdemo.StorageAccountWithContainerArgs{
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

		// Export the outputs
		ctx.Export("storageAccountName", storage.StorageAccountName)
		ctx.Export("storageAccountId", storage.StorageAccountId)
		ctx.Export("containerName", storage.ContainerName)
		ctx.Export("primaryBlobEndpoint", storage.PrimaryBlobEndpoint)

		return nil
	})
}
