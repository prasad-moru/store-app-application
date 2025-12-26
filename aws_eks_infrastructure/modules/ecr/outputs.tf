# Enhanced ECR Module - modules/ecr/outputs.tf

output "repository_urls" {
  description = "Map of repository names to their URLs"
  value = {
    for name, repo in aws_ecr_repository.ecr_repos : name => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    for name, repo in aws_ecr_repository.ecr_repos : name => repo.arn
  }
}

output "repository_names" {
  description = "List of all repository names"
  value       = [for repo in aws_ecr_repository.ecr_repos : repo.name]
}

output "registry_id" {
  description = "ECR Registry ID"
  value       = values(aws_ecr_repository.ecr_repos)[0].registry_id
}
