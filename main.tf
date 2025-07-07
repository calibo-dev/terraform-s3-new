
resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Environment = "Dev"
    Test-1      = var.test_1
    Test-2      = var.test_2
  }
}
