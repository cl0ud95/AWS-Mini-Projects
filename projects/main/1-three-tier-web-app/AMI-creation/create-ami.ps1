Write-Host "Creating AMI Security Group with Terraform"
Start-Job {Set-Location $Using:PSScriptRoot\terraform-VPC && terraform init && `
  terraform apply -auto-approve } `
  | Receive-Job -Wait -AutoRemoveJob

# Write output to pkrvars file
Start-Job {Set-Location $Using:PSScriptRoot\terraform-VPC && terraform output `
  | Set-Content -Path $Using:PSScriptRoot\packer\terraform.auto.pkrvars.hcl} `
  | Receive-Job -Wait -AutoRemoveJob

# Create AMI
Write-Host "Creating AMI with Packer"
Start-Job {Set-Location $Using:PSScriptRoot\packer && packer init . && packer build .} `
  | Receive-Job -Wait -AutoRemoveJob