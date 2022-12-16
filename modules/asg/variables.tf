variable "vpc_id" {
  type = string
}

variable "vpc_subnet_id" {
  type = list(string)
  description = "VPC subnet ID variable is passed from the outside for reusable purpose"
}

variable "env" {
  type = string 
  description = "Environment of our infrastructure"
}

variable "max_size" {
  type = number
  description = "Maximum number of Autoscaling Group"
}

variable "min_size" {
  type = number
  description = "Minimum number of Autoscaling Group"
}

variable "instance_type" {
  type = string
  description = "instance type that used in launch configuration or launch template of ASG"
}

variable "image_id" {
  type = string 
  description = "image id that used in launch configuration or launch template of asg"
}

variable "key_name" {
  type = string 
  description = "SSH keypem used for access EC2"
}

variable "desired_capacity"{ 
  type = number 
  description = "Number of desired instance we want in autoscaling group"
}