=======================================================
MODULES: Transit Gateway and Transit Gateway Attachment
=======================================================

General
=======

``transit-gateway/gateway`` module creates a Transit Gateway to inter-connect different project
VPCs together.  Companion ``transit-gateway/attachment`` module handles Transit Gateway Attachment
to connect a particular VPC to the Transit Gateway.

Copyright (c) 2020 Automat-IT



Limitations
===========

For now only the simplest possible case is covered: a single-account Transit Gateway connecting
several VPCs to each other. Dynamic route propagation and other advanced features are not covered
by these modules.



``transit-gateway/gateway`` module
==================================

This creates a simple Transit Gateway, tagging it appropriately.


Requirements
------------

Requires `Terraform Null Provider`_ and `AWS CLI`_ to work, as tagging the default Transit Gateway
Route Table is not implemented by Terraform's AWS Provider.


Parameters
----------

``name``, ``tags``
  Base name and tags to assign to the resources

``description``
  Description of the Transit Gateway


Outputs
-------

``id``, ``rt_id``
  ID of the Transit Gateway and its default route table


Example
-------

A Transit Gateway usually belongs to Management VPC environment. To create a Transit Gateway and
return it as an output for other VPCs to attach, ``environment/mgmt/transit-gateway.tf`` may look
as follows::

  ### Providers
  # FIXME: Move to main.tf
  provider "null" {
    version = "~> 2.1"
  }

  ### Transit Gateway: Interconnect project VPCs
  module "tgw" {
    source = "../../modules/transit-gateway/gateway/"

    description = "Connect ${var.project_name} VPCs together"

    name = local.basename
    tags = local.base_tags
  }

  # Attach the VPC to this gateway
  module "tgw-attachment" {
    source = "../../modules/transit-gateway/attachment/"

    name = local.basename
    tags = local.base_tags

    tgw_id    = module.transit-gateway.id
    tgw_rt_id = module.transit-gateway.rt_id

    vpc_id   = module.vpc.id
    vpc_cidr = var.vpc_cidr
    subnets  = module.vpc.public_subnets.ids

    # Skip default route table to isolate resources there
    vpc_route_tables = [
      module.vpc.rt_public,
      module.vpc.rt_private,
    ]
  }

  ### Outputs
  output "tgw" {
    value = {
      id    = module.transit-gateway.id
      rt_id = module.transit-gateway.rt_id
    }
  }



``transit-gateway/attachment`` module
=====================================

This module attaches a VPC to an existing Transit Gateway, setting up the routing as requested.

Also this module adds a route to each of the provided route tables to route the specified
``peer_cidr`` via the attachment. This covers the most basic star topology network with Management
VPC in the centre, but more advanced topologies would need adjustments from outside of the module
- e.g., if a Site-to-Site VPN is attached to the Transit Gateway the routes would need to be added
explicitly.


Parameters
----------

``name``, ``tags``
  Name and tags to attach to the resources

``tgw_id``, ``tgw_rt_id``
  The Transit Gateway and its Route Table to attach VPC to

``vpc_id``
  The VPC ID to attach to Transit Gateway

``vpc_cidr``
  VPC CIDR to use for routing

``subnets``
  Subnets (usually public) to place the attachment into

``vpc_route_tables``
  A list of VPC route tables to receive a route to Transit Gateway

``peer_cidr``
  A CIDR to route through the Transit Gateway from VPC. Should be set to Management VPC CIDR in a
  regular VPC, and can be set to ``10.0.0.0/8`` in the Management VPC itself to simplify the
  routing scheme.


Outputs
-------

``id``
  ID of the Transit Gateway Attachment created in the VPC


Example
-------

To attach to a Transit Gateway defined as part of Management VPC environment,
``environment/stage/mgmt-tgw.tf`` may look as follows::

  ### Handy locals
  # FIXME: Move to locals block in data.tf
  locals {
    mgmt_tgw = data.terraform_remote_state.mgmt.outputs.tgw
  }

  ### Attach the VPC to MGMT Transit Gateway
  module "mgmt-tgw-attachment" {
    source = "../../modules/transit-gateway/attachment/"

    name = local.basename
    tags = local.base_tags

    tgw_id    = local.mgmt_tgw.id
    tgw_rt_id = local.mgmt_tgw.rt_id

    vpc_id   = module.vpc.id
    vpc_cidr = var.vpc_cidr
    subnets  = module.vpc.public_subnets.ids

    peer_cidr = local.mgmt_vpc.cidr

    # Note the default route table is present here
    vpc_route_tables = [
      module.vpc.rt_public,
      module.vpc.rt_private,
      module.vpc.rt_default,
    ]
  }



.. Links
.. _Terraform Null Provider: https://www.terraform.io/docs/providers/null/index.html
.. _AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html

.. vim: set ts=2 sw=2 et tw=98 spell:
