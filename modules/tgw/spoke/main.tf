# Create the Transit Gateway, route table associations/propagations, and static TGW routes in the `network` account.
# Enable sharing the Transit Gateway with the Organization using Resource Access Manager (RAM).
# If you would like to share resources with your organization or organizational units,
# then you must use the AWS RAM console or CLI command to enable sharing with AWS Organizations.
# When you share resources within your organization,
# AWS RAM does not send invitations to principals. Principals in your organization get access to shared resources without exchanging invitations.
# https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html

locals {
  spoke_account = module.this.tenant != null ? format("%s-%s-%s", module.this.tenant, module.this.environment, module.this.stage) : format("%s-%s", module.this.environment, module.this.stage)
}

module "tgw_hub_routes" {
  source  = "cloudposse/transit-gateway/aws"
  version = "0.10.0"

  providers = {
    aws = aws.tgw-hub
  }

  ram_resource_share_enabled = false
  route_keys_enabled         = false

  create_transit_gateway                                         = false
  create_transit_gateway_route_table                             = false
  create_transit_gateway_vpc_attachment                          = false
  create_transit_gateway_route_table_association_and_propagation = true

  config = {
    (local.spoke_account) = module.tgw_spoke_vpc_attachment.tg_config,
  }

  existing_transit_gateway_route_table_id = module.tgw_hub.outputs.transit_gateway_route_table_id

  context = module.this.context
}

module "tgw_spoke_vpc_attachment" {
  source = "./modules/standard_vpc_attachment"

  owning_account          = local.spoke_account
  own_vpc_component_name  = var.own_vpc_component_name
  own_eks_component_names = var.own_eks_component_names

  tgw_config           = module.tgw_hub.outputs.tgw_config
  tgw_connector_config = module.cross_region_hub_connector
  connections          = var.connections
  expose_eks_sg        = var.expose_eks_sg
  peered_region        = var.peered_region


  context = module.this.context
}
