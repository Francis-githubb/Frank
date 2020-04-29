#----vpc----

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_vpc" "test" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "aws-test-vpc"
  }
}


# Test Subnet

resource "aws_subnet" "test-public" {
  vpc_id = aws_vpc.test.id
  cidr_block = "10.1.4.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "aws-test-PublicSubnet"
  }
}

resource "aws_subnet" "test-private" {
  vpc_id = aws_vpc.test.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "aws-test-PrivateSubnet"
  }
}


# Test Internet Gateway

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "aws-test-igw"
  }
}


# Test NAT Gateway
## Get Elastic IP

resource "aws_eip" "nat" {
  vpc    = false
}

## Create NAT Gateway

resource "aws_nat_gateway" "test-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.test-public.id

  tags = {
    Name = "aws-test-NatGateway"
  }
}

# Test Route tables

resource "aws_route_table" "test-public-rtb" {
  vpc_id = aws_vpc.test.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.test-igw.id
        }
  tags = {
        Name = "aws-test-Publicrtb"
  }
}

resource "aws_route_table" "test-private-rtb" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "aws-test-Privatertb"
  }
}


# Test Route Table Association

resource "aws_route_table_association" "public" {
  subnet_id       = aws_subnet.test-public.id
  route_table_id  = aws_route_table.test-public-rtb.id
}

resource "aws_route_table_association" "private" {
  subnet_id       = aws_subnet.test-private.id
  route_table_id  = aws_route_table.test-private-rtb.id
}


# Test EC2
## Test Instance Linux

resource "aws_instance" "test-linux" {
  instance_type                = "t2.micro"
  ami                          = "ami-0323c3dd2da7fb37d"
  key_name                     = "linuxkey"
  subnet_id                    = aws_subnet.test-public.id
  monitoring                   = true
  associate_public_ip_address  = true
  
  tags = {
    Name = "test linux"
  }
}

## Test Instance Windows

resource "aws_instance" "test-Windows" {
  instance_type                = "t2.micro"
  ami                          = "ami-09d496c26aa745869"
  key_name                     = "linuxkey"
  subnet_id                    = aws_subnet.test-public.id
  monitoring                   = true
  associate_public_ip_address  = true
  
  tags = {
    Name = "test Windows"
  }
}


# SES Email Identity

resource "aws_ses_email_identity" "SES_Email" {
  email = "fc14_us@yahoo.com" "franktonyc@yahoo.com"
}

