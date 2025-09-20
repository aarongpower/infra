locals {
  subnets = {
    "1000_cerberus" = { id = 0, name = "cerberus", reservations = [] }
    "1003_cygni"    = { id = 3, name = "cygni", reservations = [] }
    "1010_jupiter" = { id = 10, name = "jupiter", reservations = [
      {
        host_address = "11",
        mac_address  = "2c:cf:67:6c:86:b6",
        hostname     = "nexus-1"
      },
      # {
      #   host_address = "11",
      #   mac_address  = "00:11:22:33:44:66",
      #   hostname     = "nexus-2"
      # },
      # {
      #   host_address = "12",
      #   mac_address  = "00:11:22:33:44:77",
      #   hostname     = "nexus-3"
      # }
    ] }
    "2000-gigachad" = { id = 256, name = "gigachad", reservations = [] }
  }
  now = formatdate("YYYY-MM-DD'T'HH:mm:ss", timestamp())
}

module "subnet" {
  source   = "./modules/subnet"
  for_each = local.subnets

  id           = each.value.id
  name         = each.value.name
  reservations = each.value.reservations
}

resource "routeros_ip_route" "default_route" {
  dst_address = "0.0.0.0/0"
  gateway     = "192.168.1.1"
}



data "onepassword_vault" "sol" {
  name = "000-sol"
}














# data "onepassword_item" "terraform-pve" {
#   vault = data.onepassword_vault.sol.uuid
#   title = "Yggdrasil Aaron"
# }

# # resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
# #   content_type = "import"
# #   datastore_id = "local"
# #   node_name    = "pve"
# #   url          = "https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img"
# #   # need to rename the file to *.qcow2 to indicate the actual file format for import
# #   file_name = "ubuntu-24.04-minimal-cloudimg-amd64.qcow2"
# # }

# resource "proxmox_virtual_environment_file" "pdns_cloud_config" {
#   content_type = "snippets"
#   datastore_id = "local"
#   node_name    = "yggdrasil"

#   source_raw {
#     data = <<-EOF
#     #cloud-config
#     hostname: test-ubuntu
#     timezone: Jakarta/Asia
#     users:
#       - default
#       - name:  ${data.onepassword_item.terraform-pve.username}
#         password: ${data.onepassword_item.terraform-pve.password}
#         groups:
#           - sudo
#         shell: /bin/bash
#         ssh_authorized_keys:
#           - ${trimspace(data.onepassword_item.aaron_ssh_key.public_key)}
#         sudo: ALL=(ALL) NOPASSWD:ALL
#     package_update: true
#     package_upgrade: true
#     packages:
#       - qemu-guest-agent
#       - pdns-server
#       - pdns-backend-sqlite3
#       - curl
#     runcmd:
#       - systemctl enable qemu-guest-agent
#       - systemctl start qemu-guest-agent
#       - systemctl enable pdns
#       - systemctl start pdns
#       - echo "done" > /tmp/cloud-config.done
#     EOF

#     file_name = "pdns_cloud_config.yaml"
#   }
# }

# resource "proxmox_virtual_environment_vm" "resolvatron" {
#   depends_on = [
#     data.onepassword_item.terraform-pve, 
#     proxmox_virtual_environment_file.pdns_cloud_config
#   ]

#   node_name = "yggdrasil"
#   vm_id      = 1000001 # vlan 1000 node 001
#   name      = "resolvatron"

#   clone {
#     vm_id = 710
#   datastore_id = "vm-disks"
#   }

#   agent {
#     enabled = true
#   }

#   cpu {
#     cores = 2
#   }

#   memory {
#     dedicated = 2048
#   }

#   disk {
#     datastore_id = "vm-disks"
#     interface = "scsi0"
#     size = 16
#   }

#   initialization {
#     ip_config {
#       ipv4 {
#         address = "dhcp"
#       }
#     }

#     user_data_file_id = proxmox_virtual_environment_file.pdns_cloud_config.id
#   }

#   network_device {
#     bridge = "br0"
#     vlan_id = 1000
#   }
# }
