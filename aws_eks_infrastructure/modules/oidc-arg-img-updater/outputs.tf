# ArgoCD Image Updater IAM Module - modules/argocd-image-updater-iam/outputs.tf

output "role_arn" {
  description = "ARN of IAM role for ArgoCD Image Updater"
  value       = aws_iam_role.argocd_image_updater.arn
}

output "role_name" {
  description = "Name of IAM role for ArgoCD Image Updater"
  value       = aws_iam_role.argocd_image_updater.name
}

output "policy_arn" {
  description = "ARN of IAM policy for ArgoCD Image Updater ECR access"
  value       = aws_iam_policy.argocd_image_updater_ecr.arn
}

output "service_account_annotation" {
  description = "Annotation to add to the Kubernetes service account"
  value       = "eks.amazonaws.com/role-arn=${aws_iam_role.argocd_image_updater.arn}"
}
