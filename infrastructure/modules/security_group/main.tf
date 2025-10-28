resource "aws_security_group" "ec2_sg" {
  name        = "tf-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  # Ingress rules
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-ec2-sg"
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "tf-rds-sg"
  description = "Allow MySQL from EC2 SG"
  vpc_id      = var.vpc_id

  # Allow MySQL from EC2 SG
  ingress {
    description      = "MySQL from EC2"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.ec2_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-rds-sg"
  }
}

