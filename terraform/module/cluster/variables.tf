variable "capacity_providers" {
  default = {}
  type    = map(any)
}

variable "name" {
  type = string
}

variable "vpc_name" {
  type = string
}
