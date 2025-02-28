data "openstack_compute_keypair_v2" "kp" {
  name = "my_key" # Existing key in OpenStack
}

#resource "openstack_compute_keypair_v2" "key" {
#  name       = "my_key"
#  public_key = file("/home/ubuntu/.ssh/id_ed25519.pub")
#}


resource "openstack_compute_instance_v2" "agent_vm" {
  for_each        = local.puppet_agents
  name            = each.key #.dev.local
  image_name      = "Ubuntu 24.04-LTS (Noble Numbat)"
  flavor_name     = "aem.1c2r.50g"
  key_pair        = data.openstack_compute_keypair_v2.kp.name 
  security_groups = ["default"]

  network {
    name = "oslomet"
  }
  # Use cloud-init to add both SSH keys
  user_data = <<-EOF
    #cloud-config
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${file("/home/ubuntu/.ssh/id_ed25519.pub")}
	  #- ${data.openstack_compute_keypair_v2.kp.public_key}  # Extract OpenStack key
  EOF
}

