data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = "main-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  private_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  intra_subnets   = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]

  # Single NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  intra_dedicated_network_acl   = true
  intra_inbound_acl_rules       = var.intra_inbound_acl_rules
  intra_outbound_acl_rules      = var.intra_outbound_acl_rules
  private_dedicated_network_acl = true
  private_inbound_acl_rules     = var.private_inbound_acl_rules
  private_outbound_acl_rules    = var.private_outbound_acl_rules
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "poc" {
  name          = "poc"
  image_id      = data.aws_ami.amazon-linux.id
  instance_type = "t2.micro"
  user_data     = filebase64("user-data.sh")
  # security_group_names = [ aws_security_group.poc_instance.name ]
  vpc_security_group_ids = [aws_security_group.poc_instance.id]
  # do usuniecia
  key_name = data.aws_key_pair.poc.key_name

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "poc" {
  name             = "poc"
  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  vpc_zone_identifier = module.vpc.private_subnets

  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.poc.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "PoC"
    propagate_at_launch = true
  }
}

resource "aws_lb" "poc" {
  name               = "alb-poc"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.poc_lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "poc" {
  load_balancer_arn = aws_lb.poc.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "poc_tls" {
  load_balancer_arn = aws_lb.poc.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = data.aws_acm_certificate.cert.id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.poc.arn
  }
}

resource "aws_lb_target_group" "poc" {
  name     = "alb-poc"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  deregistration_delay = 30
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 5
    matcher             = 200
    protocol            = "HTTP"
    path                = "/"
    port                = 80
    timeout             = 2
    unhealthy_threshold = 2
  }
}


resource "aws_autoscaling_attachment" "poc" {
  autoscaling_group_name = aws_autoscaling_group.poc.id
  lb_target_group_arn    = aws_lb_target_group.poc.arn
}

resource "aws_security_group" "poc_instance" {
  name = "instance-poc"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.poc_lb.id]
  }

  # just for testing
  # ingress {
  #   from_port       = 22
  #   to_port         = 22
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.poc_lb.id]
  # }


  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat(var.secureweb_ips, var.repo_example_ips)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = module.vpc.intra_subnets_cidr_blocks
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "poc_lb" {
  name = "alb-poc"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # just for testing
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = var.ssh_allowed_ips
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id
}

data "aws_key_pair" "poc" {
  key_name = var.ssh_key_name
}