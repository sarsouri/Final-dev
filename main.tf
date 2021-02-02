# Configure the AWS Provider
provider "aws" {
    region =  var.availability_zone_names[2]
    access_key = var.access_key_var
    secret_key = var.secret_key_var
}

# # 1. Create vpc - Virtual Private Cloud 
resource "aws_vpc" "fursa" {
  cidr_block = var.vpc_ip   # 10.10.0.0 netmask 255.255.0.0 
}
# # 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.fursa.id
}
# # 3. Create Custom Route Table
resource "aws_route_table" "fursa-route-table" {
  vpc_id = aws_vpc.fursa.id

  route {
    cidr_block = "0.0.0.0/0" # IPv4
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0" #IPv6
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "fursa"
  }
}

# # 4. Create a Subnets
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.fursa.id
  cidr_block        = var.subnets_names[0] # Class C: 255.255.255.0 
  availability_zone = var.availability_zone_names[0] # Availability Zone 
  tags = {
    Name = "subnet1"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.fursa.id
  cidr_block        = var.subnets_names[1] # Class C: 255.255.255.0 
  availability_zone = var.availability_zone_names[1] # Availability Zone 
  tags = {
    Name = "subnet1"
  }
}


# Design to fail 
# # 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.fursa-route-table.id
}

# # 6. Create Security Group to allow port 22,80,443,5000
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.fursa.id

  ingress {
    description = "HTTPS"
    from_port   = 443  # 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "docker"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "docker"
    from_port   = 3002
    to_port     = 3002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "docker"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}
# # 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet1.id
  private_ips     = ["10.10.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}
# # 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.10.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

# # 9. Create Ubuntu server and install/enable docker
resource "aws_instance" "web-server-instance" {
  ami               = var.image_id
  instance_type     = "t2.micro"
  availability_zone = var.availability_zone_names[0]
  key_name          = var.KeyName

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
 }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install docker.io -y
                chown ubuntu home/ubuntu
                EOF

    # commands to run after creating the Ubuntu server
  provisioner "remote-exec" {
    # commands to build the python image and run it
    inline = [
      "sudo apt update -y",
      "sudo apt install docker.io -y",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo apt install git-all -y",
      "git clone https://github.com/ibraheemsar/currency_swap.git",
      "cd currency_swap",
      "sudo docker-compose up -d --build"
    ]
  connection {
    user = "ubuntu"
    host = aws_instance.web-server-instance.public_ip
    type = "ssh"
    private_key = "${file("C:/Users/ibraheem/ibr.pem")}"
    agent = false
  }
} 

#Load Balancer
resource "aws_lb" "test" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}
#target group
resource "aws_lb_target_group" "tgTest" {
  name     = "ATG"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.fursa.id
}
#attatching target group to load balancer
resource "aws_lb_target_group_attachment" "ATtest" {
  target_group_arn = aws_lb_target_group.tgTest.arn
  target_id        = aws_instance.web-server-instance.id
  port             = 5000
}



