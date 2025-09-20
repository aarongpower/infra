variable "mikrotik_user" {
  description = "Mikrotik username"
  type        = string
}

variable "mikrotik_password" {
  description = "Mikrotik password"
  type        = string
  sensitive   = true
}

variable "unifi_user" {
  description = "Unifi username"
  type        = string
}

variable "unifi_password" {
  description = "Unifi password"
  type        = string
  sensitive   = true
}

variable "insecure" {
  description = "Use secure connection"
  type        = bool
  default     = true
}

variable "zerotier_api_token" {
  description = "Zerotier API token"
  type        = string
  sensitive   = true
}

variable "proxmox_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "proxmox_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "pve_user" {
  description = "Proxmox user for cloud-init"
  type        = string
}

variable "pve_password" {
  description = "Proxmox password for cloud-init"
  type        = string
  sensitive   = true
}

variable "pve_host" {
  description = "Proxmox host for cloud-init"
  type        = string
}

variable "op_service_account_token" {
  description = "1Password service account token"
  type        = string
  sensitive   = true
}
