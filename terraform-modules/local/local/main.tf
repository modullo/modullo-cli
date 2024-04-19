# No remote infrastructure to create besides ansible inventory_folder and inventory files

resource "null_resource" "inventory_folder" {
  provisioner "local-exec" {
    command = "mkdir -p ${var.setup_root}/projects/${var.project}/inventory"
  }
}

# Update Ansible Inventory File
resource "local_file" "ansible-inventory" {
    content = templatefile("${path.module}/ansible_inventory.tmpl",
    {
    compute-ip = try(digitalocean_floating_ip.droplet_ip[0].ip_address, digitalocean_droplet.modullo_droplet_instance.ipv4_address),
    compute-id = digitalocean_droplet.modullo_droplet_instance.id,
    compute-ssh-key = "${var.setup_root}/projects/${var.project}/instance-sshkey"
    }
    )
    filename = "${var.setup_root}/projects/${var.project}/inventory/ansible_inventory"
}


# Update Project Parameter File
resource "local_file" "project-parameters" {
    content = templatefile("${path.module}/parameters.tmpl",
    {
    iaas_provider = var.iaas_provider
    do_token = var.do_token
    instance-region = var.region
    instance-domain = var.domain
    db-name = var.db
    instance-private-key = "projects/${var.project}/instance-sshkey"
    instance-ip = try(digitalocean_floating_ip.droplet_ip[0].ip_address, digitalocean_droplet.modullo_droplet_instance.ipv4_address),
    }
    )
    filename = "${var.setup_root}/projects/${var.project}/parameters_infrastructure"
}