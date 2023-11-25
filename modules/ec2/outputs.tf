output "app_eip" {
  value = aws_eip.kindred_addr.*.public_ip
}

output "app_instance" {
  value = aws_instance.kindred_web.id
}