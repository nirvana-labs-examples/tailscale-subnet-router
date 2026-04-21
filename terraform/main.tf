terraform {
  required_providers {
    nirvana = {
      source = "nirvana-labs/nirvana"
    }
  }
}

provider "nirvana" {}

# VPC for Tailscale Subnet Router
resource "nirvana_networking_vpc" "tailscale" {
  name        = var.vpc_name
  region      = var.region
  project_id  = var.project_id
  subnet_name = "${var.vpc_name}-subnet"
  tags        = var.tags
}

# Firewall rule - SSH access to router
resource "nirvana_networking_firewall_rule" "tailscale_ssh" {
  vpc_id              = nirvana_networking_vpc.tailscale.id
  name                = "tailscale-ssh"
  protocol            = "tcp"
  source_address      = "0.0.0.0/0"
  destination_address = nirvana_networking_vpc.tailscale.subnet.cidr
  destination_ports   = ["22"]
  tags                = var.tags
}

# Firewall rule - Allow internal VPC TCP traffic
resource "nirvana_networking_firewall_rule" "tailscale_internal_tcp" {
  vpc_id              = nirvana_networking_vpc.tailscale.id
  name                = "tailscale-internal-tcp"
  protocol            = "tcp"
  source_address      = nirvana_networking_vpc.tailscale.subnet.cidr
  destination_address = nirvana_networking_vpc.tailscale.subnet.cidr
  destination_ports   = ["1-65535"]
  tags                = var.tags
}

# Firewall rule - Allow internal VPC UDP traffic
resource "nirvana_networking_firewall_rule" "tailscale_internal_udp" {
  vpc_id              = nirvana_networking_vpc.tailscale.id
  name                = "tailscale-internal-udp"
  protocol            = "udp"
  source_address      = nirvana_networking_vpc.tailscale.subnet.cidr
  destination_address = nirvana_networking_vpc.tailscale.subnet.cidr
  destination_ports   = ["1-65535"]
  tags                = var.tags
}

# Firewall rule - Allow Tailscale UDP (for direct connections)
resource "nirvana_networking_firewall_rule" "tailscale_udp" {
  vpc_id              = nirvana_networking_vpc.tailscale.id
  name                = "tailscale-udp"
  protocol            = "udp"
  source_address      = "0.0.0.0/0"
  destination_address = nirvana_networking_vpc.tailscale.subnet.cidr
  destination_ports   = ["41641"]
  tags                = var.tags
}

# Tailscale Router VM (with public IP)
resource "nirvana_compute_vm" "router" {
  name              = "${var.vm_name_prefix}-router"
  project_id        = var.project_id
  region            = var.region
  subnet_id         = nirvana_networking_vpc.tailscale.subnet.id
  public_ip_enabled = true
  os_image_name     = var.os_image
  instance_type     = var.instance_type

  boot_volume = {
    size = var.boot_volume_size
    type = "abs"
    tags = var.tags
  }

  ssh_key = {
    public_key = var.ssh_public_key
  }

  tags = var.tags
}

# Internal Test VM (no public IP)
resource "nirvana_compute_vm" "internal" {
  name              = "${var.vm_name_prefix}-internal"
  project_id        = var.project_id
  region            = var.region
  subnet_id         = nirvana_networking_vpc.tailscale.subnet.id
  public_ip_enabled = false
  os_image_name     = var.os_image
  instance_type     = var.instance_type

  boot_volume = {
    size = var.boot_volume_size
    type = "abs"
    tags = var.tags
  }

  ssh_key = {
    public_key = var.ssh_public_key
  }

  tags = var.tags
}
