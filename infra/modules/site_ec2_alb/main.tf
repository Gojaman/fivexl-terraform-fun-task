data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ---------- Security Groups ----------
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "ALB ingress"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "ec2" {
  name        = "${var.name}-ec2-sg"
  description = "EC2 web ingress from ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Optional SSH (only if key provided; still restricted to your IP is better, but optional)
  dynamic "ingress" {
    for_each = var.ssh_key_name == null ? [] : [1]
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- ALB ----------
resource "aws_lb" "alb" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = local.alb_subnets
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path    = "/"
    matcher = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ---------- EC2 (nginx + site) ----------
# Embed your site files directly into user_data (simple + no extra infra)
# We'll render index.html + style.css; you can extend if needed.

locals {
  index_html = file("${path.module}/../../../site/index.html")
  style_css  = file("${path.module}/../../../site/style.css")
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id = local.alb_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name

  user_data = <<-USERDATA
    #!/bin/bash
    set -e

    dnf -y update
    dnf -y install nginx

    mkdir -p /usr/share/nginx/html
    cat > /usr/share/nginx/html/index.html <<'HTML'
    ${local.index_html}
HTML

    cat > /usr/share/nginx/html/style.css <<'CSS'
    ${local.style_css}
CSS

    systemctl enable nginx
    systemctl restart nginx
  USERDATA

  # This makes Terraform replace the instance whenever the site hash changes
  tags = {
    Name     = "${var.name}-web"
    SiteHash = var.site_hash
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}

# Get details for each subnet so we can pick one per AZ (ALB requirement)
data "aws_subnet" "by_id" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

locals {
  # Group subnets by AZ (some accounts have multiple subnets per AZ)
  subnets_by_az = {
    for id, s in data.aws_subnet.by_id : s.availability_zone => s.id...
  }

  # Pick the first subnet id in each AZ
  alb_subnets = [for az, ids in local.subnets_by_az : ids[0]]
}
