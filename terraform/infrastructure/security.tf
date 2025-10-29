###########################################
# SECURITY GROUPS
###########################################

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_name}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-eks-cluster-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Security Group for EKS Nodes
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                                = "${var.project_name}-eks-nodes-sg"
    Environment                                         = var.environment
    ManagedBy                                           = "Terraform"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "owned"
  }
}

###########################################
# SECURITY GROUP RULES
###########################################

# Cluster to Nodes
resource "aws_security_group_rule" "cluster_to_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Allow all traffic from EKS cluster to nodes"
}

# Nodes to Cluster
resource "aws_security_group_rule" "nodes_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
  description              = "Allow nodes to communicate with cluster API"
}

# Nodes to Nodes
resource "aws_security_group_rule" "nodes_to_nodes" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow nodes to communicate with each other"
}