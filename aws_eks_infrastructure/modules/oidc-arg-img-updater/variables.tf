# ArgoCD Image Updater IAM Module - modules/argocd-image-updater-iam/variables.tf

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider for the EKS cluster"
  type        = string
}

variable "ecr_repository_arns" {
  description = "List of ECR repository ARNs that ArgoCD Image Updater can access"
  type        = list(string)
}

variable "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed"
  type        = string
  default     = "argocd"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account for ArgoCD Image Updater"
  type        = string
  default     = "argocd-image-updater"
}

variable "tags" {
  description = "A map of tags to add to resources"
  type        = map(string)
  default     = {}
}
