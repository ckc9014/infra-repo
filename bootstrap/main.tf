
resource "aws_s3_bucket" "terraform_state" {
  bucket = "backend-bucket"
  lifecycle { prevent_destroy = true }
}
