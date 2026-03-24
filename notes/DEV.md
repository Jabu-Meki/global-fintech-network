# LocalStack Terraform Lab Developer Notes

This file is intentionally local-only and excluded from Git.

Its job is simple:

- explain this project from absolute beginner level
- show how the pieces fit together
- make it easy to rebuild the lab from scratch
- capture what broke, why it broke, and how we fixed it
- give a path from simple concepts to more advanced Terraform architecture

If GitHub docs are the polished front door, this file is the workshop manual.

---

## 1. What this project is

This repository is a Terraform learning lab that models a multi-region AWS-style architecture using:

- a root Terraform configuration
- reusable child modules
- multiple AWS provider configurations
- LocalStack for local emulation
- an optional Cloud WAN design layer

It is meant for:

- architecture learning
- Terraform practice
- module design practice
- understanding multi-region composition

It is not meant for:

- packet flow validation
- production readiness claims
- certified network behavior testing

Important reminder:

- no packet flow tests were performed
- Cloud WAN is modeled for architecture learning, not validated routing behavior

---

## 2. Current project state

The configuration currently validates successfully with:

```bash
cd environments/localstack
../../venv/bin/tflocal validate
```

Cloud WAN is disabled by default:

```hcl
enable_cloudwan = false
```

That is intentional because the Terraform configuration is valid, but LocalStack runtime support for Network Manager / Cloud WAN is not reliable for this lab.

---

## 3. The simplest possible mental model

If you are brand new, think of the project like this:

1. The root module is the conductor.
2. The child modules are specialists.
3. Providers decide where resources get created.
4. Variables are inputs.
5. Outputs are return values.

In plain language:

- the root module tells Terraform what big pieces to create
- the VPC module creates networks
- the security group module creates access boundaries
- the EC2 module creates instances
- the Cloud WAN module optionally connects regions conceptually

---

## 4. Build it from simple to advanced

This is the order you should understand the repo in.

### Level 1: Single resource thinking

Start by understanding one Terraform resource.

Example idea:

- one `aws_vpc`
- one `aws_subnet`
- one `aws_instance`

At this stage, learn:

- resource blocks
- arguments
- references
- `terraform fmt`
- `terraform validate`

The key thought:

- Terraform is just a graph of resources and dependencies

### Level 2: Single module thinking

Once one resource makes sense, move to one module.

A module is just a folder with Terraform files that does one job.

Example in this repo:

- `modules/vpc`

At this stage, learn:

- `variables.tf`
- `main.tf`
- `outputs.tf`

The key thought:

- a module is like a function
- variables are inputs
- outputs are return values

### Level 3: Root module orchestration

Now understand how the root stack `environments/localstack/main.tf` calls modules.

The root module:

- creates a US VPC
- creates US security groups
- creates US instances
- repeats that pattern for Europe and Asia

The key thought:

- the root module composes smaller modules into a system

### Level 4: Multi-region provider thinking

This is where Terraform becomes more architectural.

Instead of one AWS provider, we use:

- default `aws` for `us-east-1`
- `aws.eu` for `eu-west-1`
- `aws.asia` for `ap-southeast-1`

The key thought:

- providers control execution context
- resources do not usually choose region themselves

### Level 5: Module contracts

Now focus on outputs and references.

Examples:

- the VPC module outputs `vpc_id`
- the security group module consumes `vpc_id`
- the VPC module outputs subnet IDs
- the EC2 module consumes subnet IDs

The key thought:

- module naming must be exact
- outputs are contracts

### Level 6: Optional architecture layers

Finally, understand the optional Cloud WAN layer.

This is more advanced because it adds:

- wrapper modules
- upstream module behavior
- aliased providers
- object outputs from third-party modules
- runtime support differences between LocalStack and AWS

The key thought:

- valid Terraform does not always mean supported runtime behavior

---

## 5. Repository walkthrough

### Root stack files

The runnable Terraform root is grouped under:

- `environments/localstack`

#### `environments/localstack/main.tf`

This is the orchestration layer.

It calls:

- `module "us_vpc"`
- `module "us_security_groups"`
- `module "us_public_instance"`
- `module "us_private_instance"`
- `module "eu_vpc"`
- `module "eu_security_groups"`
- `module "eu_public_instance"`
- `module "asia_vpc"`
- `module "asia_security_groups"`
- `module "asia_public_instance"`
- `module "cloudwan"` optionally

#### `environments/localstack/providers.tf`

This defines the provider configurations:

- default AWS provider
- Europe alias
- Asia alias

This file answers the question:

- where should Terraform try to create resources?

#### `environments/localstack/terraform.tf`

This defines required providers for the root module.

It answers the question:

- what providers does this configuration depend on?

#### `environments/localstack/variables.tf`

Right now the main root variable is:

- `enable_cloudwan`

This controls whether the optional Cloud WAN path is enabled.

