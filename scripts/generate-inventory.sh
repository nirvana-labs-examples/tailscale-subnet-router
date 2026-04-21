#!/bin/bash
# Generate Ansible inventory from Terraform output

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
ANSIBLE_DIR="$SCRIPT_DIR/../ansible"

cd "$TERRAFORM_DIR"

# Get IPs from terraform output
ROUTER_PUBLIC_IP=$(terraform output -raw router_public_ip)
ROUTER_PRIVATE_IP=$(terraform output -raw router_private_ip)
INTERNAL_PRIVATE_IP=$(terraform output -raw internal_private_ip)
VPC_CIDR=$(terraform output -raw vpc_cidr)

# Generate inventory file
INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"

cat > "$INVENTORY_FILE" << EOF
[router]
router ansible_host=${ROUTER_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519

[internal]
internal ansible_host=${INTERNAL_PRIVATE_IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519 ansible_ssh_common_args='-o ProxyJump=ubuntu@${ROUTER_PUBLIC_IP}'
EOF

echo ""
echo "Inventory generated at $INVENTORY_FILE"
echo ""
echo "=== Tailscale Subnet Router Setup ==="
echo "Router Public IP:    $ROUTER_PUBLIC_IP"
echo "Router Private IP:   $ROUTER_PRIVATE_IP"
echo "Internal VM IP:      $INTERNAL_PRIVATE_IP"
echo "VPC CIDR:            $VPC_CIDR"
echo ""
echo "Next: Set TAILSCALE_AUTHKEY and run ansible-playbook"
echo "  export TAILSCALE_AUTHKEY='tskey-auth-xxxxx'"
echo "  cd ansible && ansible-playbook playbook.yml"
