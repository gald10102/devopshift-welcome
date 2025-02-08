#task 2 :Deploy an EC2 Instance in the Public Subnet
module "create_vpc_and_subnets" {
    source = "./modules/vpc"
    vpc_cidr_range = "10.0.0.0/16"
    subnet_count = 2
}

module "create_ec2" {
  source = "./modules/ec2"
  name = "gal1"
  set_public_ip = true
  instance_type = "t2.micro"
  subnet_id = module.create_vpc_and_subnets.get_subnet_id
  sg_id = module.create_vpc_and_subnets.get_sg_id
}