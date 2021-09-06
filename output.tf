output "redshift_cluster_id" {
  description = "The availability zone of the RDS instance"
  value       = module.redshift_cluster.redshift_cluster_id
}

output "redshift_cluster_endpoint" {
  description = "Redshift endpoint"
  value       = module.redshift_cluster.redshift_cluster_endpoint
}

output "redshift_cluster_hostname" {
  description = "Redshift hostname"
  value       = module.redshift_cluster.redshift_cluster_hostname
}

output "redshift_cluster_port" {
  description = "Redshift port"
  value       = module.redshift_cluster.redshift_cluster_port
}