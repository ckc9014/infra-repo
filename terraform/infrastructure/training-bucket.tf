# IAM role for training pod
resource "aws_iam_role" "training_pod_role" {
  name = "${local.name_prefix}-training-pod-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}


# Pod Identity association for training pod
resource "aws_eks_pod_identity_association" "training" {
  cluster_name    = module.eks.cluster_name
  namespace       = "training"
  service_account = "default"
  role_arn        = aws_iam_role.training_pod_role.arn
}

resource "random_id" "suffix" {
  byte_length = 4 
}

resource "aws_s3_bucket" "training" {
  bucket = "${local.name_prefix}-training-bucket-${random_id.suffix.hex}"
}

resource "aws_iam_role_policy" "training_pod_s3" {
  name = "${local.name_prefix}-training-pod-s3"
  role = aws_iam_role.training_pod_role.name
  policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = "s3:PutObject"
      Resource = "${aws_s3_bucket.training.arn}/*"
    }]
  })
}