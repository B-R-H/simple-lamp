output "ld-dns" {
    description = "DNS for the load ballencer"
  value = aws_lb.application_load_balancer.dns_name
}