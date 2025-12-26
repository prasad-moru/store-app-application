# Enhanced ECR Module - modules/ecr/main.tf
# Supports multiple ECR repositories for microservices

resource "aws_ecr_repository" "ecr_repos" {
  for_each = toset(var.repository_names)

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability

  encryption_configuration {
    encryption_type = var.encryption_type
  }

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(
    var.tags,
    {
      Service = each.value
      ManagedBy = "Terraform"
    }
  )
}

# Lifecycle policy to manage images for each repository
resource "aws_ecr_lifecycle_policy" "ecr_policies" {
  for_each   = var.enable_lifecycle_policy ? toset(var.repository_names) : []
  repository = aws_ecr_repository.ecr_repos[each.value].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.image_count_to_keep} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.image_count_to_keep
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
