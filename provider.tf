terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}
variable "pvt_key" {}
variable "pub_key" {}
variable "foundry_timed_url" {}
variable "domain_name" {} // e.g. example.com
variable "subdomain_name" {} // e.g. www

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}