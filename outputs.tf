output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.tic_tac_toe.dns_name
}