variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "eks-flask-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "192.168.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "192.168.1.0/24"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Desired number of nodes per node group"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes per node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes per node group"
  type        = number
  default     = 3
}