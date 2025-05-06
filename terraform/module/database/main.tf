module "this" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.12.0"

  allocated_storage                   = 50
  create_db_option_group              = false
  create_db_parameter_group           = false
  create_db_subnet_group              = false
  create_monitoring_role              = false
  db_subnet_group_name                = var.vpc_name
  engine                              = "postgres"
  engine_version                      = "17.2"
  iam_database_authentication_enabled = false
  identifier                          = var.name
  instance_class                      = "db.t4g.micro"
  max_allocated_storage               = 100
  option_group_name                   = "default:postgres-17"
  parameter_group_name                = "default.postgres17"
  publicly_accessible                 = false
  skip_final_snapshot                 = true
  username                            = replace(var.name, "-", "_")
  vpc_security_group_ids              = var.security_groups
}
