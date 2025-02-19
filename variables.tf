
variable "public_subnets" {
  description = "List of public subnet configurations"
  type        = list(object({
    cidr_block       = string
    name             = string
    availability_zone = string
  }))
    default = [{cidr_block = "10.0.3.0/24", name = "public-subnet-1", availability_zone = "eu-west-1a"},{cidr_block = "10.0.4.0/24", name = "public-subnet-2", availability_zone = "eu-west-1b"}]
    }

variable "private_subnets" {
  description = "List of private subnet configurations"
  type        = list(object({
    cidr_block       = string
    name             = string
    availability_zone = string
  }))
    default = [{cidr_block = "10.0.1.0/24", name = "private-subnet-1", availability_zone = "eu-west-1a"},{cidr_block = "10.0.2.0/24", name = "private-subnet-2", availability_zone = "eu-west-1b"}]
}

variable "node_port" {
    type = number
    description = "Holds container port for nodegroups pods"
}