# --- Outputs ---

# 1. SSH Access
output "ssh_access" {
  description = "SSH Connection Strings for all nodes"
  value = merge(
    {
      "pg1 [Primary]" = "ssh -i ${var.ssh_key_name}.pem ubuntu@${aws_instance.primary.public_ip}"
    },
    {
      for i, instance in aws_instance.standbys :
      "pg${i + 2} [Standby]" => "ssh -i ${var.ssh_key_name}.pem ubuntu@${instance.public_ip}"
    },
    {
      "monitor" = "ssh -i ${var.ssh_key_name}.pem ubuntu@${aws_instance.monitor.public_ip}"
    }
  )
}

# 2. Database Endpoints
output "database_endpoints" {
  description = "Connection strings for Postgres (Admin/Write and Read)"
  value = {
    "primary_write" = nonsensitive("postgres://mmuser:${var.mm_password}@${aws_lb.ha_postgres.dns_name}:5000/mattermost")
    "read_replicas" = nonsensitive("postgres://mmuser:${var.mm_password}@${aws_lb.ha_postgres.dns_name}:5001/mattermost")
  }
  sensitive = false
}

# 3. Metrics Endpoints
output "metrics_endpoints" {
  description = "Monitoring URLs"
  value = {
    "grafana"    = "http://${aws_instance.monitor.public_ip}:3000"
    "prometheus" = "http://${aws_instance.monitor.public_ip}:9090"
  }
}

output "grafana_admin_password" {
  description = "Admin password for Grafana"
  value       = nonsensitive(random_password.grafana_admin_password.result)
}

# 4. App Configuration
output "app_configuration" {
  description = "Configuration for Applications (Mattermost)"
  value = {
    "mattermost_db" = nonsensitive("postgres://mmuser:${var.mm_password}@${aws_lb.ha_postgres.dns_name}:5000/mattermost")
  }
  sensitive = false
}
