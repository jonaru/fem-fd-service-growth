module "staging" {
  source = "./module/environment"

  bastion_ingress = ["162.232.14.171/32"]
  name            = "staging"
}

# module "staging" {
#   source = "./module/environment"
#
#   bastion_ingress = ["162.232.14.171/32"]
#   name            = "staging"
# }
