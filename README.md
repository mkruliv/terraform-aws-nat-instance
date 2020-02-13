# AWS NAT Instance Terraform module

Terraform module which creates EC2 NAT instance on AWS.

These types of resources are supported:

## Terraform versions

Terraform 0.12.

## Usage

```hcl
module "nat_instance" {
  source              = "../"
  env_name            = "Test"
  key_pair            = "test-key"
  vpc_id              = module.app_vpc.vpc_id
  vpc_cidr            = module.app_vpc.vpc_cidr_block
  vpc_public_subnet   = module.app_vpc.public_subnets[0]
  vpc_private_subnets = module.app_vpc.private_subnets
  vpc_private_routes  = module.app_vpc.private_route_table_ids
  bastion_subnet_cidr = "10.20.0.0/16"
}
```

## Examples

* [Basic EC2 instance](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/tree/master/examples/basic)

## Notes


## Authors

Module managed by [Mykola Kruliv](https://github.com/mkruliv).

## License

Apache 2 Licensed. See LICENSE for full details.
