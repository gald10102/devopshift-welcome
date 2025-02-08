module "create_vpc_and_subnets" {
    source = "./modules/vpc"
    vpc_cidr_range = "10.0.0.0/16"
    subnet_count = 2
}

module "creating_ALB_and_Scaling_Group" {
  source = "./modules/lb"
  sg = module.create_vpc_and_subnets.get_sg_id
  subnet_id_list = module.create_vpc_and_subnets.subnets_ids
  vpc_id = module.create_vpc_and_subnets.get_vpc_id

}

output "printing_lb_dns" {
  value = "LoadBalancer DNS is: ${module.creating_ALB_and_Scaling_Group.alb_dns_name}"
}

