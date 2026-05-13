resource "aws_ecr_repository" "training" {
  name = "${local.name_prefix}-training"  
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}