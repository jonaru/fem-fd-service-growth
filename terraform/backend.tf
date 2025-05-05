terraform {
  backend "s3" {
    bucket = "terraform-fem-fd-service"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}
