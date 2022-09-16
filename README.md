# TF_S3_Backend_bootStrapper
Terraform boilerplate code, to initialise an S3 backend in AWS and move local state, through terraform.

## Requirements
- An AWS account.
- Credentials to access said AWS account.

## Setup
Clone this repository, cd into it, run the following commands:

- `terraform init`
- `terraform apply`

That's it, you now have a terraform workspace with a backend in S3.

## Backend Properties
To get the name of the S3 bucket and the object that holds your state file, query the terraform outputs.
### Example:
`terraform output backend`

Should yield:

```
{
  "bucket" = "terraform-state-00000000000000000000000001"
  "key" = "terraform.tfstate"
}
```

## Revert back to local state. *repatriate*
To move the state back to your local environment, either run the included `repatriate.sh` script, or perform the following steps manually:
- `rm provider.tf`
- `mv temp_provider.bak temp_provider.tf`
- `terraform init -migrate-state`

## Caveats / Weirdness
Due to the fact that the terraform configuration file does the state migration itself using a `null_resource`, this `null_resource` is not yet stored in the state file when it is being migrated.

As a result, on the next `terraform apply` the state file which now lives in S3 will not have a record of the `null_resource` and will deem it nescesary to create it again.

This is not harmful, it will simply reinitialise and leave the state file where it is (in S3).

If this behaviour bothers you, run `terraform apply --auto-approve` twice when initializing this environment.
