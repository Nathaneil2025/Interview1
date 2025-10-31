# providers.tf

# -----------------------------------------------------------------------------
# 1. AWS EKS Cluster Auth Data Source (Needed by both providers)
# -----------------------------------------------------------------------------
data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

# -----------------------------------------------------------------------------
# 2. Kubernetes Provider Configuration
# Used for deploying Kubernetes objects (like Namespaces)
# -----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

# -----------------------------------------------------------------------------
# 3. Helm Provider Configuration (Correct Syntax)
# This uses the Kubernetes provider's configuration implicitly or explicitly.
# -----------------------------------------------------------------------------
provider "helm" {
  # Helm provider uses the configuration from the default Kubernetes provider block.
  # No 'kubernetes {}' block is required here if the 'kubernetes' provider is defined.
}