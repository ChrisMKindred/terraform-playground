output "app_eip" {
  value = aws_eip.kindred_addr.*.public_ip
}

output "app_instance" {
  value = aws_instance.kindred_web.id
}

output "security_group_public" {
  value = aws_security_group.public.id
}
 
output "security_group_private" {
  value = aws_security_group.private.id
}