#### `environments/localstack/outputs.tf`

This is the main root output file.

It exposes:

- `us_region`
- `eu_region`
- `asia_region`
- `cloudwan`

This makes the final infrastructure easier to inspect from the root level.

---

## 6. Child modules explained

### `modules/vpc`

Purpose:

- create a VPC
- create public subnets
- create private subnets
- create an internet gateway
- create route tables and associations

Inputs:

- region
- name_prefix
- vpc_cidr
- public subnet CIDRs
- private subnet CIDRs
- availability zones

Important outputs:

- `vpc_id`
- `vpc_arn`
- `public_subnet_ids`
- `private_subnet_ids`
- `private_subnet_arns`

Beginner takeaway:

- this module defines the network foundation

### `modules/security_groups`

Purpose:

- create a public security group
- create a private security group
- allow SSH and HTTP on the public side
- allow SSH from the public security group to the private one

Important outputs:

- `public_sg_id`
- `private_sg_id`

Beginner takeaway:

- this module defines who can talk to what

### `modules/ec2`

Purpose:

- create one EC2 instance per module call

Key design choice:

- use a fixed LocalStack-safe placeholder AMI by default

Default:

- `ami-12345678`

Beginner takeaway:

- this module is intentionally simple
- simple is good for labs

### `modules/cloudwan`

Purpose:

- wrap the upstream `aws-ia/cloudwan/aws` module
- build a core network policy document
- attach regional VPCs to Cloud WAN

Important reality:

- this is architecturally interesting
- but runtime support is not the same as AWS in LocalStack

Beginner takeaway:

- third-party modules can be very useful
- but you must learn their outputs, provider requirements, and runtime assumptions

---

## 7. How to build this project from scratch

If you wanted to recreate this repo step by step, do it in this order.

### Stage 1: Start with one region

Build only US first:

1. Create the AWS provider.
2. Create a VPC module.
3. Create public/private subnets.
4. Create security groups.
5. Create one EC2 instance.
6. Validate.

Do not start with three regions.

Why:

- one-region success is easier to debug

### Stage 2: Turn repeated infrastructure into modules

Once the US region works:

1. move the VPC resources into `modules/vpc`
2. move the security groups into `modules/security_groups`
3. move instance logic into `modules/ec2`

Then connect them with:

- variables
- outputs

### Stage 3: Add a second provider alias

Once one region works cleanly:

1. keep default `aws` for US
2. add `aws.eu`
3. pass `aws.eu` into EU modules

Only after that:

1. add Asia

### Stage 4: Add root outputs

Once infrastructure works:

1. expose the useful pieces
2. group them into clean root outputs

This makes learning and inspection easier.

### Stage 5: Add Cloud WAN only after the basics are stable

Cloud WAN should come last.

Why:

- it introduces upstream modules
- aliased providers
- runtime differences
- more complex references

If the base network is not clean first, Cloud WAN becomes noisy and confusing.

---

## 8. What each Terraform concept means in this repo

### Providers

Providers are plugins that let Terraform talk to an API.

In this repo:

- provider `aws` is default
- provider `aws.eu` is the EU alias
- provider `aws.asia` is the Asia alias

Think:

- provider = region + credentials + endpoint behavior

### Variables

Variables are inputs to modules.

Examples:

- VPC CIDR
- subnet CIDRs
- VPC ID
- AMI ID
- `enable_cloudwan`

Think:

- variables = knobs and inputs

### Outputs

Outputs expose useful values.

Examples:

- `vpc_id`
- `public_subnet_ids`
- `instance_id`
- `core_network_id`

Think:

- outputs = return values

### Module references

When you see:

```hcl
module.us_vpc.vpc_id
```

read it as:

- ask the `us_vpc` module for its exported `vpc_id`

### Provider mappings

When you see:

```hcl
providers = {
  aws = aws.eu
}
```

read it as:

- run this module using the EU provider instance

---

## 9. Troubleshooting guide

Use this order every time.

### Step 1: Format everything

```bash
terraform fmt -recursive
```

Why:

- messy formatting hides mistakes

### Step 2: Validate

```bash
cd environments/localstack
../../venv/bin/tflocal validate
```

Why:

- catches broken references, wrong attributes, missing providers, and invalid expressions

### Step 3: Read the exact failing object

If Terraform says:

```text
module.cloudwan is object with no attribute ...
```

that means:

- the thing you are referencing does not exist with that name

Do not guess.

Open:

- the child module outputs
- upstream module outputs
- the exact file and line Terraform mentioned

### Step 4: Check whether the error is config or runtime

Config errors:

- unsupported attribute
- missing variable
- wrong output name
- wrong provider alias

Runtime errors:

- authentication failure
- unsupported service behavior
- endpoint problems
- provider startup issues

This distinction matters a lot.

### Step 5: Simplify before adding more

If something advanced breaks:

