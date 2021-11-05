
resource "aws_key_pair" "fp-key" {
  key_name   = "fp-key"
  public_key = var.ssh_key
}

resource "aws_vpc" "fp-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "fp-vpc"
  }
}


resource "aws_subnet" "fp-public-subnet-1" {
  vpc_id            = aws_vpc.fp-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "fp-public-subnet-1"
  }
}

resource "aws_subnet" "fp-public-subnet-2" {
  vpc_id            = aws_vpc.fp-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "fp-public-subnet-2"
  }
}

resource "aws_internet_gateway" "fp-ig" {
  vpc_id = aws_vpc.fp-vpc.id

  tags = {
    Name = "fp-gw"
  }
}

resource "aws_route_table" "fp-rt" {
  vpc_id = aws_vpc.fp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fp-ig.id
  }

  tags = {
    Name = "fp-route_table"
  }

}

resource "aws_route_table_association" "to-public-subnet-1" {
  subnet_id      = aws_subnet.fp-public-subnet-1.id
  route_table_id = aws_route_table.fp-rt.id
}

resource "aws_route_table_association" "to-public-subnet-2" {
  subnet_id      = aws_subnet.fp-public-subnet-2.id
  route_table_id = aws_route_table.fp-rt.id
}


resource "aws_security_group" "fp-sg-1" {
  name   = "fp-sg"
  vpc_id = aws_vpc.fp-vpc.id

}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.fp-sg-1.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allows all HTTP traffic"

}

resource "aws_security_group_rule" "outbound_all-1" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.fp-sg-1.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "fp-sg-2" {
  name   = "fp-sg-2"
  vpc_id = aws_vpc.fp-vpc.id

}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.fp-sg-2.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow ssh from everywhere"

}

resource "aws_security_group_rule" "inbound_http-2" {
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.fp-sg-2.id
  to_port                  = 80
  type                     = "ingress"
  source_security_group_id = aws_security_group.fp-sg-1.id
  description              = "allow http from ALB"

}

resource "aws_security_group_rule" "outbound_all-2" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.fp-sg-2.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_s3_bucket" "fp-terrabucket" {
  bucket = "fp-terrabucket"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "fp-object-image-default" {
  bucket = "fp-terrabucket"
  key    = "default/default.jpg"
  source = "/root/final-project/default/default.jpg"
}

resource "aws_s3_bucket_object" "fp-object-index-default" {
  bucket = "fp-terrabucket"
  key    = "default/index-default.html"
  source = "/root/final-project/default/default-index.html"
}


resource "aws_s3_bucket_object" "fp-object-images" {
  bucket = "fp-terrabucket"
  key    = "images/einstein.jpg"
  source = "/root/final-project/pictures/einstein.jpg"
}

resource "aws_s3_bucket_object" "fp-object-index-image" {
  bucket = "fp-terrabucket"
  key    = "images/index-image.html"
  source = "/root/final-project/pictures/index-image.html"
}

resource "aws_s3_bucket_object" "fp-object-videos" {
  bucket = "fp-terrabucket"
  key    = "videos/funny_guy.mp4"
  source = "/root/final-project/videos/funny_guy.mp4"
}

resource "aws_s3_bucket_object" "fp-object-index-video" {
  bucket = "fp-terrabucket"
  key    = "videos/index-video.html"
  source = "/root/final-project/videos/index-video.html"
}


resource "aws_instance" "fp-default-page" {
  ami           = "ami-0443305dabd4be2bc"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  user_data = <<EOF
  #!/bin/bash
  sudo yum install -y httpd
  cd /var/www/html/
  sudo wget https://fp-terrabucket.s3.us-east-2.amazonaws.com/default/default.jpg
  sudo wget https://fp-terrabucket.s3.us-east-2.amazonaws.com/default/index-default.html
  sudo mv index-default.html index.html
  sudo systemctl enable httpd --now
  EOF
  vpc_security_group_ids = ["${aws_security_group.fp-sg-2.id}"]
  subnet_id = aws_subnet.fp-public-subnet-1.id
  key_name        = "fp-key"
    tags = {
    Name = "fp-default-page"
  }

}


