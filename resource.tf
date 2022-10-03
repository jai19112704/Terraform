################## VPC Creation  ####################

resource "aws_vpc" "VPC1" {
    cidr_block = "10.0.0.0/16"   # With CIDR
    tags = {
      "name" = "VPC1"
    }
  
}

############# Subnet Creation =============
resource "aws_subnet" "Subnet1" {
    vpc_id = aws_vpc.VPC1.id
    cidr_block = "10.0.1.0/24"
    tags = {
      "name" = "Subnet1"
    }
  
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.VPC1.id
    cidr_block = "10.0.2.0/24"
    tags = {
      "name" = "subnet2"
    }
}

############### Internet Gateway  ###################
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.VPC1.id
    tags = {
      "Name" = "igw"
    }
  
}

################# Route Table ################
resource "aws_route_table" "routtable1" {
    vpc_id = aws_vpc.VPC1.id
    route = [{
        cidr_block = "0.0.0.0/0"
        gateway_id=aws_internet_gateway.igw.id
        carrier_gateway_id=null
        core_network_arn=null
        destination_prefix_list_id=null
        egress_only_gateway_id=null
        instance_id=null
        ipv6_cidr_block=null
        local_gateway_id=null
        nat_gateway_id=null
        network_interface_id=null
        transit_gateway_id=null
        vpc_endpoint_id=null
        vpc_peering_connection_id=null

    
} ]


}

resource "aws_route_table" "routetable2" {
vpc_id = aws_vpc.VPC1.id

route = [ {
    cidr_block = "0.0.0.0/0"
  gateway_id=aws_internet_gateway.igw.id
  carrier_gateway_id=null
        core_network_arn=null
        destination_prefix_list_id=null
        egress_only_gateway_id=null
        instance_id=null
        ipv6_cidr_block=null
        local_gateway_id=null
        nat_gateway_id=null
        network_interface_id=null
        transit_gateway_id=null
        vpc_endpoint_id=null
        vpc_peering_connection_id=null
  
} ]
  
}

############## Subnet Association ##########
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Subnet1.id
  route_table_id = aws_route_table.routtable1.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.routetable2.id
}

############ Security Group ###########

resource "aws_security_group" "sg1" {

vpc_id = aws_vpc.VPC1.id
 name        = "allow_tls"
  description = "Allow TLS inbound traffic"
    ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
  
}

################### Key Pair ###########

resource "aws_key_pair" "key" {
  key_name   = "Terraform1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+UXtYRGnIiKULWFhFXOnqJiBx0Zjg+PTd3Zg1u3vFxDKyv+ksiClDfwPM9hlnU4rf7yeBS9DzkKhC8qgmbCE1CpCcOja2+jwz9iD9gzEzTWLmx8Q1v68bNKrpTHbLgtcY7NI58wqgKw0tkydN32cHYEaoBwnPQk1TeUuv1a2xDvvYyKRWAtDV2XZT7OZu5mT5Iogxy6nJ6QhLg9pgn9/siGl4pGzP9gDjRX3ZJAsg42zFmxKJn9xf1DGxc/d2ppnT1LJjH74CAfisrv8ip4teIaQOomX0BdmZgq/WZWd9oCzZUX5Vu/5ZK9hrYRE9C1XUrb6fb0vA90phWs4UEG5z"
}


##################### EC2 Instance #################

resource "aws_instance" "myinstance1" {
    ami = "ami-0464d49b8794eba32"
    instance_type = "t2.micro"
  subnet_id = aws_subnet.Subnet1.id
  #security_groups = "sg-088c2d8bd991847fc"
  # public_ip="true"
  key_name = aws_key_pair.key.id
  tags = {
"Name" = "myinstance1"
  }
}

resource "aws_instance" "myinstance2" {
    ami = "ami-0464d49b8794eba32"
    instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet2.id
  #security_groups = "sg-088c2d8bd991847fc"
  # public_ip="true"
  # map_public_ip_on_launch = true
  key_name = aws_key_pair.key.id
  depends_on = [aws_internet_gateway.igw]
  tags = {
"Name" = "myinstance2"
  }
}