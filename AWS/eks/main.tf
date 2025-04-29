resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_iam_role_arn != "" ? var.cluster_iam_role_arn : aws_iam_role.eks_cluster[0].arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = var.enable_cluster_log_types

  tags = var.cluster_tags
}

resource "aws_iam_role" "eks_cluster" {
  count = var.cluster_iam_role_arn == "" ? 1 : 0

  name = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json

  tags = {
    Name = "${var.cluster_name}-eks-cluster"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  count = var.cluster_iam_role_arn == "" ? 1 : 0
  role  = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Managed Node Groups
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = var.node_role_arn != "" ? var.node_role_arn : aws_iam_role.node_group[each.key].arn

  subnet_ids = var.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  tags = merge(var.node_group_tags, {
    Name = "${var.cluster_name}-${each.key}"
  })
}

# IAM Role for Node Groups
resource "aws_iam_role" "node_group" {
  for_each = var.node_role_arn == "" ? var.node_groups : {}

  name = "${var.cluster_name}-${each.key}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json

  tags = {
    Name = "${var.cluster_name}-${each.key}-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "node_group" {
  for_each = var.node_role_arn == "" ? var.node_groups : {}

  role       = aws_iam_role.node_group[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_group_cni" {
  for_each = var.node_role_arn == "" ? var.node_groups : {}

  role       = aws_iam_role.node_group[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_group_ecr" {
  for_each = var.node_role_arn == "" ? var.node_groups : {}

  role       = aws_iam_role.node_group[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
