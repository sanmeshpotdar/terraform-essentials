```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-1.8.0-openjdk
              cd /opt
              wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.50/bin/apache-tomcat-9.0.50.tar.gz
              tar xzvf apache-tomcat-9.0.50.tar.gz
              mv apache-tomcat-9.0.50 tomcat
              chmod +x /opt/tomcat/bin/*.sh
              /opt/tomcat/bin/startup.sh
              EOF

  tags = {
    Name = "Web-Server-${count.index + 1}"
  }
}

resource "aws_elb" "web" {
  name               = "web-load-balancer"
  availability_zones = ["us-west-2a", "us-west-2b"]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  instances = [aws_instance.web[*].id]

  tags = {
    Name = "Web-Load-Balancer"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  tags = {
    Name = "MyRDSInstance"
  }
}

output "instance_ids" {
  value = aws_instance.web[*].id
}

output "public_ips" {
  value = aws_instance.web[*].public_ip
}

output "elb_dns_name" {
  value = aws_elb.web.dns_name
}

output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}
```
