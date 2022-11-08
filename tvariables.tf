variable region {
  description = "select different region for production and developing"
}
variable "vpc_id" {
  description = "ID of devops server VPC, no need to create new one"
}
variable "subnet_cidr_block" {
  description = "value"
}
variable "ami" {
  description = "value"
}
variable "instance_type" {}
variable "keypair" {}
variable "security_groups" {
  description = "Using the same as devops server"
}
variable "private_key" {
  
}
variable availability_zone {}
variable "eipalloc" {}
variable "backend_env" {}