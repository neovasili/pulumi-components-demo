module example

go 1.25

require (
	github.com/pulumi/pulumi-azure-native-sdk/resources/v2 v2.0.0
	github.com/pulumi/pulumi/sdk/v3 v3.0.0
	github.com/example/components-demo/sdk/go/componentsdemo v0.1.0
)

replace github.com/example/components-demo/sdk/go/componentsdemo => ../../sdk/go/componentsdemo
