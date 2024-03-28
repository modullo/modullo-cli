locals {
  domain_label = replace(var.domain, ".", "-")
}

resource "tls_private_key" "gen_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "create_priv_key" {
  content     = tls_private_key.gen_key.private_key_pem
  filename    = "${path.module}/../../projects/${var.project}/instance-sshkey"
  file_permission = "0400"
}

resource "local_file" "create_public_key" {
  content     = tls_private_key.gen_key.public_key_openssh
  filename    = "${path.module}/../../projects/${var.project}/instance-sshkey.pub"
  file_permission = "0400"
}

resource "digitalocean_ssh_key" "instance_key_pair" {
  name       = "modullo-keypair-${var.project}-${local.domain_label}"
  public_key = tls_private_key.gen_key.public_key_openssh
}


resource "digitalocean_droplet" "modullo_droplet_instance" {
  name   = "modullo-${local.domain_label}"
  region = "${var.region}"
  size   = "${var.do_droplet_size}"
  image  = "ubuntu-20-04-x64"
  monitoring = true

  ssh_keys = [digitalocean_ssh_key.instance_key_pair.id]
}


resource "digitalocean_floating_ip" "droplet_ip" {
  count = "${contains(split(",", var.options), "static-ip") ? 1 : 0}"
  region = "${var.region}"
}


resource "digitalocean_floating_ip_assignment" "droplet_ip_assignment" {
  count = "${contains(split(",", var.options), "static-ip") ? 1 : 0}"
  droplet_id = digitalocean_droplet.modullo_droplet_instance.id
  ip_address = digitalocean_floating_ip.droplet_ip[0].ip_address
}

resource "digitalocean_domain" "modullo_domain" {
  name = "${var.domain}"
}

resource "digitalocean_record" "dns_project" {
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "main"
  value  = digitalocean_floating_ip.droplet_ip[0].ip_address
  ttl    = 300
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
      filename = "${path.module}/../../projects/${var.project}/ansible_inventory"
  }


# Update Project Parameter File
  resource "local_file" "project-parameters" {
      content = templatefile("${path.module}/parameters.tmpl",
      {
      iaas_provider = var.iaas_provider
      do_token = var.do_token
      instance-region = var.region
      instance-domain = var.domain
      instance-private-key = "projects/${var.project}/instance-sshkey"
      instance-ip = try(digitalocean_floating_ip.droplet_ip[0].ip_address, digitalocean_droplet.modullo_droplet_instance.ipv4_address),
      }
      )
      filename = "${path.module}/../../projects/${var.project}/parameters"
  }


