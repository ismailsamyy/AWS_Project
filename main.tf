provider "aws" {
  region = "us-east-1"
}

# Create VPC for Development
resource "aws_vpc" "vpc_dev" {
  cidr_block           = "10.15.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-Dev"
  }
}

# Create VPC for Shared Resources
resource "aws_vpc" "vpc_shared" {
  cidr_block           = "10.25.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-Shared"
  }
}

# Create Subnets in VPC-Dev
resource "aws_subnet" "public_sn1_dev" {
  vpc_id                  = aws_vpc.vpc_dev.id
  cidr_block              = "10.15.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-SN1-Dev"
  }
}

resource "aws_subnet" "public_sn2_dev" {
  vpc_id                  = aws_vpc.vpc_dev.id
  cidr_block              = "10.15.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-SN2-Dev"
  }
}

resource "aws_subnet" "private_sn1_dev" {
  vpc_id            = aws_vpc.vpc_dev.id
  cidr_block        = "10.15.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private-SN1-Dev"
  }
}

resource "aws_subnet" "private_sn2_dev" {
  vpc_id            = aws_vpc.vpc_dev.id
  cidr_block        = "10.15.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private-SN2-Dev"
  }
}

# Create Subnets in VPC-Shared
resource "aws_subnet" "public_sn_shared" {
  vpc_id                  = aws_vpc.vpc_shared.id
  cidr_block              = "10.25.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-SN-Shared"
  }
}

resource "aws_subnet" "private_sn_shared" {
  vpc_id            = aws_vpc.vpc_shared.id
  cidr_block        = "10.25.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private-SN-Shared"
  }
}

# Create Internet Gateway for VPC-Dev
resource "aws_internet_gateway" "igw_dev" {
  vpc_id = aws_vpc.vpc_dev.id
  tags = {
    Name = "IGW-Dev"
  }
}

# Create Internet Gateway for VPC-Shared
resource "aws_internet_gateway" "igw_shared" {
  vpc_id = aws_vpc.vpc_shared.id
  tags = {
    Name = "IGW-Shared"
  }
}

# Create Route Tables and Associate Public Subnets for VPC-Dev
resource "aws_route_table" "public_rt_dev" {
  vpc_id = aws_vpc.vpc_dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_dev.id
  }

  tags = {
    Name = "Public-RT-Dev"
  }
}

resource "aws_route_table_association" "public_rt_assoc_sn1_dev" {
  subnet_id      = aws_subnet.public_sn1_dev.id
  route_table_id = aws_route_table.public_rt_dev.id
}

resource "aws_route_table_association" "public_rt_assoc_sn2_dev" {
  subnet_id      = aws_subnet.public_sn2_dev.id
  route_table_id = aws_route_table.public_rt_dev.id
}

# Create NAT Gateway for VPC-Dev
resource "aws_eip" "nat_dev" {
  domain = "vpc" # Updated syntax
  tags = {
    Name = "EIP-NAT-Dev"
  }
}

resource "aws_nat_gateway" "nat_dev" {
  allocation_id = aws_eip.nat_dev.id
  subnet_id     = aws_subnet.public_sn1_dev.id
  tags = {
    Name = "NAT-Dev"
  }
}

# Create Route Tables and Associate Private Subnets for VPC-Dev
resource "aws_route_table" "private_rt_dev" {
  vpc_id = aws_vpc.vpc_dev.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_dev.id
  }

  tags = {
    Name = "Private-RT-Dev"
  }
}

resource "aws_route_table_association" "private_rt_assoc_sn1_dev" {
  subnet_id      = aws_subnet.private_sn1_dev.id
  route_table_id = aws_route_table.private_rt_dev.id
}

resource "aws_route_table_association" "private_rt_assoc_sn2_dev" {
  subnet_id      = aws_subnet.private_sn2_dev.id
  route_table_id = aws_route_table.private_rt_dev.id
}
# Create NAT Gateway for VPC-Shared
resource "aws_eip" "nat_shared" {
  domain = "vpc" # Updated syntax
  tags = {
    Name = "EIP-NAT-Shared"
  }
}

resource "aws_nat_gateway" "nat_shared" {
  allocation_id = aws_eip.nat_shared.id
  subnet_id     = aws_subnet.public_sn_shared.id
  tags = {
    Name = "NAT-Shared"
  }
}

# Create Route Tables and Associate Public Subnet for VPC-Shared
resource "aws_route_table" "public_rt_shared" {
  vpc_id = aws_vpc.vpc_shared.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_shared.id
  }

  tags = {
    Name = "Public-RT-Shared"
  }
}

