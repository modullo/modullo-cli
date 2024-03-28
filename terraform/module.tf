module "iaas_provider_module" {
  source = "../terraform-modules/do/droplet"
  project = var.project
  plan = var.plan
  ready = var.ready
  domain = var.domain
  iaas_provider = var.iaas_provider
  options = var.options
  region = var.region
  setup_root = var.setup_root
  do_token = var.do_token
  do_droplet_size = var.do_droplet_size

}

variable "project" {
  description = "Terraform Variable project"
}

variable "plan" {
  description = "Terraform Variable plan"
}

variable "ready" {
  description = "Terraform Variable ready"
}

variable "domain" {
  description = "Terraform Variable domain"
}

variable "iaas_provider" {
  description = "Terraform Variable iaas_provider"
}

variable "options" {
  description = "Terraform Variable options"
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
