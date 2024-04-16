terraform {
  required_providers {
    # No providers needed
  }
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


variable "project_root" {
  description = "Project Setup Root Path"
}


variable "deployment" {
  description = "Project Deployment Mode"
}


variable "domain" {
  description = "Project Domain"
}


variable "email" {
  description = "Project Email"
}


variable "options" {
  description = "Additional Configuration Options"
}


variable "iaas_provider" {
  description = "IAAS Provider"
}