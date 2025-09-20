variable "id" {
    description = "Subnet ID"
    type = number
}

variable "name" {
    description = "Subnet name"
    type = string
}

variable "reservations" {
    description = "List of IP reservations for the subnet"
    type = list(object({
        host_address = string
        mac_address = string
        hostname = string
        allow_internet = optional(bool, true) # whether to allow internet access for this reservation
    }))
    default = []
}
