variable "mock_ip" {
  default = ""
}

resource "null_resource" "check_public_ip" {
     provisioner "local-exec" {
     command = <<EOT
      if [ -z "${var.mock_ip}" ]; then
        echo "ERROR: Public IP address was not assigned." >&2
        exit 1
      fi
    EOT
  }

  //depends_on = [aws_instance.vm]
}

  
