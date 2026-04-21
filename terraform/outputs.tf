output "router_public_ip" {
  description = "Public IP of the Tailscale router"
  value       = nirvana_compute_vm.router.public_ip
}

output "router_private_ip" {
  description = "Private IP of the Tailscale router"
  value       = nirvana_compute_vm.router.private_ip
}

output "internal_private_ip" {
  description = "Private IP of the internal test VM"
  value       = nirvana_compute_vm.internal.private_ip
}

output "vpc_cidr" {
  description = "VPC subnet CIDR (advertise this in Tailscale)"
  value       = nirvana_networking_vpc.tailscale.subnet.cidr
}

output "ssh_command_router" {
  description = "SSH command to connect to the router"
  value       = "ssh ubuntu@${nirvana_compute_vm.router.public_ip}"
}

output "ssh_command_internal_via_router" {
  description = "SSH to internal VM via router (after Tailscale setup)"
  value       = "ssh -J ubuntu@${nirvana_compute_vm.router.public_ip} ubuntu@${nirvana_compute_vm.internal.private_ip}"
}