data "aws_instance" "fp-default-page" {
  instance_id = "fp-default-page"

  filter {
    name   = "ec2-id"
    values = ["fp-default"]
  }
}
/*
resource "aws_launch_configuration" "fp-lc-images" {
  name_prefix     = "fp-lc-images"
  image_id        = "ami-0443305dabd4be2bc"
  instance_type   = "t2.micro"
  associate_public_ip_address = true
  user_data       = <<EOF
  #!/bin/bash
  sudo yum install -y httpd
  cd /var/www/html/
  sudo mkdir images
  cd images
  sudo wget https://fp-terrabucket.s3.us-east-2.amazonaws.com/images/einstein.jpg
  sudo wget https://fp-terrabucket.s3.us-east-2.amazonaws.com/images/index-image.html
  sudo mv index-image.html index.html
  sudo systemctl enable httpd --now
  EOF
  security_groups = ["${aws_security_group.fp-sg-2.id}"]
  key_name        = "fp-key"
}

resource "aws_launch_configuration" "fp-lc-videos" {
  name_prefix     = "fp-lc-videos"
  image_id        = "ami-0443305dabd4be2bc"
  associate_public_ip_address = true
  instance_type   = "t2.micro"
  user_data       = <<EOF
  #!/bin/bash
  sudo yum install -y httpd
  cd /var/www/html/
  sudo mkdir videos
  cd videos
  sudo wget https://fp-terrabucket.s3.us-east-2.amazonaws.com/videos/funny_guy.mp4
  sudo wget https://fp-terrabucket.s3.us-east-2.amazonaws.com/videos/index-video.html
  sudo mv index-video.html index.html
  sudo systemctl enable httpd --now
  EOF
  security_groups = ["${aws_security_group.fp-sg-2.id}"]
  key_name        = "fp-key"
  
}

resource "aws_autoscaling_group" "fp-asg-images" {
  name                      = "fp-asg-images"
  desired_capacity          = 1
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = aws_launch_configuration.fp-lc-images.name
  vpc_zone_identifier       = [aws_subnet.fp-public-subnet-1.id, aws_subnet.fp-public-subnet-2.id]

  tag {
    key                 = "Name"
    value               = "fp-images"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "fp-asg-videos" {
  name                      = "fp-asg-videos"
  desired_capacity          = 1
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = aws_launch_configuration.fp-lc-videos.name
  vpc_zone_identifier       = [aws_subnet.fp-public-subnet-1.id, aws_subnet.fp-public-subnet-2.id]

  tag {
    key                 = "Name"
    value               = "fp-videos"
    propagate_at_launch = true
  }
}

*/

resource "aws_lb_target_group" "fp-target-group-default" {
  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "fp-target-group-default"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.fp-vpc.id
}

resource "aws_lb_target_group_attachment" "fp-attach-default" {
  target_group_arn = aws_lb_target_group.fp-target-group-default.arn
  target_id        = "i-00c2f17287d596a5e"
  port             = 80
}


resource "aws_eip" "fp-eip-for-ec2" {
  instance = "i-00c2f17287d596a5e"
  vpc = true
}
/*

resource "aws_lb_target_group" "fp-target-group-images" {
  health_check {
    interval            = 10
    path                = "/images/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "fp-target-group-images"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.fp-vpc.id
}

resource "aws_lb_target_group_attachment" "fp-attach-images" {
  target_group_arn = aws_lb_target_group.fp-target-group-images.arn
  target_id        = "i-0bc526c3cb36fd5c1"
  port             = 80
}

resource "aws_eip" "fp-eip-for-ec2-1" {
  instance = "i-0bc526c3cb36fd5c1"
  vpc = true
}



resource "aws_lb_target_group" "fp-target-group-videos" {
  health_check {
    interval            = 10
    path                = "/videos/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "fp-target-group-videos"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.fp-vpc.id
}

resource "aws_lb_target_group_attachment" "fp-attach-videos" {
  target_group_arn = aws_lb_target_group.fp-target-group-videos.arn
  target_id        = "i-043e55cfa9fe34997"
  port             = 80
}

resource "aws_eip" "fp-eip-for-ec2-2" {
  instance = "i-043e55cfa9fe34997"
  vpc = true
}

resource "aws_lb" "fp-alb" {
  name            = "fp-alb"
  internal        = false
  security_groups = [aws_security_group.fp-sg-1.id]
  subnets         = [aws_subnet.fp-public-subnet-1.id, aws_subnet.fp-public-subnet-2.id]

  tags = {
    Name = "fp-alb"
  }

  ip_address_type    = "ipv4"
  load_balancer_type = "application"

}

resource "aws_lb_listener" "fp-lb-listener" {
  load_balancer_arn = aws_lb.fp-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.fp-target-group-default.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "images" {
  listener_arn = aws_lb_listener.fp-lb-listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fp-target-group-images.arn
  }
  condition {
    path_pattern {
      values = ["/images/*"]
    }
  }


}

resource "aws_lb_listener_rule" "videos" {
  listener_arn = aws_lb_listener.fp-lb-listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fp-target-group-videos.arn
  }
  condition {
    path_pattern {
      values = ["/videos/*"]
    }
  }


}
*/
