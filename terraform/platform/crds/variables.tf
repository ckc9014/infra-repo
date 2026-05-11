variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
  default     = "eu-west-1" 
}

variable "tf_state_bucket" {
  description = "Name of the S3 bucket used for Terraform remote state"
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "github_actions_role_arn" {
  type = string
}