terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}
resourc "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}
resource "aws_subnet" "pubsbnt" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "pubsbnt"
  }
}
resource "aws_subnet" "pvtsbnt" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "pvtsbnt"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}
resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "pubrt"
  }
}
resource "aws_route_table_association" "pubsbntpubrtassociation" {
  subnet_id      = aws_subnet.pubsbnt.id
  route_table_id = aws_route_table.pubrt.id
}
resource "aws_eip" "myeip" {
  
}
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pubsbnt.id

  tags = {
    Name = "gwNAT"
  }

 
}
resource "aws_route_table" "pvtrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

 
  tags = {
    Name = "pvtrt"
  }
}
resource "aws_route_table_association" "pvtsbntpvtrtassocication" {
  subnet_id      = aws_subnet.pvtsbnt.id
  route_table_id = aws_route_table.pvtrt.id
}
