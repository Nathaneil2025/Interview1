###########################################
# EKS CLUSTER
###########################################

resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = [aws_subnet.public.id, aws_subnet.private.id]
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Ensure IAM roles and network are ready before creating cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
    aws_subnet.public,
    aws_subnet.private,
    aws_internet_gateway.main,
    aws_nat_gateway.main
  ]
}

###########################################
# EKS NODE GROUPS
###########################################

# Public Node Group
resource "aws_eks_node_group" "public" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-public-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_subnet.public.id]

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = [var.node_instance_type]

  tags = {
    Name        = "${var.project_name}-public-node-group"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Ensure IAM policies are attached before creating node group
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
    aws_eks_cluster.main
  ]
}

# Private Node Group
resource "aws_eks_node_group" "private" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-private-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_subnet.private.id]

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = [var.node_instance_type]

  tags = {
    Name        = "${var.project_name}-private-node-group"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Ensure IAM policies are attached before creating node group
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
    aws_eks_cluster.main
  ]
}