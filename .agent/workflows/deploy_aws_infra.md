---
description: Deploy the AWS High Availability PostgreSQL Infrastructure
---

This workflow provisions the EC2 instances, Load Balancer, and Monitoring stack using Terraform.

1. Navigate to the terraform directory where the infrastructure code resides.
2. Initialize Terraform to download providers and modules.
3. Apply the configuration to create the resources.

// turbo
1. cd terraform
// turbo
2. terraform init
// turbo
// turbo
3. AWS_PROFILE=harvest terraform apply -auto-approve

### Clean Redeploy (Optional)
Use this if you need to wipe data (e.g., for version upgrades)
```bash
terraform taint 'aws_ebs_volume.pg_data[0]'
terraform taint 'aws_ebs_volume.pg_data[1]'
terraform taint 'aws_ebs_volume.pg_data[2]'
terraform taint 'aws_instance.db_nodes[0]'
terraform taint 'aws_instance.db_nodes[1]'
terraform taint 'aws_instance.db_nodes[2]'
terraform apply -auto-approve
```
