variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for main VPC"
  # default = "10.0.0.0/16"
}

variable "availability_zone" {
  type        = number
  description = "Number of availability zone"
  default     = 2
}

variable "public_subnets" {
  type = list(string)
  description = "List of public subnet for VPC"
}

# variable "private_subnets" {
#   type = list(string)
#   description = "List of private subnet for VPC"
# }

variable "env" {
  type = string
  description = "Environment of Infra on AWS"
}