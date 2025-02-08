#task1 : Create a Custom VPC with Public & Private Subnets

module "create_vpc_and_subnets" {
    source = "./modules/vpc"
    vpc_cidr_range = "10.0.0.0/16"
    subnet_count = 2
}

