resource "aws_security_group" "web_security" {
  name        = "web_security"
  description = "create security group for the webserver"
  #vpc_id      = aws_vpc.example.id

  # Allow incoming http traffic
  dynamic "ingress" {
    for_each = [22, 80]
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  #Allow outgoing traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_security"
  }
}