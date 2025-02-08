variable "instance_type"{
  type = string
  #user should enter instance type
}

variable "set_public_ip" {
  type = bool
  #user chooses if instance should get public ip
}

variable "name" {
  type = string
}

variable "subnet_id" {
  
}

variable "sg_id" {
  
}

resource "aws_instance" "create_ec2" {
  ami = "ami-0e1bed4f06a3b463d" #ubuntu 22.04 
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  associate_public_ip_address = var.set_public_ip
  tags = {
    Name = "${var.name}-ec2"
  }

}

output "print_ec2_public_ip" {
  value = aws_instance.create_ec2.public_ip
}