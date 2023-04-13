resource "digitalocean_droplet" "web" {
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
      inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]
  
      connection {
        host        = self.ipv4_address
        type        = "ssh"
        user        = "root"
        private_key = file(var.pvt_key)
      }
  }
  
  provisioner "local-exec" {
      command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' apache-install.yml"
  }
}

output "droplet_ip_addresses" {
  value = {
    for droplet in digitalocean_droplet.web:
    droplet.name => droplet.ipv4_address
  }
}
