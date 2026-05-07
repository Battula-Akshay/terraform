
# Configure the AWS Provider
provider "aws" {
  region = "ap-south-2"
  profile = "aws642"
}

resource "aws_s3_bucket" "static-website-hosting" {
  bucket = "my-tf-static-website-bucket-1"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.static-website-hosting.id  # No quotes!
  key    = "index.html"                              # Just the filename
  source = "index.html"
  content_type = "text/html"                        # Add this so browser knows it's HTML
}
resource "aws_s3_object" "error_object" {
  bucket       = aws_s3_bucket.static-website-hosting.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
}
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static-website-hosting.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
resource "aws_s3_bucket_public_access_block" "public_access" {
bucket = aws_s3_bucket.static-website-hosting.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_policy" "allow_access_from_internet" {
  bucket = aws_s3_bucket.static-website-hosting.id
  policy = data.aws_iam_policy_document.allow_public_read.json
}

data "aws_iam_policy_document" "allow_public_read" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]

    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.static-website-hosting.arn}/*",
    ]
  }
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}