module "create_ec2" {
  source = "./modules"
  ami = "ami-0c02fb55956c7d316"
  machine_type = "t2.micro"
}

output "print_module_ami" {
  value = module.create_ec2.print_ami
}
output "print_module_publicIP" {
  value = module.create_ec2.vm_public_ip
}
output "print_module_region" {
  value = module.create_ec2.print_region
}