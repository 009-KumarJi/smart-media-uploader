resource "aws_dynamodb_table" "jobs" {
  name         = "smmu-${var.env}-jobs"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "userId"
  range_key = "jobId"

  attribute {
    name = "userId"
    type = "S"
  }

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

resource "aws_dynamodb_table" "upload_sessions" {
  name         = "smmu-${var.env}-upload-sessions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "uploadId"

  attribute {
    name = "uploadId"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }

  tags = {
    Name        = "smmu-${var.env}-upload-sessions"
    Environment = var.env
  }
}

resource "aws_dynamodb_table" "ws_connections" {
  name         = "smmu-${var.env}-ws-connections"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "jobId"
  range_key = "connectionId"

  attribute {
    name = "jobId"
    type = "S"
  }

  attribute {
    name = "connectionId"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }
}
