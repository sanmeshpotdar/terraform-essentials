provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "tomcat" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              # Update the instance
              yum update -y

              # Install Java
              yum install -y java-1.8.0-openjdk

              # Download and install Apache Tomcat
              cd /opt
              wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.50/bin/apache-tomcat-9.0.50.tar.gz
              tar xzvf apache-tomcat-9.0.50.tar.gz
              mv apache-tomcat-9.0.50 tomcat

              # Set permissions
              chmod +x /opt/tomcat/bin/*.sh

              # Start Tomcat
              /opt/tomcat/bin/startup.sh

              # Install necessary patches and tools
              yum install -y patch wget tar

              # Apply patches (example placeholder)
              cd /opt/tomcat
              # wget http://example.com/patches/patch-xyz.patch
              # patch -p1 < patch-xyz.patch

              EOF

  tags = {
    Name = "Tomcat-Server"
  }
}

output "instance_id" {
  value = aws_instance.tomcat.id
}

output "public_ip" {
  value = aws_instance.tomcat.public_ip
}
