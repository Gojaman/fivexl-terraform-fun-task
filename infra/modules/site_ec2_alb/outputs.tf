output "alb_url" {
  value = "http://${aws_lb.alb.dns_name}"
}

output "instance_id" {
  value = aws_instance.web.id
}
