provider "aws" {
  region = "ap-south-1"

}

################# VPC Block #################

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "myvpc"
  }

}

############## Internet Gateway Block ###########

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id ######## im=nternet gateway will attach th this VPC
  tags = {
    "Name" = "igw"
  }
}

############# subnet block ##############

resource "aws_subnet" "mysubnet" {
  vpc_id = aws_vpc.myvpc.id 
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "mysubnet"
  }

}

############# route Table block##########

resource "aws_route_table" "table1" {
  vpc_id = aws_vpc.myvpc.id ### Route table for VPC
  route  = []

}

############## route block ################


resource "aws_route" "rt" {
  route_table_id         = aws_route_table.table1.id   ## this route will add in route table
  destination_cidr_block = "0.0.0.0/0"                 ### need to connect with internet
  gateway_id             = aws_internet_gateway.igw.id ### Route having internet gateway to connect with internet
  depends_on             = [aws_route_table.table1]    #### This route will add only after creating route table
}


################# security group block ####################

resource "aws_security_group" "sg" {
  name        = "Allow All traffic"
  description = "All traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress = [{
    description      = " All Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    prefix_list_ids  = null
    ipv6_cidr_blocks = null
    security_groups  = null
    self             = null
    }
  ]

  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Out Bound"
      to_port          = 0
      from_port        = 0
      protocol         = "-1"
      prefix_list_ids  = null
      ipv6_cidr_blocks = null
      security_groups  = null
      self             = null
    }
  ]

}

############ Route tabel associatio block #########

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.table1.id
}


#################### EC2 blcok ###############


resource "aws_instance" "myinstance" {
  ami                         = "ami-01216e7612243e0ef"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.mysubnet.id
  count                       = 2
  associate_public_ip_address = true
  tags = {
    "Name" = "web"
  }
}