- disable the advanced piece
- get the base lab healthy first
- reintroduce complexity later

---

## 10. Exact problems we hit in this repo

This section is important because it teaches real Terraform debugging.

### Problem 1: Missing provider module wiring

We had module/provider confusion because child modules were not declaring provider requirements clearly enough.

Fix:

- add `required_providers`
- add alias declarations where needed

Lesson:

- provider requirements are part of a module contract

### Problem 2: Bad alias reference

We referenced:

```hcl
aws.global
```

But no provider alias named `global` existed.

Fix:

- use the default `aws` provider in the Cloud WAN wrapper

Lesson:

- provider alias names must actually exist

### Problem 3: Root expected outputs that did not exist

The Cloud WAN root call needed:

- VPC ARNs
- private subnet ARNs

But the VPC module did not export them yet.

Fix:

- add `vpc_arn`
- add `private_subnet_arns`

Lesson:

- if a module consumes something, another module must explicitly expose it

### Problem 4: Upstream module outputs were objects, not flat fields

We assumed things like:

```hcl
module.cloudwan.global_network_id
```

But the upstream module actually exposed:

```hcl
module.cloudwan.global_network.id
```

Fix:

- switch to object field access

Lesson:

- always inspect third-party module outputs directly

### Problem 5: Sandbox plugin failure

We saw:

```text
listen unix /tmp/plugin...: setsockopt: operation not permitted
```

Fix:

- run validation outside the restrictive sandbox

Lesson:

- not every error is a Terraform design error
- sometimes the execution environment is the problem

### Problem 6: Cloud WAN runtime failure in LocalStack

We saw:

```text
CreateGlobalNetwork ... UnrecognizedClientException ...
```

Fix:

- make Cloud WAN optional
- set `enable_cloudwan = false`

Lesson:

- valid Terraform can still hit unsupported runtime behavior

---

## 11. Why Cloud WAN is disabled by default

This is a very important architectural decision in the repo.

Terraform validation:

- yes, it works

LocalStack runtime support for this Cloud WAN path:

- not dependable for this lab

So the right decision was:

- keep the architecture modeled
- keep the module available
- disable it by default for LocalStack

This is a mature engineering pattern:

- do not pretend unsupported runtime paths are production-safe
- document the limitation
- make advanced features opt-in

---

## 12. Simple-to-advanced learning roadmap

If I were teaching someone with this repo, I would use this exact progression.

### Phase 1: Terraform basics

Learn:

- resource blocks
- variables
- outputs
- references
- `terraform fmt`
- `terraform validate`

### Phase 2: Module basics

Learn:

- child modules
- module inputs
- module outputs
- reusability

### Phase 3: Root orchestration

Learn:

- how modules connect
- dependency flow
- composing systems out of smaller units

### Phase 4: Multi-region patterns

Learn:

- provider aliases
- `providers = { ... }`
- region-specific module execution

### Phase 5: Real debugging

Learn:

- reading Terraform errors carefully
- tracing outputs
- inspecting child module interfaces
- distinguishing syntax issues from runtime issues

### Phase 6: Advanced architecture wrappers

Learn:

- wrapping upstream modules
- translating third-party outputs
- making advanced features optional
- documenting limitations honestly

---

## 13. Commands you will actually use

### Format

```bash
terraform fmt -recursive
```

### Validate

```bash
cd environments/localstack
../../venv/bin/tflocal validate
```

### Plan

```bash
cd environments/localstack
../../venv/bin/tflocal plan
```

### Apply

```bash
cd environments/localstack
../../venv/bin/tflocal apply
```

### Enable Cloud WAN explicitly

Only do this when targeting an environment that really supports it:

```bash
cd environments/localstack
terraform apply -var='enable_cloudwan=true'
```

---

## 14. Rules of thumb for future changes

Whenever you change this repo, remember:

1. Add or update outputs when another module needs a value.
2. Never assume third-party module output names.
3. Keep LocalStack behavior separate from AWS assumptions.
4. Add advanced features only after simple pieces are healthy.
5. Make optional architecture layers opt-in if runtime support is uncertain.
6. Run validation after every meaningful change.
7. Prefer simple, explicit values in labs.

---

## 15. If I had to rebuild this tomorrow

This is the short practical version.

I would:

1. create the root provider config
2. build a single VPC module
3. add subnet outputs
4. add security groups
5. add one EC2 module
6. make root outputs
7. add EU with a provider alias
8. add Asia with a provider alias
9. validate
10. only then add optional Cloud WAN
11. document every assumption

That order keeps the project understandable and stable.

---

## 16. Final takeaway

The most important lesson in this whole repo is not Cloud WAN or LocalStack.

It is this:

- build simple things first
- make module contracts explicit
- validate constantly
- treat runtime support as separate from configuration correctness
- document limitations honestly

If you follow those rules, you can scale from beginner Terraform to serious architecture work without getting lost.
