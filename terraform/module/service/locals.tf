locals {
  fullname = "${var.cluster_name}-${var.name}"

  tags = merge(
    var.tags,
    {
      ClusterName = var.cluster_name
      Name        = var.name
    }
  )
}
