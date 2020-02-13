variable env_name {

}


variable vpc_id {

}

variable vpc_cidr {

}

variable vpc_public_subnet {

}

variable key_pair {
  description = "Select the key pair to use"
}

variable nat_instance_type {
  description = "Select the instance type"
  default     = "t2.nano"
}

variable nat_ebs_root_size {
  description = "Select the ebs root size"
  default     = 8
}

variable nat_ebs_root_type {
  description = "Select the ebs root type"
  default     = "gp2"
}

variable vpc_private_subnets {
}

variable vpc_private_routes {
}

variable bastion_subnet_cidr {
}