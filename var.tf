variable "AWS_REGION" {default = "us-west-1"}
variable "KEY_NAME" {default = "EC2key"}
variable "AWS_INATANCE" {default="t2.micro"}


provider "aws" { 
    region = "${var.AWS_REGION}"
}

resource "aws_instance" "test-server"{
    ami           = "ami-0019ef04ac50be30f"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public_us1a.id}"
    key_name = "${var.KEY_NAME}"
    vpc_security_group_ids = ["${aws_security_group.goldensecurity.id}"]
}

resource "aws_security_group" "goldensecurity" {
  vpc_id = "${aws_vpc.main.id}"
  name = "goldensecurity"
  description = "You are doodoo"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      }

    ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        from_port = 80
        to_port = 80
        protocol="tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        from_port = 8080
        to_port = 8080
        protocol="tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        from_port = 8000
        to_port = 8000
        protocol="tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
tags {
    Name = "ssh_ping"
  }
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
    tags {
        Name = "vpcpg-vpc"
    }
}
resource "aws_internet_gateway" "main-gw" {
    vpc_id = "${aws_vpc.main.id}"
    tags {
        Name = "main"
    }
}
resource "aws_route_table" "main-public" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-gw.id}"
    }
    tags {
        Name = "main-public-1"
    }
}
resource "aws_route_table_association" "main-public-1-a" {
    subnet_id = "${aws_subnet.public_us1a.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}
resource "aws_subnet" "public_us1a" {
    cidr_block = "10.0.1.0/24"
  availability_zone = "${var.AWS_REGION}a"
    vpc_id = "${aws_vpc.main.id}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "vpcpg subnet for ${var.AWS_REGION}a"
    }
}