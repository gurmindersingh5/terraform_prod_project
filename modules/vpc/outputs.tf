output "private_subnet_id1" {
  value = aws_subnet.private_subnet_1.id
  description = "ID of the first private subnet"
}

output "private_subnet_id2" {
  value = aws_subnet.private_subnet_2.id
  description = "ID of the second private subnet"
}

output "public_subnet_id1" {
  value = aws_subnet.public_subnet_1.id
  description = "ID of the first public subnet"
}

output "public_subnet_id2" {
  value = aws_subnet.public_subnet_2.id
  description = "ID of the second public subnet"
}

output "vpc_id" {
  value = aws_vpc.vpc_terraform_project.id
  description = "ID of the vpc"
}


