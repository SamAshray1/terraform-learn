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
  key_name = "ansible-key"
  public_key = file("~/.ssh/aws.pub")
}

resource "aws_instance" "example" {
  ami           = "ami-011899242bb902164"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ansible.key_name  

  tags = {
    Name = "WebServer"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > inventory.txt"
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

