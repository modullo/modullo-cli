terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}


variable "project" {
  description = "Project ID"
}

variable "plan" {
  description = "Project Plan ID"
}

variable "ready" {
  description = "Project Plan Ready State"
}


variable "setup_root" {
  description = "Project Setup Root Path"
}


variable "db" {
  description = "Project Database Name"
}


variable "domain" {
  description = "Project Domain"
}

variable "region" {
  description = "IAAS Region"
}

variable "options" {
  description = "Additional Configuration Options"
}

variable "do_token" {
  description = "Digital Ocean Token"
}

variable "do_droplet_size" {
  description = "Digital Ocean Droplet Size"
}

variable "iaas_provider" {
  description = "IAAS Provider"
}