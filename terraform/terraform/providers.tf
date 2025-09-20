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
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.82.1"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.1.2"
    }
  }
}

provider "routeros" {
  hosturl  = "http://192.168.88.1"
  username = "terraform"
  password = var.mikrotik_password
  insecure = true # skip TLS verify while you test
}

provider "unifi" {
  username = "terraform"
  password = var.unifi_password # optionally use UNIFI_PASSWORD env var
  api_url  = "https://192.168.2.2"

  # you may need to allow insecure TLS communications unless you have configured
  # certificates for your controller
  allow_insecure = var.insecure # optionally use UNIFI_INSECURE env var

  # if you are not configuring the default site, you can change the site
  # site = "foo" or optionally use UNIFI_SITE env var
}

data "onepassword_item" "aaron_ssh_key" {
  vault = data.onepassword_vault.sol.uuid
  title = "Aaron SSH Key"
}

data "onepassword_item" "aaron_password" {
  vault = data.onepassword_vault.sol.uuid
  title = "Yggdrasil Aaron"
}

data "onepassword_item" "pve_terraform_token" {
  vault = data.onepassword_vault.sol.uuid
  title = "pve_terraform_token"
}

provider "proxmox" {
  endpoint  = "https://192.168.3.20:8006/api2/json/"
  api_token = "${data.onepassword_item.pve_terraform_token.username}=${data.onepassword_item.pve_terraform_token.credential}"
  insecure  = true # for self-signed certs, change as appropriate

  ssh {
    agent       = false
    username    = "terraform"
    private_key = file("~/.ssh/id_ed25519") # or use PVE_SSH_PRIVATE_KEY env var

    node {
      name    = var.pve_node_name
      address = "192.168.3.20"
    }
  }
}

provider "onepassword" {
  service_account_token = var.op_service_account_token
}

