variable "region" {
  description = "Region of the resource group."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "vnets" {
  type = list(object({
    name           = string
    address_spaces = list(string)
    subnets = list(object({
      name             = string
      address_prefixes = list(string)
    }))
  }))
}

variable "cluster_name" {
  type = string
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

variable "kubernetes_version" {
  type = string
}

variable "node_count" {
  type    = number
  default = 1
}

variable "network_plugin" {
  type    = string
  default = "kubenet"
}

variable "network_policy" {
  type    = string
  default = "calico"
}

variable "node_pools" {
  type = list(object({
    name                   = string
    orchestrator_version   = string
    vm_size                = string
    enable_host_encryption = bool
    os_disk_size_gb        = number
    os_disk_type           = string
    vnet_name              = string
    subnet_name            = string
    node_count             = number
    enable_auto_scaling    = bool
    min_count              = number
    max_count              = number
    max_pods               = number
    availability_zones     = list(string)
    enable_public_ip       = bool
    ultra_ssd_enabled      = bool
    labels                 = map(string)
    taints                 = list(string)
    mode                   = string
  }))
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource."
}

variable "acr_name" {
  type = string
}

variable "acr_sku" {
  type = string
}

variable "acr_allowed_public_ips" {
  type = list(string)
  default = []
}

variable "vm_name" {
  type    = string
  default = "jumpbox-vm"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}