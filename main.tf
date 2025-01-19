provider "aws" {
  region = "us-east-1" # Change to your desired region
}

# S3 Bucket resource
resource "aws_s3_bucket" "static_website" {
  bucket = "my-static-website-bucket-fsl-leonardo" # Change this to your desired bucket name

  # Enable website hosting
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  versioning {
    enabled = true # Enable versioning for the bucket
  }

  tags = {
    Name        = "Static Website Bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket             = aws_s3_bucket.static_website.id
  block_public_acls  = false
  block_public_policy = false
  restrict_public_buckets = false
  ignore_public_acls = false
}

# Upload index.html and error.html to the bucket (optional)

# S3 Bucket Policy to allow public access
resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.static_website.id
  key    = "index.html"
  source = "index.html" # Ensure index.html is in the same directory as this Terraform file
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "error" {
  bucket = aws_s3_bucket.static_website.id
  key    = "error.html"
  source = "error.html" # Ensure error.html is in the same directory as this Terraform file
  content_type = "text/html"
}

output "website_endpoint" {
  value = aws_s3_bucket.static_website.website_endpoint
}
