
resource "openstack_compute_keypair_v2" "key" {
  name       = "new_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

data "openstack_compute_keypair_v2" "kp" {
  name = "ansible_key"
}

resource "openstack_compute_instance_v2" "myVM" {
  name            = var.vm_name
  image_name      = "Ubuntu 24.04-LTS (Noble Numbat)"
  flavor_name     = var.flavor_name
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
        home: /home/ubuntu
        #sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
	  - ${file("/home/ubuntu/.ssh/id_rsa.pub")}
	#  - ${data.openstack_compute_keypair_v2.kp.public_key}  # Extract OpenStack key
  EOF

}

