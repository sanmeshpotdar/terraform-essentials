Sure thing! I'll translate your Pulumi program over to Terraform. We'll set up the S3 bucket, EC2 instance, security group, and CloudFront distribution.

Here's the Terraform version of your infrastructure:

```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "mcdonalds_assets" {
  bucket = "mcdonalds-assets"
  
  website {
    index_document = "index.html"
  }
}

data "aws_ami" "amzn_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "web_secgrp" {
  description = "Enable HTTP access"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server_www" {
  ami           = data.aws_ami.amzn_linux.id
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.web_secgrp.id]
  
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup python -m SimpleHTTPServer 80 &
              EOF
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.mcdonalds_assets.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.mcdonalds_assets.arn
  }
  
  enabled             = true
  default_root_object = "index.html"
  
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.mcdonalds_assets.arn
    viewer_protocol_policy = "allow-all"
    
    forwarded_values {
      query_string = false
      
      cookies {
        forward = "none"
      }
    }
  }
  
  price_class = "PriceClass_100"
}

output "bucket_url" {
  value = "http://${aws_s3_bucket.mcdonalds_assets.website_endpoint}"
}

output "cdn_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
```
