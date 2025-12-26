# Enhanced ECR Module - modules/ecr/variables.tf

variable "repository_names" {
  description = "List of ECR repository names for microservices"
  type        = list(string)
}

variable "tags" {
  description = "Tags for ECR repositories"
  type        = map(string)
  default     = {}
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "IMMUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "encryption_type" {
  description = "Encryption type (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy"
  type        = bool
  default     = true
}

variable "image_count_to_keep" {
  description = "Number of images to keep in lifecycle policy"
  type        = number
  default     = 30
}

variable "node_role_arn" {
  description = "ARN of the EKS node IAM role for repository policy"
  type        = string
}
