# Validation Errors And Fixes

This document captures the key Terraform issues discovered while validating the project and the fixes that made the configuration pass validation in `environments/localstack`.

## Final Validation Result

Command:

```bash
cd environments/localstack
../../venv/bin/tflocal validate
```

Result:

```text
Success! The configuration is valid.
```

Important distinction:

- Terraform validation is green
- Cloud WAN runtime apply is disabled by default for LocalStack

## Issues We Hit

### 1. Missing child module provider declarations

Problem:

- child modules were being passed provider mappings without clearly declaring their provider requirements
- the Cloud WAN wrapper also needed aliased provider support

Fix:

- added explicit `required_providers` declarations to the root and child modules
- added `configuration_aliases` for the Cloud WAN wrapper

Files involved:

- [`terraform.tf`](/home/jabu/Documents/localstack-lab/environments/localstack/terraform.tf)
- [`modules/cloudwan/terraform.tf`](/home/jabu/Documents/localstack-lab/modules/cloudwan/terraform.tf)

### 2. Invalid provider alias reference in Cloud WAN

Problem:

- the wrapper module referenced `aws.global`, but no such provider alias existed in the project

Fix:

- switched the wrapper to use the default `aws` provider
- passed `aws`, `aws.eu`, and `aws.asia` from the root module

Files involved:

- [`modules/cloudwan/main.tf`](/home/jabu/Documents/localstack-lab/modules/cloudwan/main.tf)
- [`main.tf`](/home/jabu/Documents/localstack-lab/environments/localstack/main.tf)

### 3. Root module referenced outputs that did not exist

Problem:

- the root Cloud WAN call expected VPC ARNs and private subnet ARNs, but the VPC module did not export them

Fix:

- added `vpc_arn`
- added `private_subnet_arns`
- updated the root module to consume `module.<name>.vpc_arn` and `module.<name>.private_subnet_arns`

Files involved:

- [`modules/vpc/outputs.tf`](/home/jabu/Documents/localstack-lab/modules/vpc/outputs.tf)
- [`main.tf`](/home/jabu/Documents/localstack-lab/environments/localstack/main.tf)

### 4. Wrong variable names in Cloud WAN attachments

Problem:

- the Asia attachment used `ap_vpc_arn` and `ap_private_subnet_arns`, but the module variables were named `asia_vpc_arn` and `asia_private_subnet_arns`

Fix:

- aligned the attachment resource with the declared variable names

File involved:

- [`modules/cloudwan/attachments.tf`](/home/jabu/Documents/localstack-lab/modules/cloudwan/attachments.tf)

### 5. Unsupported attribute errors from upstream Cloud WAN module outputs

Problem:

- the upstream `aws-ia/cloudwan/aws` module exposes `core_network` and `global_network` as objects
- this project was trying to access flat attributes like:
  - `module.cloudwan.core_network_id`
  - `module.cloudwan.core_network_arn`
  - `module.cloudwan.global_network_id`

Fix:

- updated references to use:
  - `module.cloudwan.core_network.id`
  - `module.cloudwan.core_network.arn`
  - `module.cloudwan.global_network.id`

Files involved:

- [`modules/cloudwan/outputs.tf`](/home/jabu/Documents/localstack-lab/modules/cloudwan/outputs.tf)
- [`modules/cloudwan/attachments.tf`](/home/jabu/Documents/localstack-lab/modules/cloudwan/attachments.tf)

### 6. Root module warning about undefined provider reference

Problem:

- Terraform warned that the root module had no explicit declaration for the local provider name `aws`

Fix:

- added a root `terraform` block with `required_providers`

File involved:

- [`terraform.tf`](/home/jabu/Documents/localstack-lab/environments/localstack/terraform.tf)

## Environment Note

One validation failure was not a Terraform configuration bug.

Inside the sandboxed environment, provider plugins failed with:

```text
listen unix /tmp/plugin...: setsockopt: operation not permitted
```

That was caused by the execution sandbox blocking the provider plugin socket setup, not by invalid Terraform code. Running validation with the needed permissions confirmed the configuration itself was valid.

## Runtime Support Note

After validation passed, applying the Cloud WAN resources still failed at runtime with:

```text
CreateGlobalNetwork ... 403 UnrecognizedClientException: The security token included in the request is invalid
```

This happened on the upstream module resource:

- `aws_networkmanager_global_network.global_network`

Interpretation:

- the Terraform code was valid
- but the target LocalStack environment did not successfully emulate the Network Manager / Cloud WAN runtime path for this project

Project decision:

- Cloud WAN is now disabled by default with `var.enable_cloudwan = false`
- LocalStack runs focus on the VPC, security group, and EC2 portions of the lab
- Cloud WAN should be enabled only when targeting an environment that supports it

Relevant references:

- LocalStack coverage index: https://docs.localstack.cloud/references/coverage/
- LocalStack regions coverage: https://docs.localstack.cloud/references/regions-coverage/
