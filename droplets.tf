resource "digitalocean_droplet" "foundry_droplet" {
  name   = "my-foundry-server"
  size   = "s-1vcpu-1gb"
  image  = "docker-20-04"
  region = "sfo3"

  tags = ["FoundryVTT"]

  ssh_keys = [
      data.digitalocean_ssh_key.terraform.id
  ]

  provisioner "remote-exec" {
      inline = ["echo Done!"]
  
      connection {
        host        = self.ipv4_address
        type        = "ssh"
        user        = "root"
        private_key = file(var.pvt_key)
      }
  }
}

resource "digitalocean_firewall" "foundry_droplet_firewall" {
  name = "foundry-droplet-firewall"

  tags = ["FoundryVTT"]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    # TODO: Limit SSH source addresses to desired IP addresses
    source_addresses = [ "0.0.0.0/0", "::/0" ]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Assign domain name to the created droplet, if provided
# Add an A record to the domain -- e.g. subdomain of www and domain of example.com -> www.example.com
resource "digitalocean_record" "A_record" {
  domain = var.domain_name
  name   = var.subdomain_name
  type   = "A"
  value  = digitalocean_droplet.foundry_droplet.ipv4_address
  ttl    = 300
  # Only create the A record if assign_domain_name is "true"
  count = tobool(var.assign_domain_name) ? 1 : 0
}

# Wait for A record to propagate and then execute Ansible playbook
resource "null_resource" "wait_and_provision" {
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${digitalocean_droplet.foundry_droplet.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key} domain_name=${var.domain_name} subdomain_name=${var.subdomain_name} existing_foundry_zip_data_path=${var.existing_foundry_zip_data_path}' foundry-setup.yml"
  }
}

# Print out the IP address of the created droplet
output "droplet_ip_address" {
  value = digitalocean_droplet.foundry_droplet.ipv4_address
}

output "droplet_domain_name" {
  value = "${var.subdomain_name}.${var.domain_name}"
}
