provider "aws" {
  region = var.region
  shared_credentials_file = "/home/ubuntu/.aws/credentials"
  # profile                 = "default"
    
  default_tags {
    tags = {
      bootcamp   = "poland1"
      created_by = "Maksymilian Wegrzyn"
    }
  }
}
terraform {
  backend "s3" {
    bucket = "max-s3-bucket"
    key    = "tfstate"
    region = "eu-north-1"
  }
}

locals {
  instance_name = "Max-TED-search-${terraform.workspace}-instance"
}

##################   RESOURCES   ##########################
###########################################################

resource "aws_subnet" "embedash_subnet" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Max-embedash_subnet"
  }
}

resource "aws_instance" "embedash_instance" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.keypair
  security_groups = var.security_groups
  subnet_id = aws_subnet.embedash_subnet.id
  
  user_data = file("./docker_ec2.sh")


  tags = {
    Name = local.instance_name
  }
  volume_tags = {
    bootcamp = "poland1"
    created_by = "Maksymilian Wegrzyn"
    Name = "Max-embedash_instance_vol"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file(var.private_key)
    host     = self.public_ip
    timeout  = "5m"
  }

  provisioner "file" {
  source      = "./docker-compose.yml"
  destination = "/home/ubuntu/docker-compose.yml"
  }
  provisioner "file" {
  source      = "./nginx.conf"
  destination = "/home/ubuntu/nginx.conf"
  }
  provisioner "file" {
  source      = "./docker_ec2.sh"
  destination = "/home/ubuntu/docker_ec2"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.embedash_instance.id
  allocation_id = var.eipalloc
}
