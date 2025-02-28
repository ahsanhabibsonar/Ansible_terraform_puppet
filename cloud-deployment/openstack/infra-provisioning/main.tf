locals {
  server_names = ["web", "dev"]
}


resource "openstack_compute_keypair_v2" "key" {
  name       = "new_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "openstack_compute_instance_v2" "myVM" {
  count           = length(local.server_names)
  name            = element(local.server_names, count.index)
  image_name      = "Ubuntu 24.04-LTS (Noble Numbat)"
  flavor_name     = "aem.1c2r.50g"
  key_pair        = openstack_compute_keypair_v2.key.name
  security_groups = ["default"]

  network {
    name = "oslomet"
  }
}

output "instance_ip_address" {
  description = "The IPv4 address of the compute instance"
  value       = [for instance in openstack_compute_instance_v2.myVM : instance.access_ip_v4]
}

