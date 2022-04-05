package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func TestTerraformBasicExample(t *testing.T) {
	t.Parallel()

	expectedStackName := "test"
	// expectedList := []string{expectedStackName}
	expectedTags := map[string]string{"env": "gotest"}
	expectedLocation := "centralus"
	expectedInstanceCount := 1

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/basic-example",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"stack_name":  expectedStackName,
			"location":    expectedLocation,
			"vminstances": expectedInstanceCount,
			"tags":        expectedTags,

			// We also can see how lists and maps translate between terratest and terraform.
			// "example_list": expectedList,
		},

		// Variables to pass to our Terraform code using -var-file options
		//VarFiles: []string{"varfile.tfvars"},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	})

	fmt.Printf("Env: %v\n", terraformOptions.EnvVars)

	// website::tag::4::Clean up resources with "terraform destroy". Using "defer" runs the command at the end of the test, whether the test succeeds or fails.
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2::Run "terraform init" and "terraform apply".
	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	actualJumpboxPublicIp := terraform.Output(t, terraformOptions, "jumpbox_public_ip")
	// actualStackName := terraform.Output(t, terraformOptions, "stack_name")
	// actualLocation := terraform.Output(t, terraformOptions, "location")
	// actualInstanceCount := terraform.Output(t, terraformOptions, "vminstances")
	// actualList := terraform.OutputList(t, terraformOptions, "example_list")
	// actualTags := terraform.OutputMap(t, terraformOptions, "tags")

	// website::tag::3::Check the output against expected values.
	// Verify we're getting back the outputs we expect
	assert.NotEmpty(t, actualJumpboxPublicIp)
	// assert.Equal(t, expectedStackName, actualStackName)
	// assert.Equal(t, expectedLocation, actualLocation)
	// assert.Equal(t, expectedInstanceCount, actualInstanceCount)
	// assert.Equal(t, expectedTags, actualTags)
	// assert.Equal(t, expectedList, actualList)
}
