module "iaas_provider_module" {
  source = "../terraform-modules/local/local"
  project = var.project
  plan = var.plan
  ready = var.ready
  domain = var.domain
  email = var.email
  deployment = var.deployment
  iaas_provider = var.iaas_provider
  options = var.options
  setup_root = var.setup_root
  project_root = var.project_root

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

variable "email" {
  description = "Terraform Variable email"
}

variable "deployment" {
  description = "Terraform Variable deployment"
}

variable "iaas_provider" {
  description = "Terraform Variable iaas_provider"
}

variable "options" {
  description = "Terraform Variable options"
}

variable "setup_root" {
  description = "Terraform Variable setup_root"
}

variable "project_root" {
  description = "Terraform Variable project_root"
}
