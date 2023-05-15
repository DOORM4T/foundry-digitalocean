terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {} // e.g. "dop_v1_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
variable "pvt_key" {} // e.g. "~/.ssh/foundry-digitalocean/terraform/id_rsa"
variable "pub_key" {} // e.g. "~/.ssh/foundry-digitalocean/terraform/id_rsa.pub"
variable "assign_domain_name" {} // e.g. "true", "false" -- droplets.tf will cast this string to bool
variable "domain_name" {} // e.g. "example.com"
variable "subdomain_name" {} // e.g. "www"
variable "existing_foundry_zip_data_path" {} // e.g. "~/Documents/foundry/backups/foundrydata.zip containing Config/ and Data/ directories"

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}