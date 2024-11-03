terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

variable "aws_access_key" {
  type = string
  sensitive = true
}

variable "aws_secret_key" {
  type = string
  sensitive = true
}

# define a provider
provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# create a new vpc
resource "aws_vpc" "production-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production-vpc"
  }
}

# create an internet gateway
resource "aws_internet_gateway" "production-igw" {
  vpc_id = aws_vpc.production-vpc.id
  tags = {
    Name = "production-igw"
  }
}

# create a route table
resource "aws_route_table" "production_route_table" {
  vpc_id = aws_vpc.production-vpc.id


  route {
    # sends all traffic to the internet
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.production-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.production-igw.id
  }

  tags = {
    Name : "production-route-table"
  }
}


# create a subnet within the vpc
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.production-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "production-subnet"
  }
}

# associate the subnet with the route table
resource "aws_route_table_association" "prod-rta" {
  route_table_id = aws_route_table.production_route_table.id
  subnet_id      = aws_subnet.subnet-1.id
}

# create a security group to allow ports 22, 443, 80
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.production-vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # allow https traffic from anywhere on the internet
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # allow https traffic from anywhere on the internet
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # allow https traffic from anywhere on the internet
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port = 0
    to_port   = 0
    # any protocol and cidr blocks
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}

# create a network interface with an ip in the subnet that was created - basically a private IP address
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web_traffic.id]
}

# Assign an Elastic IP directly to the instance
resource "aws_eip" "prod-eip" {
  instance   = aws_instance.web-server.id
  depends_on = [aws_internet_gateway.production-igw]
}

# Create an amazon linux 2023 server and install/enable Apache2
resource "aws_instance" "web-server" {
  ami               = "ami-06b21ccaeff8cd686"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "server-key"

  vpc_security_group_ids = [aws_security_group.allow_web_traffic.id]
  subnet_id              = aws_subnet.subnet-1.id

  # Run commands to install packages
  user_data = <<-EOF
      #!/bin/bash
      sudo yum update -y
      sudo yum install -y httpd
      sudo systemctl start httpd
      sudo systemctl enable httpd
      echo "Your very first web server" | sudo tee /var/www/html/index.html
  EOF

  tags = {
    Name = "web-server"
  }
}

