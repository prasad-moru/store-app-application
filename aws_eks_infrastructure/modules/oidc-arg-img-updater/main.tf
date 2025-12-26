# ArgoCD Image Updater IAM Module - modules/oidc-arg-img-updater/main.tf
# FIXED VERSION - Handles OIDC URL properly

data "aws_caller_identity" "current" {}

locals {
  # Ensure we have a clean OIDC URL without https:// prefix
  oidc_url_clean = replace(replace(var.oidc_provider_url, "https://", ""), "http://", "")
}

# IAM Policy for ECR Access
resource "aws_iam_policy" "argocd_image_updater_ecr" {
  name        = "${var.cluster_name}-argocd-image-updater-ecr-policy"
  description = "Policy for ArgoCD Image Updater to access ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage"
        ]
        Resource = var.ecr_repository_arns
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-argocd-image-updater-ecr-policy"
    }
  )
}

# Trust Policy for OIDC Federation
data "aws_iam_policy_document" "argocd_image_updater_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url_clean}:sub"
      values   = ["system:serviceaccount:${var.argocd_namespace}:${var.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url_clean}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# IAM Role for ArgoCD Image Updater
resource "aws_iam_role" "argocd_image_updater" {
  name               = "${var.cluster_name}-argocd-image-updater-role"
  assume_role_policy = data.aws_iam_policy_document.argocd_image_updater_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-argocd-image-updater-role"
    }
  )
}

# Attach ECR Policy to Role
resource "aws_iam_role_policy_attachment" "argocd_image_updater_ecr" {
  policy_arn = aws_iam_policy.argocd_image_updater_ecr.arn
  role       = aws_iam_role.argocd_image_updater.name
}
