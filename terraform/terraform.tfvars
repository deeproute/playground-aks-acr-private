region              = "eastus2"
resource_group_name = "playground-aks-acr-private"

tags = {
  Owner = "deeproute"
}

### INFRA

vnets = [{
  name           = "aks-vnet"
  address_spaces = ["10.100.0.0/16"]
  subnets = [{
    name             = "aks-subnet"
    address_prefixes = ["10.100.1.0/24"]
  }]
  }, {
  name           = "acr-vnet"
  address_spaces = ["10.101.0.0/16"]
  subnets = [{
    name             = "acr-subnet"
    address_prefixes = ["10.101.1.0/24"]
  }]
}]

### AKS
cluster_name            = "aks-acr-private"
private_cluster_enabled = true
kubernetes_version      = "1.23.15"
network_plugin          = "kubenet"
network_policy          = "calico"

node_pools = [{
  name                   = "default"
  orchestrator_version   = "1.23.15"
  vm_size                = "Standard_B2ms"
  enable_host_encryption = true
  os_disk_size_gb        = null
  os_disk_type           = null
  vnet_name              = "infra"
  subnet_name            = "aks-subnet"
  node_count             = 1
  enable_auto_scaling    = false
  min_count              = null
  max_count              = null
  max_pods               = null
  availability_zones     = ["1", "2", "3"]
  enable_public_ip       = false
  ultra_ssd_enabled      = false
  labels                 = {}
  taints                 = []
  mode                   = "System"
  },
]

acr_name = "acrprivatetyz"
acr_sku  = "Premium"
acr_allowed_public_ips = ["20.12.61.190/32"] #"20.12.61.190/32"

vm_name = "jumpbox-vm"
vm_size = "Standard_B2s"