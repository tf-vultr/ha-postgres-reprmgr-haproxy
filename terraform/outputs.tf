# --- Outputs ---

output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "db_node_public_ips" {
  value = {
    for i, instance in concat([aws_instance.primary], aws_instance.standbys) :
    "pg${i + 1}" => instance.public_ip
  }
}

output "nlb_endpoint" {
  description = "The DNS name of the Network Load Balancer"
  value       = aws_lb.ha_postgres.dns_name
}

output "psql_connection_string" {
  description = "Connection string for PostgreSQL via NLB"
  value       = nonsensitive("postgres://postgres:${var.db_password}@${aws_lb.ha_postgres.dns_name}:5000/postgres")
  sensitive   = false
}

output "mattermost_connection_string" {
  description = "Connection string for Mattermost via NLB"
  value       = nonsensitive("postgres://mmuser:${var.mm_password}@${aws_lb.ha_postgres.dns_name}:5000/mattermost")
  sensitive   = false
}
