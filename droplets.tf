resource "digitalocean_droplet" "foundry_droplet" {
  count  = 1
  image  = "docker-20-04"
  name   = "my-foundry-server"
  region = "sfo3"
  size   = "s-1vcpu-1gb"

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
  
  provisioner "local-exec" {
      command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key} foundry_timed_url=${var.foundry_timed_url} domain_name=${var.domain_name} subdomain_name=${var.subdomain_name}' foundry-setup.yml"
  }
}

# Assign domain name to the created droplet
# Add an A record to the domain -- e.g. subdomain of www and domain of example.com -> www.example.com
resource "digitalocean_record" "A_record" {
  domain = var.domain_name
  name   = var.subdomain_name
  type   = "A"
  value  = digitalocean_droplet.foundry_droplet[0].ipv4_address
  ttl    = 300
}


output "droplet_ip_addresses" {
  value = {
    for droplet in digitalocean_droplet.foundry_droplet:
    droplet.name => droplet.ipv4_address
  }
}
