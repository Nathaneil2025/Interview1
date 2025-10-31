# monitoring.tf

# Deploy Prometheus + Grafana using Helm after cluster is ready
resource "null_resource" "deploy_monitoring" {
  provisioner "local-exec" {
    command = <<-EOT
      # Configure kubectl
      aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}
      
      # Create monitoring namespace
      kubectl create namespace monitoring || echo "Namespace already exists"
      
      # Add Prometheus Helm repo
      helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
      helm repo update
      
      # Install kube-prometheus-stack
      helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --version 57.0.0 \
        --values ${path.module}/monitoring-values.yaml \
        --wait \
        --timeout 10m
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.public,
    aws_eks_node_group.private,
    null_resource.update_aws_auth
  ]

  triggers = {
    cluster_id = aws_eks_cluster.main.id
    values_hash = filemd5("${path.module}/monitoring-values.yaml")
  }
}

# Output Grafana LoadBalancer URL
resource "null_resource" "get_grafana_url" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for Grafana LoadBalancer to be ready..."
      sleep 60
      
      GRAFANA_URL=$(kubectl get svc -n monitoring prometheus-grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "LoadBalancer not ready yet")
      
      echo "============================================"
      echo "Grafana URL: http://$GRAFANA_URL"
      echo "Username: admin"
      echo "Password: D3xt3r!@1944"
      echo "============================================"
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [null_resource.deploy_monitoring]

  triggers = {
    monitoring_deployed = null_resource.deploy_monitoring.id
  }
}