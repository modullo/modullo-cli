module "iaas_provider_module" {
  source = "../terraform-modules/do/droplet"
  project = var.project
  domain = var.domain
  iaas_provider = var.iaas_provider
  region = var.region
  setup_root = var.setup_root
  do_token = var.do_token
  do_droplet_size = var.do_droplet_size

}

variable "project" {
  description = "Terraform Variable project"
}

variable "domain" {
  description = "Terraform Variable domain"
}

variable "iaas_provider" {
  description = "Terraform Variable iaas_provider"
}

variable "region" {
  description = "Terraform Variable region"
}

variable "setup_root" {
  description = "Terraform Variable setup_root"
}

variable "do_token" {
  description = "Terraform Variable do_token"
}

variable "do_droplet_size" {
  description = "Terraform Variable do_droplet_size"
}
