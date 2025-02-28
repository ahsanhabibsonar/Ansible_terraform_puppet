#main.tf
resource "openstack_compute_keypair_v2" "key" {
  name       = "my_key"
  public_key = file("/home/ubuntu/.ssh/id_ed25519.pub")
}


resource "openstack_compute_instance_v2" "agent_vm" {
  for_each        = local.puppet_agents
  name            = each.key #.dev.local
  image_name      = "Ubuntu 24.04-LTS (Noble Numbat)"
  flavor_name     = "aem.1c2r.50g"
  key_pair        = openstack_compute_keypair_v2.key.name 
  security_groups = ["default"]

  network {
    name = "oslomet"
  }
}

