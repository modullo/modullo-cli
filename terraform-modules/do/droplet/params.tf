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


variable "setup_root" {
  description = "Project Setup Root Path"
}

variable "domain" {
  description = "Project Domain"
}

variable "region" {
  description = "IAAS Region"
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