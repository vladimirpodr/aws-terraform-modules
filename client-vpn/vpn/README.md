# AWS Client VPN

This module creates AWS Client VPN with split-tunnel and authorize ingress via provisioner

## HOW use
    openvpn --config /config_from_download_client_configuration_in_aws  --cert /tmp/client_cert.cert  --key /tmp/client_key.pem
     Files in folder /tmp will be created automatically by terraform and you should  move they to other location

## Inputs
| Name | Description | Type | Default | Required |Example|
|------|-------------|:----:|:-----:|:-----:|:-----:|
|environment_name|Environment name|string||yes|dev|
|zone_name|Zone name|string||yes|vpn|
|aws_region|AWS region name|string||yes|eu-west-1|
|client_cidr_block| CIDR block for clients OpenVPN|string||yes|10.243.0.0/16|
|aws_subnet_assoc||list of subnet|list(string)|yes|["subnet-01a0ef315cb2a990e", "subnet-0ea3dc0bc6f79e2dd", "subnet-0a71a9bed14371b02"]
|domain_name|Domain name for OpenVPN| string|yes|ait-internal.com|
|org_name|Name of Organization|string||yes|MyOrganizations|
|count_per_subnet|number of subnet to associate with vpn client|int|yes|2
|vpc_cidr| CIDR of your VPC to associate with vpn|string|10.95.0.0/16



## Example
```hcl
module "client_vpn" {
  source = "git::ssh://git@bitbucket.org/automatitdevops/terraform-modules.git//aws/client_vpn"
  zone_name                       = "${var.zone_name}"
  environment_name                = "${var.environment_name}"
  client_cidr_block               = "${var.client_cidr_block}"
  aws_subnet_assoc                = "${var.aws_subnet_assoc}"  
  domain_name                     = "${var.domain_name}"
  org_name                        = "${var.org_name}"
  count_per_subnet                = "${var.count_per_subnet}"
  vpc_cidr                        = "${var.vpc_cidr}"

}
```

