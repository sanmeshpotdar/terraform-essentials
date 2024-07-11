Sure, let's set up a simple yet robust cloud infrastructure for a Netflix-like application on AWS using Terraform. This infrastructure will include:

1. An EC2 instance for the application server.
2. An RDS instance for the database.
3. An S3 bucket for object storage.
4. A Security Group to manage access.

Here’s the Terraform code:

```hcl
provider "aws" {
  region = "us-west-2"
}

# S3 bucket for object storage
resource "aws_s3_bucket" "netflix_bucket" {
  bucket = "netflix-content-bucket"
  acl    = "private"
}

# Security Group
resource "aws_security_group" "netflix_sg" {
  name        = "netflix_sg"
  description = "Allow inbound traffic on port 80 and 443"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance for the application server
resource "aws_instance" "netflix_app" {
  ami           = "ami-0c55b159cbfafe1f0" # Example AMI
  instance_type = "t2.micro"

  security_groups = [aws_security_group.netflix_sg.name]

  tags = {
    Name = "netflix-app-server"
  }
}

# RDS instance for the database
resource "aws_db_instance" "netflix_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "13.4"
  instance_class       = "db.t3.micro"
  name                 = "netflixdb"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true
  publicly_accessible  = true

  vpc_security_group_ids = [aws_security_group.netflix_sg.id]
}

# Outputs
output "s3_bucket_name" {
  value = aws_s3_bucket.netflix_bucket.bucket
}

output "ec2_instance_id" {
  value = aws_instance.netflix_app.id
}

output "rds_instance_endpoint" {
  value = aws_db_instance.netflix_db.endpoint
}
```

This setup includes an S3 bucket for storing media content, an EC2 instance to serve as the app server, and a PostgreSQL RDS instance for the database. Security groups are configured to allow HTTP and HTTPS traffic. Outputs are provided to easily reference key information.
