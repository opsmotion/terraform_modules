resource "aws_security_group" "ssh_ec2_jenkins" {
  name = "ssh_ec2_jenkins"

  # Inbound HTTP from anywhere
  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound ssh from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  count         = "${var.count}"
  ami           = "${var.ami}"           #Ubuntu 16.04
  instance_type = "${var.instance_type}"

  tags {
    Name = "${format("jenkins-%01d",count.index+1)}"
  }

  security_groups = ["${aws_security_group.ssh_ec2_jenkins.name}"]
  key_name = "${var.key_name}"

# Left in place but #'d out for future updates.
  provisioner "file" {
    source      = "files/jenkins_install.sh"
    destination = "/tmp/jenkins_install.sh"
  }

# Replaced by the script jenkins_install.sh
#  provisioner "remote-exec" {
#    inline = [
#      # Installing Gitlab:
#      "sudo apt update -yq",
#    ]
#  }
    provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/jenkins_install.sh",
          "sudo /tmp/jenkins_install.sh"
        ]
    }

  # Setup user access via SSH
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${var.private_key_path}")}"
    timeout     = "2m"
    agent       = false
  }
}
