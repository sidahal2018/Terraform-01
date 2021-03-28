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