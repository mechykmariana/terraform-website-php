terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}
provider "aws" {
  region = "eu-north-1"
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_security.id]
  
  #subnet_id     = aws_subnet.example.id
  associate_public_ip_address = true
  user_data = local.user_data
  tags = {
    Name = "web"
  }
  

}
