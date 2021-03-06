provider "aws" {
  region = "us-east-1"
  default_tags {
   tags = {
     terraform = true
     owner       = "jmartinson@hashicorp.com"
     se-region       = "south"
     ttl     = 768
     hc-internet-facing = true
   }
 }
}

resource "aws_instance" "tfe" {
  ami           = "ami-05dc324761386f3a9"
  instance_type = "m5.xlarge"
  key_name = "jmartinson"
  associate_public_ip_address = true
  vpc_security_group_ids = ["jmartinson-tfe-sg"]
  root_block_device {
    volume_size           = "42"
  }
  tags = {
    Name = "tfe"
  }
  user_data = <<-EOF
#!/bin/bash
#curl https://install.terraform.io/ptfe/stable | sudo bash

EOF
}

resource "aws_instance" "splunk" {
  ami           = "ami-05dc324761386f3a9"
  instance_type = "m3.large"
  key_name = "jmartinson"
  associate_public_ip_address = true
  vpc_security_group_ids = ["jmartinson-tfe-sg"]
  root_block_device {
    volume_size           = "20"
  }
  tags = {
    Name = "splunk"
  }
  user_data = <<-EOF
#!/bin/bash
wget   https://d7wz6hmoaavd0.cloudfront.net/products/splunk/releases/8.2.2/linux/splunk-8.2.2-87344edfcdb4-linux-2.6-amd64.deb
#dpkg -i splunk-8.2.2-87344edfcdb4-linux-2.6-amd64.deb
EOF
}
  
}



resource "aws_security_group" "web-sg" {
  name = "jmartinson-tfe-sg"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8000
    to_port     = 8800
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


output "tfe_public_ip" {
  value       = aws_instance.tfe.public_ip
}

output "splunk_public_ip" {
  value       = aws_instance.splunk.public_ip
}
