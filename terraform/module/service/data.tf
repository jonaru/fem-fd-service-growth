data "aws_caller_identity" "this" {}

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_iam_policy_document" "execution_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "execution_policy" {
  statement {
    actions = ["ssm:GetParameters"]
    resources = concat(
      [for item in var.secrets : module.parameter_secure[item].ssm_parameter_arn]
    )
  }
}

data "aws_iam_policy_document" "task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "service_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs.amazonaws.com"]
      type        = "Service"
    }
  }
}
