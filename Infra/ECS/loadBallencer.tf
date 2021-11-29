resource "aws_lb" "ECSLB" {
  name            = "example-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
  tags = {
    Name = "loadBallence"
    Enviroment = var.env-tag
  }
}

resource "aws_lb_target_group" "lamp" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ECS-VPC.id
  target_type = "ip"
  tags = {
    Name = "lbtg"
    Enviroment = var.env-tag
  }
}

resource "aws_lb_listener" "lamp" {
  load_balancer_arn = aws_lb.ECSLB.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lamp.id
    type             = "forward"
  }
  tags = {
    Name = "lblistener"
    Enviroment = var.env-tag
  }
}