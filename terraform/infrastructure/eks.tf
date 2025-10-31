###########################################
# EKS CLUSTER
###########################################

resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    # It's recommended to use only private subnets for EKS control plane ENIs,
    # but using both public and private is acceptable if necessary.
    subnet_ids           = [aws_subnet.public.id, aws_subnet.private.id]
    security_group_ids   = [aws_security_group.eks_cluster.id]
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
  
  # REMOVED: lifecycle { ignore_changes = all }. Keep this removed unless
  # you are actively performing an import or a very specific temporary operation.
}

---

# EKS Access Entries (Modern Replacement for aws-auth ConfigMap)

# Grant access for the Node Group's IAM role (aws_iam_role.eks_nodes)
# This replaces the need for the manual ConfigMap update for nodes.
resource "aws_eks_access_entry" "node_group_access" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.eks_nodes.arn
  kubernetes_groups = ["system:bootstrappers", "system:nodes"]
  # The 'standard' type is appropriate for EKS Managed Node Group roles
  type          = "standard" 
}

# Grant access for the GitHub Actions IAM Role (Assuming you have this role defined elsewhere)
# You will need to define the GitHub Actions Role resource (e.g., aws_iam_role.github_actions)
/*
resource "aws_eks_access_entry" "github_actions_access" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.github_actions.arn
  kubernetes_groups = ["system:masters"] # Or a custom group for CI/CD access
}
*/

# The null_resource for aws-auth is now entirely removed.
# resource "null_resource" "update_aws_auth" is DELETED

---

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
  
  # REMOVED: lifecycle { ignore_changes = all }
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
  
  # REMOVED: lifecycle { ignore_changes = all }
}

---

# EKS Addons
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "aws-ebs-csi-driver"
  # Corrected for the deprecation of 'resolve_conflicts'
  resolve_conflicts_on_create = "OVERWRITE" 
  resolve_conflicts_on_update = "OVERWRITE"
}