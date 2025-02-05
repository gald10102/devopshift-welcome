provider "aws" {
    region = var.region
}

terraform {
  required_providers{
    time = {
      source = "hashicorp/time"
      version = "0.12.1"
    }
  }
}

variable "region" {
    default = "us-east-1"
}

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
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "Gal-vm"
  }
}

resource "time_sleep" "wait_for_ip"{
  create_duration = "10s"
}

output "vm_public_ip" {
  value      = aws_instance.vm.public_ip
  depends_on = [null_resource.check_public_ip]
  description = "Public IP address of the VM"

}

resource "null_resource" "check_public_ip" {
     provisioner "local-exec" {
     command = <<EOT
      if [ -z "${aws_instance.vm.public_ip}" ]; then
        echo "ERROR: Public IP address was not assigned." >&2
        exit 1
      fi
    EOT
  }

  depends_on = [aws_instance.vm]
}



