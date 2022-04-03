Running this module manually

1. Install Terraform and make sure it's on your PATH.
1. Run terraform init.
1. Run terraform apply.
1. When you're done, run terraform destroy.

Running automated tests against this module

1.    Install Terraform and make sure it's on your PATH.
1.    Install Golang and make sure this code is checked out into your GOPATH.
1.    cd test
1.    dep ensure
1.    go test -v -run TestTerraformBasicExample
