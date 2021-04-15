variable "vpc_cidr_block" {
  description = "cidr block for eks vpc"
  default     = "10.200.0.0/21"
}

variable "ekspublicsubnet1_cidr_block" {
  description = "cidr block for eks public subnet 1"
  default     = "10.200.0.0/23"
}
variable "ekspublicsubnet2_cidr_block" {
  description = "cidr block for eks public subnet 2"
  default     = "10.200.2.0/23"
}

variable "eksprivatesubnet1_cidr_block" {
  description = "cidr block for eks private subnet 1"
  default     = "10.200.4.0/23"
}

variable "eksprivatesubnet2_cidr_block" {
  description = "cidr block for eks private subnet 2"
  default     = "10.200.6.0/23"
}