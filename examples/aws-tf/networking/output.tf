# ---networking/outputs.tf

output "vpc_id" {
  value = aws_vpc.k0s_vpc.id
}

output "public_sg" {
  value = aws_security_group.k0s_sg["public"].id
}

output "public_subnets" {
  value = aws_subnet.k0s_public_subnet.*.id
}