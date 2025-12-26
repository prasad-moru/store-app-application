# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# EKS Outputs
output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

# Node Group Outputs
output "node_group_name" {
  description = "The name of the EKS node group"
  value       = aws_eks_node_group.this.node_group_name
}

output "node_group_arn" {
  description = "The ARN of the EKS node group"
  value       = aws_eks_node_group.this.arn
}

output "node_security_group_id" {
  description = "The ID of the node security group"
  value       = aws_security_group.nodes.id
}

# IAM Outputs
output "cluster_role_arn" {
  description = "ARN of IAM role for EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "ARN of IAM role for EKS nodes"
  value       = aws_iam_role.node.arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.url
}

# EBS CSI Driver Outputs
output "ebs_csi_role_arn" {
  description = "ARN of IAM role for EBS CSI driver"
  value       = module.ebs_csi.ebs_csi_role_arn
}

# ALB Ingress Controller Outputs
output "alb_ingress_role_arn" {
  description = "ARN of IAM role for ALB Ingress Controller"
  value       = var.enable_alb_ingress ? module.alb_ingress[0].alb_ingress_role_arn : null
}

# Command to update kubeconfig
output "configure_kubectl" {
  description = "Command to configure kubectl to connect to the EKS cluster"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

output "ecr_repository_urls" {
  description = "Map of ECR repository names to their URLs"
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "Map of ECR repository names to their ARNs"
  value       = module.ecr.repository_arns
}

output "ecr_repository_names" {
  description = "List of all ECR repository names"
  value       = module.ecr.repository_names
}

output "ecr_registry_id" {
  description = "ECR Registry ID"
  value       = module.ecr.registry_id
}

# ArgoCD Image Updater IAM Outputs
output "argocd_image_updater_role_arn" {
  description = "ARN of IAM role for ArgoCD Image Updater"
  value       = module.argocd_image_updater_iam.role_arn
}

output "argocd_image_updater_role_name" {
  description = "Name of IAM role for ArgoCD Image Updater"
  value       = module.argocd_image_updater_iam.role_name
}

output "argocd_image_updater_policy_arn" {
  description = "ARN of IAM policy for ArgoCD Image Updater ECR access"
  value       = module.argocd_image_updater_iam.policy_arn
}

output "argocd_image_updater_service_account_annotation" {
  description = "Annotation for ArgoCD Image Updater service account (use this in Helm values)"
  value       = module.argocd_image_updater_iam.service_account_annotation
}

# Formatted output for easy Helm values integration
output "helm_values_snippet" {
  description = "Helm values snippet for ArgoCD Image Updater"
  value = <<-EOT
    # Add this to your ArgoCD Image Updater Helm values:
    serviceAccount:
      create: true
      annotations:
        ${module.argocd_image_updater_iam.service_account_annotation}
    
    config:
      registries:
        - name: ECR
          api_url: https://${module.ecr.registry_id}.dkr.ecr.${var.region}.amazonaws.com
          prefix: ${module.ecr.registry_id}.dkr.ecr.${var.region}.amazonaws.com
          ping: yes
          insecure: no
          credentials: ext:/scripts/ecr-login.sh
          credsexpire: 10h
  EOT
}
