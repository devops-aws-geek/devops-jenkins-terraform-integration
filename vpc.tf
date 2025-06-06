# Create VPC/Subnet/Security Group/Network ACL
#create the VPC
resource "aws_vpc" "My_VPC_LAB" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "Project VPC LAB"
}
} # end resource

# create the Subnet
resource "aws_subnet" "My_VPC_Subnet_LAB" {
  vpc_id                  = aws_vpc.My_VPC_LAB.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
   Name = "My VPC Subnet LAB"
}
} # end resource

# Create the Security Group
resource "aws_security_group" "My_VPC_Security_Group_LAB" {
  vpc_id       = aws_vpc.My_VPC_LAB.id
  name         = "My VPC Security Group LAB"
  description  = "My VPC Security Group"

  # allow ingress of port 22
  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
   Name = "My VPC Security Group LAB"
   Description = "My VPC Security Group"
}
} # end resource

# create VPC Network access control list
resource "aws_network_acl" "My_VPC_Security_ACL_LAB" {
  vpc_id = aws_vpc.My_VPC_LAB.id
  subnet_ids = [ aws_subnet.My_VPC_Subnet_LAB.id ]# allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22
    to_port    = 22
  }

  # allow ingress port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80
    to_port    = 80
  }

  # allow ingress ephemeral ports
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }

  # allow egress port 22
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22
    to_port    = 22
  }

  # allow egress port 80
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80
    to_port    = 80
  }

  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "My VPC ACL LAB"
}
} # end resource

# Create the Internet Gateway
resource "aws_internet_gateway" "My_VPC_GW_LAB" {
 vpc_id = aws_vpc.My_VPC_LAB.id
 tags = {
        Name = "My VPC Internet Gateway LAB"
}
} # end resource

# Create the Route Table
resource "aws_route_table" "My_VPC_route_table_LAB" {
 vpc_id = aws_vpc.My_VPC_LAB.id
 tags = {
        Name = "My VPC Route Table LAB"
}
} # end resource

# Create the Internet Access
resource "aws_route" "My_VPC_internet_access_LAB" {
  route_table_id         = aws_route_table.My_VPC_route_table_LAB.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW_LAB.id
} # end resource

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_VPC_association_LAB" {
  subnet_id      = aws_subnet.My_VPC_Subnet_LAB.id
  route_table_id = aws_route_table.My_VPC_route_table_LAB.id
} # end resource

