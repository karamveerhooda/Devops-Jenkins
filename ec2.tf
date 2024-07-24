resource "aws_security_group" "allow_jenkins" {
  name        = "allow_jenkins"
  description = "Allow Jenkins traffic using ingress and outgress"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_jenkins.name]

  tags = {
    Name = "JenkinsServer"
  }

  key_name = "EC2-Key"

 /* provisioner "file" {
    source      = "C:/Users/khooda/Downloads/EC2-Key.pem"
    destination = "/home/ec2-user/EC2-Key.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:/Users/khooda/Downloads/EC2-Key.pem")
      host        = self.public_ip
    }
  }*/

  provisioner "remote-exec" {
    inline = [
      //"#!/bin/bash",
      "sudo yum update -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
      "sudo yum upgrade -y",
      "sudo amazon-linux-extras install java-openjdk11 -y",
      "sudo yum install jenkins -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"     
      
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:/Users/khooda/Downloads/EC2-Key.pem") 
      host        = self.public_ip
      timeout     = "10m"
    }
  }
}

output "instance_ip" {
  value = aws_instance.jenkins_server.public_ip
}
output "instance_details" {
  value = {
    instance_id = aws_instance.jenkins_server.id
    public_ip   = aws_instance.jenkins_server.public_ip
    public_dns  = aws_instance.jenkins_server.public_dns
    private_ip  = aws_instance.jenkins_server.private_ip
    state       = aws_instance.jenkins_server.instance_state
  }
}
