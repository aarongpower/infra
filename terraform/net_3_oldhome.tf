### VLAN 3 - Home network
resource "routeros_vlan" "v3-home" {
  name      = "ether2.3-home" # name of the VLAN interface
  interface = "ether2"        # parent port
  vlan_id   = 3
}

resource "routeros_ip_address" "v3-home-gw" {
  address   = "192.168.3.254/24"
  interface = routeros_vlan.v3-home.name
}

resource "routeros_ip_address" "v2-oldmanagement-gw" {
  address   = "192.168.2.254/24"
  interface = "ether2"
}