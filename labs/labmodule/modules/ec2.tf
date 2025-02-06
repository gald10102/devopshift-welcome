provider "aws" {
 region = var.region
}

variable "region" {
 default = "us-east-1"
}

variable "ami" {}

variable "machine_type" {}


resource "aws_security_group" "sg" {
 ingress {
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }


 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}


resource "aws_instance" "vm" {
 ami           = var.ami
 instance_type = var.machine_type
 vpc_security_group_ids = [aws_security_group.sg.id]

 tags = {
   Name = "Gal-vm"
 }
}

output "vm_public_ip" {
 value       = aws_instance.vm.public_ip
 description = "Public IP address of the VM"
 depends_on = [ null_resource.check_public_ip ]
}


resource "null_resource" "check_public_ip" {
 provisioner "local-exec" {
   command = <<EOT
     if [ -z "${aws_instance.vm.public_ip}" ]; then
       echo "ERROR: Public IP address was not assigned." >&2
       exit 1
       else
       echo "We got the IP! ${aws_instance.vm.public_ip}"
     fi
   EOT
 }


 depends_on = [aws_instance.vm]
}

output "print_ami" {
  value = var.ami
}

output "print_region" {
  value = var.region
}