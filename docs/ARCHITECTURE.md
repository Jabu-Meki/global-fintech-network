# Architecture

## Overview

This project provisions a small multi-region network lab with Terraform and LocalStack.

The runnable root Terraform stack lives in:

- `environments/localstack`

The root module orchestrates four child modules:

- `modules/vpc`
- `modules/security_groups`
- `modules/ec2`
- `modules/cloudwan`

## Regions

The current lab targets:

- `us-east-1`
- `eu-west-1`
- `ap-southeast-1`

The default AWS provider handles the US region, and aliased providers are used for Europe and Asia.

## Module Responsibilities

### `modules/vpc`

Creates:

- one VPC
- public subnets
- private subnets
- an internet gateway
- public and private route tables

Exports:

- VPC ID and ARN
- public subnet IDs
- private subnet IDs and ARNs

### `modules/security_groups`

Creates:

- one public security group
- one private security group
- ingress rules for SSH and HTTP on the public group
- restricted SSH access from the public group into the private group
- outbound access for the private group

Exports:

- public security group ID
- private security group ID

### `modules/ec2`

Creates:

- a single EC2 instance per module call

The module uses a LocalStack-safe placeholder AMI by default:

- `ami-12345678`

Exports:

- instance ID
- public IP
- private IP

### `modules/cloudwan`

Acts as a wrapper around the upstream `aws-ia/cloudwan/aws` module and then creates regional VPC attachments.

It:

- builds the global network and core network
- composes the policy document
- attaches the regional VPCs to Cloud WAN

At the root level, this module is optional and controlled by `var.enable_cloudwan`.

Default behavior:

- `enable_cloudwan = false`

Reason:

- LocalStack's coverage docs currently do not list Network Manager as a covered service, so Cloud WAN is treated as an AWS-only path in this repository.

## Data Flow

The root module passes outputs from one module into the next:

- `modules/vpc` exports VPC and subnet data
- `modules/security_groups` consumes `vpc_id`
- `modules/ec2` consumes subnet IDs and security group IDs
- `modules/cloudwan` consumes VPC ARNs and private subnet ARNs

This makes the modules behave like small APIs, where output names must remain stable and exact.
