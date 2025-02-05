provider "aws" {
  region = var.region
}

variable "region" {
  default = "us-east-1"
}

data "aws_ami" "find_yaniv_ami" {
  owners = [ "self" ]
  filter {
    name = "name"
    values = ["terraform-workshop-image-do-not-delete"]
  }

}


output "ami-" {
  value = data.aws_ami.find_yaniv_ami.id
}

