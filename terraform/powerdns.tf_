variable "node_name" {
  type    = string
  default = "pve"
}
variable "image_datastore" {
  type    = string
  default = "local"
} # has "Disk image" content
variable "vm_datastore" {
  type    = string
  default = "vm-disks"
} # has "Disk image" content
variable "snippets_datastore" {
  type    = string
  default = "local"
} # has "Snippets" content
variable "bridge" {
  type    = string
  default = "br0"
}
variable "vlan" {
  type    = number
  default = 1000
}
variable "vm_name" {
  type    = string
  default = "resolvatron"
}
variable "vm_id" {
  type    = string
  default = "1000001"
}
variable "vm_cpu_cores" {
  type    = number
  default = 2
}
variable "vm_memory_mb" {
  type    = number
  default = 2048
}
variable "vm_disk_gb" {
  type    = number
  default = 10
}
variable "vm_user" {
  type    = string
  default = "admin"
}
variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}
variable "pve_node_name" {
  type    = string
  default = "yggdrasil"
}
variable "pdns_api_key" {
  description = "PowerDNS API key"
  type        = string
  sensitive   = true
}


locals {
  pdns_ip_arr = [10, 71, 0, 5] # PowerDNS IP address
  pdns_ip     = join(".", local.pdns_ip_arr)
  pdns_mac = format(
    "02:00:%02x:%02x:%02x:%02x",
    local.pdns_ip_arr[0],
    local.pdns_ip_arr[1],
    local.pdns_ip_arr[2],
    local.pdns_ip_arr[3]
  )
  #   now = formatdate("YYYY-MM-DD'T'HH:mm:ss", timestamp())
  ssh_pubkey = trimspace(file(var.ssh_public_key_path))
  cloudinit = templatefile("${path.module}/snippets/resolvatron-cloudinit.yaml", {
    vm_hostname    = var.vm_name
    ssh_authorized = local.ssh_pubkey
    vm_user        = "admin"
    pdns_api_key   = var.pdns_api_key
  })
  cloudinit_file_id = "local:snippets/resolvatron-cloudinit.yaml"
}

resource "routeros_ip_dhcp_server_lease" "reservation" {
  address     = local.pdns_ip
  mac_address = local.pdns_mac
  server      = "1000-cerberus-dhcp"
  comment     = "resolvatron-powerdns"
}

resource "routeros_ip_firewall_filter" "allow_forward_lan_to_wan" {
  chain         = "forward"
  src_address   = local.pdns_ip
  out_interface = "ether1"
  action        = "accept"
}

resource "onepassword_item" "powerdns" {
  vault    = data.onepassword_vault.sol.uuid
  title    = "reslovatron-powerdns"
  username = "aaronp"

  password_recipe {
    length  = 32
    symbols = false
  }

  section {
    label = "Creation details"

    field {
      label = "Created by"
      value = "Terraform"
      type  = "STRING"
    }

    field {
      label = "Created at"
      value = local.now
      type  = "STRING"
    }
  }
}

# Download Ubuntu 24.04 cloud image to Proxmox
resource "proxmox_virtual_environment_download_file" "ubuntu_plucky" {
  node_name    = var.pve_node_name
  datastore_id = "local"
  # On older PVE, using ISO content with a qcow2.img name avoids extension checks
  content_type = "import"
  url          = "https://cloud-images.ubuntu.com/releases/plucky/release/ubuntu-25.04-server-cloudimg-amd64.vmdk"
  file_name    = "ubuntu-25.04-server-cloudimg-amd64.vmdk"
}

resource "local_file" "cloudinit_yaml" {
  content  = local.cloudinit
  filename = "${path.module}/.terraform/cloudinit-rendered.yaml"
}

# Copy cloudinit template to target system
resource "null_resource" "pdns_cloudinit_upload" {
  depends_on = [
    local_file.cloudinit_yaml
  ]

  triggers = {
    # Evaluate hash at plan time based on the rendered content
    content_sha = sha256(local.cloudinit)
  }

  provisioner "file" {
    source      = local_file.cloudinit_yaml.filename
    destination = "/tmp/resolvatron-cloudinit.yaml"

    connection {
      type        = "ssh"
      host        = var.pve_host
      user        = "terraform"
      private_key = file("~/.ssh/id_ed25519")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"creating snippets dir\"; sudo -n mkdir -p /var/lib/vz/snippets",
      "echo \"copying cloudinit\"; sudo -n mv /tmp/resolvatron-cloudinit.yaml /var/lib/vz/snippets/resolvatron-cloudinit.yaml",
      "echo \"setting ownership\"; sudo -n chown root:root /var/lib/vz/snippets/resolvatron-cloudinit.yaml",
      "echo \"setting permissions\"; sudo -n chmod 0644 /var/lib/vz/snippets/resolvatron-cloudinit.yaml",
    ]

    connection {
      type        = "ssh"
      host        = var.pve_host
      user        = "terraform"
      private_key = file("~/.ssh/id_ed25519")
    }
  }
}


# Create the VM and inject the Cloud-Init user-data
resource "proxmox_virtual_environment_vm" "pdns" {
  name        = var.vm_name
  description = "PowerDNS authoritative (SQLite). Managed by Terraform."
  node_name   = var.pve_node_name
  tags        = ["terraform", "pdns"]
  vm_id       = var.vm_id

  depends_on = [
    null_resource.pdns_cloudinit_upload
  ]

  agent {
    enabled = true
  }

  cpu {
    sockets = 1
    cores   = var.vm_cpu_cores
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.vm_memory_mb
  }

  disk {
    datastore_id = var.vm_datastore
    interface    = "scsi0"
    import_from = proxmox_virtual_environment_download_file.ubuntu_plucky.id
    size    = var.vm_disk_gb
  }

  network_device {
    bridge  = var.bridge
    model   = "virtio"
    vlan_id = var.vlan
  }

  operating_system {
    type = "l26"
  }

  initialization {
    # Where to create the cloud-init disk (avoid defaulting to 'local-lvm')
    datastore_id = var.vm_datastore
    # DHCP on first NIC
    ip_config {
      ipv4 { address = "dhcp" }
    }

    # Pass our custom user-data
    user_data_file_id = local.cloudinit_file_id
  }

  # Optional: ensure a serial console for easier troubleshooting
  serial_device {}
}
