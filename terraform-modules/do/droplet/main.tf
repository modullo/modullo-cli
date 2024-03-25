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
  region = "${var.region}"
}


resource "digitalocean_floating_ip_assignment" "droplet_ip_assignment" {
  droplet_id = digitalocean_droplet.modullo_droplet_instance.id
  ip_address = digitalocean_floating_ip.droplet_ip.ip_address
}


resource "digitalocean_droplet" "modullo_droplet_knowledge_instance" {
  count  = try(var.with_knowledge, "no") == "yes" ? 1 : 0
  name   = "modullo-droplet-${var.project}-knowledge-${local.domain_label}"
  region = "${var.region}"
  size   = "${var.do_droplet_size}"
  image  = "ubuntu-20-04-x64"
  monitoring = true

  ssh_keys = [digitalocean_ssh_key.instance_key_pair.id]
}

resource "digitalocean_floating_ip" "droplet_ip_knowledge" {
  count  = try(var.with_knowledge, "no") == "yes" ? 1 : 0
  region = "${var.region}"
}


resource "digitalocean_floating_ip_assignment" "droplet_ip_assignment_knowledge" {
  count  = try(var.with_knowledge, "no") == "yes" ? 1 : 0
  droplet_id = digitalocean_droplet.modullo_droplet_knowledge_instance[0].id
  ip_address = digitalocean_floating_ip.droplet_ip_knowledge[0].ip_address
}


resource "digitalocean_domain" "modullo_domain" {
  name = "${var.domain}"
}

resource "digitalocean_record" "dns_hub" {
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "hub"
  value  = digitalocean_floating_ip.droplet_ip.ip_address
  ttl    = 300
}

resource "digitalocean_record" "dns_core" {
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "core"
  value  = digitalocean_floating_ip.droplet_ip.ip_address
  ttl    = 300
}

resource "digitalocean_record" "dns_store" {
  count   = var.edition == "business" ? 1 : 0
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "store"
  value  = digitalocean_floating_ip.droplet_ip.ip_address
  ttl    = 300
}

resource "digitalocean_record" "dns_wildcard" {
  count   = var.edition == "community" || var.edition == "enterprise" ? 1 : 0
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "*"
  value  = digitalocean_floating_ip.droplet_ip.ip_address
  ttl    = 300
}



resource "digitalocean_record" "dns_wildcard_store" {
  count   = var.edition == "community" || var.edition == "enterprise" ? 1 : 0
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "*.store"
  value  = digitalocean_floating_ip.droplet_ip.ip_address
  ttl    = 300
}


resource "digitalocean_record" "dns_portal" {
  count   = var.with_portal == "yes" ? 1 : 0
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "portal"
  value  = digitalocean_floating_ip.droplet_ip.ip_address
  ttl    = 300
}


resource "digitalocean_record" "dns_marketplace" {
  count   = var.with_marketplace == "yes" ? 1 : 0
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "market"
  value  = digitalocean_floating_ip.droplet_ip.ip_address
  ttl    = 300
}


resource "digitalocean_record" "dns_lms" {
  count   = var.with_lms == "yes" ? 1 : 0
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "lms"
  value  = digitalocean_floating_ip.droplet_ip.ip_address
  ttl    = 300
}


resource "digitalocean_record" "dns_university" {
  count   = var.with_university == "yes" ? 1 : 0
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "university"
  value  = digitalocean_floating_ip.droplet_ip.ip_address
  ttl    = 300
}


resource "digitalocean_record" "dns_scheduler" {
  count  = var.with_scheduler == "yes" ? 1 : 0
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "scheduler"
  value  = digitalocean_floating_ip.droplet_ip.ip_address
  ttl    = 300
}


resource "digitalocean_record" "dns_meet" {
  count  = try(var.with_knowledge, "no") == "yes" ? 1 : 0
  domain = digitalocean_domain.modullo_domain.name
  type   = "A"
  name   = "meet"
  value  = digitalocean_floating_ip.droplet_ip_knowledge[0].ip_address
  ttl    = 300
}


# Update Ansible Inventory File
  resource "local_file" "ansible-inventory" {
      content = templatefile("${path.module}/ansible_inventory.tmpl",
      {
      compute-ip = digitalocean_floating_ip.droplet_ip.ip_address,
      compute-id = digitalocean_droplet.modullo_droplet_instance.id,
      compute-ssh-key = "${var.setup_root}/projects/${var.project}/instance-sshkey"
      compute-ip-knowledge = try(digitalocean_floating_ip.droplet_ip_knowledge[0].ip_address, ""),
      compute-id-knowledge = try(digitalocean_droplet.modullo_droplet_knowledge_instance[0].id, ""),
      compute-ssh-key-knowledge = "${var.setup_root}/projects/${var.project}/instance-sshkey"
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
      aws_access_key_id = try(var.access_key, "")
      aws_access_key_secret = try(var.secret_key, "")
      instance-region = var.region
      instance-domain = var.domain
      instance-private-key = "projects/${var.project}/instance-sshkey"
      instance-ip = digitalocean_floating_ip.droplet_ip.ip_address
      instance-ip-knowledge = try(digitalocean_floating_ip.droplet_ip_knowledge[0].ip_address, "")
      }
      )
      filename = "${path.module}/../../projects/${var.project}/parameters"
  }


