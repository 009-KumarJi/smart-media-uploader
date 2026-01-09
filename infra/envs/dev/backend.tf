terraform {
  backend "s3" {
    bucket         = "smmu-terraform-state"
    key            = "smmu/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
