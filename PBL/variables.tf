variable "region" {
    default = "us-east-2" 
}
variable "vpc_cidr" {
  default = "10.0.0.0/16" 
}

variable "enable_dns_hostnames" {
  default = true

}
variable "enable_dns_support"{
  default = true
}
variable "enable_classiclink" {
    default = false
}

variable "enable_classiclink_dns_support" {
  default = false
}
variable "preferred_number_of_public_subnets" {
    default = null
  
}
variable "preferred_number_of_private_subnets_1" {
      default = null
}

variable "environment" {
      default = null
}

variable "my_key_pair_name" {
 default =  "siki"
}

variable "ingressrules" {
  type = list(number)
  default = [22,80]
}
variable "egressrules" {
  type = list(number)
  default = [0]
}
variable "cidr_route-table" {
  default= "0.0.0.0/0"
}
variable "cidr_all_traffic" {
  default= ["0.0.0.0/0"]
}
variable "allow_myip" {
  default= ["71.173.193.5/32"]
}
variable "egress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}
variable "ingress_rules_lb"{
default =  [{
      from_port  = 80
     to_port     = 80
     protocol    = "tcp"
     description = "Port 80"
	}]
}
variable "ingress_rules_bastion"{
default =  [{
     from_port  = 22
     to_port    = 22
     protocol   = "tcp"
     description = "Port 22"
	}]
}