resource "aws_route_table_association" "public_rt_assoc_shared" {
  subnet_id      = aws_subnet.public_sn_shared.id
  route_table_id = aws_route_table.public_rt_shared.id
}

# Create Route Tables and Associate Private Subnet for VPC-Shared
resource "aws_route_table" "private_rt_shared" {
  vpc_id = aws_vpc.vpc_shared.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_shared.id
  }

  tags = {
    Name = "Private-RT-Shared"
  }
}

resource "aws_route_table_association" "private_rt_assoc_shared" {
  subnet_id      = aws_subnet.private_sn_shared.id
  route_table_id = aws_route_table.private_rt_shared.id
}
# VPC Peering Connection
resource "aws_vpc_peering_connection" "peer_dev_shared" {
  vpc_id        = aws_vpc.vpc_dev.id
  peer_vpc_id   = aws_vpc.vpc_shared.id
  peer_region   = "us-east-1"
  tags = {
    Name = "Dev-to-Shared-Peering"
  }
}

# Route for VPC Peering from Dev to Shared
resource "aws_route" "peer_route_dev_to_shared" {
  route_table_id         = aws_route_table.private_rt_dev.id
  destination_cidr_block = aws_vpc.vpc_shared.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_dev_shared.id
}

# Route for VPC Peering from Shared to Dev
resource "aws_route" "peer_route_shared_to_dev" {
  route_table_id         = aws_route_table.private_rt_shared.id
  destination_cidr_block = aws_vpc.vpc_dev.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_dev_shared.id
}

# Route for VPC Peering from Shared to Dev
resource "aws_route" "peer_route_shared2_to_dev" {
  route_table_id         = aws_route_table.public_rt_shared.id
  destination_cidr_block = aws_vpc.vpc_dev.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_dev_shared.id
}


# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.vpc_dev.id
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
    Name = "ALB-SG"
  }
}
# Define Security Group for Bastion (if needed)
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.vpc_shared.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust CIDR for tighter security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion-SG"
  }
}

# Security Group for Web Servers 
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.vpc_dev.id

  # Allow traffic from the ALB
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.alb_sg.id]
  }
  
  # Allow SSH from the Bastion host
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.25.1.0/24"]
  }
  # Allow ICMP traffic from the WEBSERVER1 AND 2
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.15.0.0/16"]
  }
  # Allow ICMP traffic from the mysql instance
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.25.2.0/24"]
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-Server-SG"
  }
}



# Security Group for mysql 
resource "aws_security_group" "mysql_sg" {
  vpc_id = aws_vpc.vpc_shared.id



  # Allow SSH from the Bastion host
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.25.1.0/24"]
  }
 # Allow traffic from the webservers 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.15.3.0/24"]   
  }
 # Allow traffic from the webservers 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["10.15.4.0/24"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MYSQL-SG"
  }
}



# Bastion Host
resource "aws_instance" "bastion" {
  ami           = "ami-0453ec754f44f9a4a" # Replace with appropriate AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_sn_shared.id
  security_groups = [aws_security_group.bastion_sg.id]
  key_name      = "vockey"

  tags = {
    Name = "Bastion-Host"
  }
}


# mysql Host
resource "aws_instance" "mysql" {
  ami           = "ami-0453ec754f44f9a4a" # Replace with appropriate AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_sn_shared.id
  security_groups = [aws_security_group.mysql_sg.id]
  key_name      = "vockey"

  tags = {
    Name = "mysql-instance"
  }
  
  user_data = <<-EOT
#!/bin/bash
sudo yum install  docker
sudo systemctl start docker 


EOT
}


# Webserver1
resource "aws_instance" "webserver1" {
  ami           = "ami-0453ec754f44f9a4a" # Replace with correct AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_sn1_dev.id
  security_groups = [aws_security_group.web_sg.id]
  key_name      = "vockey"



  tags = {
    Name = "Webserver1"
  }
  user_data = <<-EOT
#!/bin/bash
sudo yum install  docker
sudo systemctl start docker 


EOT
}



# Webserver2
resource "aws_instance" "webserver2" {
  ami           = "ami-0453ec754f44f9a4a" # Replace with correct AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_sn2_dev.id
  security_groups = [aws_security_group.web_sg.id]
  key_name      = "vockey"

  

  tags = {
    Name = "Webserver2"
  }
  user_data = <<-EOT
#!/bin/bash
sudo yum install  docker
sudo systemctl start docker 


EOT
}


resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.vpc_dev.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  # Add route tables for private subnets
  route_table_ids   = [
    aws_route_table.private_rt_dev.id
  ]
}


# S3 Bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-private-app120425-bucket"

  tags = {
    Name = "Private-App-Bucket"
  }

}
