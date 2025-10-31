# providers.tf

# -----------------------------------------------------------------------------
# 1. AWS EKS Cluster Auth Data Source
# -----------------------------------------------------------------------------
data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

# -----------------------------------------------------------------------------
# 2. Kubernetes Provider Configuration
# -----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

# -----------------------------------------------------------------------------
# 3. Helm Provider Configuration 
# No kubernetes block needed here; it should inherit from the kubernetes provider above.
# If this still fails, we'll confirm version constraints.
# -----------------------------------------------------------------------------
provider "helm" {}