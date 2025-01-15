terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "ansible" {
  key_name   = "ansible-key"
  public_key = file("~/.ssh/aws.pub")
}

resource "aws_instance" "example" {
  ami             = "ami-011899242bb902164"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.ansible.key_name
  security_groups = [aws_security_group.instances.name]

  tags = {
    Name = "WebServer"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > inventory.txt"
  }
}

resource "aws_security_group" "instances" {
  name        = "instances"
  description = "Security group for web server with multiple ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_server_sg"
  }
}


output "public_ip" {
  value = aws_instance.example.public_ip
}
