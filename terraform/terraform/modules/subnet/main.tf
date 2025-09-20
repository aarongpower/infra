terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros" # REST or classic API
      version = "~> 1.76"
    }
    unifi = {
      source  = "paultyng/unifi"
      version = "0.41.0"
    }
  }
}


locals {
  id_mod         = var.id % 256
  id_quotient    = floor(var.id / 256)
  vlan_id        = local.id_mod + ((local.id_quotient + 1) * 1000) # e.g., 1000 for id=0, 1003 for id=3, 1010 for id=10
  slug           = "${local.vlan_id}-${var.name}"                  # e.g., "1000-cerberus", "1003-cygni", "1010-jupiter"
  octet2         = 70 + local.id_quotient + 1
  subnet_cidr    = "10.${local.octet2}.${local.id_mod}.0/24"
  gateway        = "10.${local.octet2}.${local.id_mod}.1"
  gateway_cidr   = "10.${local.octet2}.${local.id_mod}.1/24"
  dhcp_pool      = "10.${local.octet2}.${local.id_mod}.200-10.${local.octet2}.${local.id_mod}.220"
  dns_server     = ["192.168.3.22"]
}

resource "routeros_vlan" "vlan" {
  name      = "ether2.${local.slug}" # name of the VLAN interface
  interface = "ether2"               # parent port
  vlan_id   = local.vlan_id
}

resource "routeros_ip_address" "gateway" {
  address   = local.gateway_cidr
  interface = routeros_vlan.vlan.name
}

resource "routeros_ip_pool" "dhcp-pool" {
  name   = "${local.slug}-pool"
  ranges = [local.dhcp_pool]
}

resource "routeros_ip_dhcp_server" "dhcp-server" {
  name          = "${local.slug}-dhcp"
  interface     = routeros_vlan.vlan.name
  address_pool  = routeros_ip_pool.dhcp-pool.name
  authoritative = "yes"
  lease_time    = "1h"
}

resource "routeros_ip_dhcp_server_lease" "reservation" {
  for_each = { for res in var.reservations : res.mac_address => res }

  address     = "10.${local.octet2}.${local.id_mod}.${each.value.host_address}"
  mac_address = each.value.mac_address
  server      = routeros_ip_dhcp_server.dhcp-server.name
  comment     = each.value.hostname
}

resource "routeros_ip_firewall_nat" "masquerade" {
  chain         = "srcnat"
  src_address   = local.subnet_cidr
  out_interface = "ether1"
  action        = "masquerade"
}

resource "routeros_ip_firewall_filter" "allow_allow_internal_to_wan" {
  for_each = { for res in var.reservations : res.mac_address => res if res.allow_internet }

  chain         = "forward"
  src_address   = "10.${local.octet2}.${local.id_mod}.${each.value.host_address}"
  out_interface = "ether1"
  action        = "accept"
}

resource "routeros_ip_dhcp_server_network" "dhcp-network" {
  address    = local.subnet_cidr
  gateway    = local.gateway
  dns_server = local.dns_server
}

resource "unifi_network" "unifi-vlan" {
  name    = local.slug
  purpose = "vlan-only"
  vlan_id = local.vlan_id
}

resource "unifi_static_route" "unifi-route" {
  name     = "to-vlan${local.slug}"
  type     = "nexthop-route"
  network  = local.subnet_cidr
  distance = 1
  next_hop = "192.168.2.254"
}
