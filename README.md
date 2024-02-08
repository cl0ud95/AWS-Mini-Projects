# Terraform Mini Projects
---
- Mini projects created in AWS using Terraform
	- 1: Bootstrapping the remote backend to AWS S3 bucket
	- 2: Creating a generic VPC network with 1 subnet and 1 internet gateway
	- 3: Website hosting using S3 and CloudFront
	- 4: Serverless API solution
- Backend configuration is stored in the env folder
  
## Requirements
---
- AWS account with relevant permissions
- AWS CLI [installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Terraform [installed](https://developer.hashicorp.com/terraform/install?product_intent=terraform)

## Instructions
---
- `git clone` repo
- Project 1:
	- Add your backend bucket name and state file name to the variables.
	- Run `terraform init` and `terraform apply` to create the backend.
	- After the backend has been created, modify the backend file in the env folder
	- Add `backend "s3" {}` to the terraform block to access the backend.
	- Re-initialize terraform with `terraform init -backend-config={backend_file_path}`
- Project 2:
	- Uses backend config in project 1
	- Modify the variables for the VPC to your desired values
	- Run `terraform init` and `terraform apply`
- Project 3:
	- Uses backend config in project 1
	- Add your domain name to the `domain_name` variable
	- Select whether you want CloudFront deployment by setting the `CloudFront_deployment` variable to `true` or `false`.
	- Run `terraform init` and `terraform apply`
- Project 4:
	- Uses backend config in project 1
	- Add the DynamoDB name and Lambda Function name to the variables
	- Run `terraform init` and `terraform apply`
	- Follow the tutorial by [Saha Rajdeep](https://github.com/saha-rajdeep/serverless-lab) to test the API using Postman


