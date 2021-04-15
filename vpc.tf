# 1. create vpc
resource "aws_vpc" "eks-poc" {
  cidr_block = var.vpc_cidr_block


  tags = {
    Name = "eks-poc"
  }
}

# 2. create Internet Gateway

resource "aws_internet_gateway" "eks-IGW" {
  vpc_id = aws_vpc.eks-poc.id

  tags = {
    Name = "eks-IGW"
  }
}



# 3.creating 2 public subnets and 2 private subnets in us-east-1a and us-east-1b

resource "aws_subnet" "eks-publicsubnet1" {
  vpc_id            = aws_vpc.eks-poc.id
  cidr_block        = var.ekspublicsubnet1_cidr_block
  availability_zone = "us-east-1a"
  #required for EKS if we decide to launch the worker nodes in public subnet.
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-publicsubnet1"
    #need these two tags to create the loadbalancer and eks cluster in these subnets.
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "eks-publicsubnet2" {
  vpc_id            = aws_vpc.eks-poc.id
  cidr_block        = var.ekspublicsubnet2_cidr_block
  availability_zone = "us-east-1b"
  #required for EKS if we decide to launch the worker nodes in public subnet.
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-publicsubnet2"
    #need these two tags to create the loadbalancer and eks cluster in these subnets.
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "eks-privatesubnet1" {
  vpc_id            = aws_vpc.eks-poc.id
  cidr_block        = var.eksprivatesubnet1_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "eks-privatesubnet1"
    #need these two tags to create the loadbalancer and eks cluster in these subnets.
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "eks-privatesubnet2" {
  vpc_id            = aws_vpc.eks-poc.id
  cidr_block        = var.eksprivatesubnet2_cidr_block
  availability_zone = "us-east-1b"

  tags = {
    Name = "eks-privatesubnet2"
    #need these two tags to create the loadbalancer and eks cluster in these subnets.
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

#4
#----------------------------------------------------------------
#creating elastic Ip for nat gateway and the nategateway as well
#----------------------------------------------------------------

# we need to create the EIP for for our nat gateway

# Elastic IP for NAT Gateway
resource "aws_eip" "eks_nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.eks-IGW]
  tags = {
    Name = "eks_nat_eip"
  }
}

#Creating NAT Gateway
# the requirement for nat gateway is it should be placed in atleast one public subnets 

resource "aws_nat_gateway" "eks-NatGW" {
  allocation_id = aws_eip.eks_nat_eip.id
  subnet_id     = aws_subnet.eks-publicsubnet1.id

  tags = {
    Name = "eks-NatGW"
  }
}


# 5. create public routing table

resource "aws_route_table" "ekspublic-rt" {
  vpc_id = aws_vpc.eks-poc.id

  route {
    # target
    cidr_block = "0.0.0.0/0"
    # destination
    gateway_id = aws_internet_gateway.eks-IGW.id
  }

  tags = {
    Name = "ekspublic-rt"
  }
}

# 5. Associating public routing table with public subnets

#Associate public subnet with public routing tables

resource "aws_route_table_association" "rt_association_with_eks-publicsubnet1" {
  subnet_id      = aws_subnet.eks-publicsubnet1.id
  route_table_id = aws_route_table.ekspublic-rt.id
}

resource "aws_route_table_association" "rt_association_with_eks-publicsubnet2" {
  subnet_id      = aws_subnet.eks-publicsubnet2.id
  route_table_id = aws_route_table.ekspublic-rt.id
}


# 6. create private routing table

resource "aws_route_table" "eksprivate-rt" {
  vpc_id = aws_vpc.eks-poc.id

  route {
    # target
    cidr_block = "0.0.0.0/0"
    # destination
    gateway_id = aws_nat_gateway.eks-NatGW.id

  }

  tags = {
    Name = "eksprivate-rt"
  }
}


# 7. Associating private routing table with private subnets

#Associate private subnet with private routing tables

resource "aws_route_table_association" "rt_association_with_eks-privatesubnet1" {
  subnet_id      = aws_subnet.eks-privatesubnet1.id
  route_table_id = aws_route_table.eksprivate-rt.id
}

resource "aws_route_table_association" "rt_association_with_eks-privatesubnet2" {
  subnet_id      = aws_subnet.eks-privatesubnet2.id
  route_table_id = aws_route_table.eksprivate-rt.id
}




