data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-db-*"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_security_group" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-db"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}
