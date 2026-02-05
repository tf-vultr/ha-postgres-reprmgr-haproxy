---
description: Destroy the AWS High Availability PostgreSQL Infrastructure
---

This workflow tears down the EC2 instances, Load Balancer, and Monitoring stack using Terraform.

1. Navigate to the terraform directory.
2. Run terraform destroy.

// turbo
1. cd terraform
// turbo
2. AWS_PROFILE=harvest terraform destroy -auto-approve
