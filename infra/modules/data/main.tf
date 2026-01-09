resource "aws_dynamodb_table" "jobs" {
  name         = "smmu-${var.env}-jobs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "jobId"

  attribute {
    name = "jobId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "media" {
  name         = "smmu-${var.env}-media"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "mediaId"

  attribute {
    name = "mediaId"
    type = "S"
  }
}
