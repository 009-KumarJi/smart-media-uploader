resource "aws_s3_bucket" "raw" {
  bucket = "smmu-${var.env}-raw-media"
}

resource "aws_s3_bucket" "processed" {
  bucket = "smmu-${var.env}-processed-media"
}

resource "aws_s3_bucket_versioning" "raw_versioning" {
  bucket = aws_s3_bucket.raw.id
  versioning_configuration {
    status = "Enabled"
  }
}
