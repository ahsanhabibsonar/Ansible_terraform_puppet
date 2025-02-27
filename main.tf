terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "3.0.0"
    }
  }
}

provider "openstack" {
  #cloud = var.cloud_name
  cloud = "openstack_cred1"
}

resource "openstack_compute_instance_v2" "mini_ub" {
  name = "mini-ubuntu"
  image_name = "Ubuntu 24.04-LTS (Noble Numbat)"
  flavor_name = "aem.1c2r.50g"
  key_pair = "master"
  security_groups = ["default"]
  network {
  name = "oslomet"
}
}
resource "openstack_compute_instance_v2" "mini_deb" {
  name = "mini-debian"
  image_name = "Debian12 (Bookworm)"
  flavor_name = "aem.1c2r.50g"
  key_pair = "master"
  security_groups = ["ssh"]
  network {
  name = "oslomet"
 }
}
resource "openstack_compute_instance_v2" "count_instance" {
  count = 2
  name = "mini-${count.index}"
  image_name = "Ubuntu 24.04-LTS (Noble Numbat)"
  flavor_name = "aem.1c2r.50g"
  key_pair = "master"
  security_groups = ["ssh"]
  network {
  name = "oslomet"
 }
}
# Build volume from image and boot from it
resource "openstack_compute_instance_v2" "mini_instance" {
  name = "mini"
  flavor_name = "aem.1c2r.50g"
  key_pair = "master"
  block_device {
  uuid = "078bf838-1507-4c9e-9e0f-a0861e177cdd"
  source_type = "image"
  volume_size = 25
  boot_index = 0
  destination_type = "volume"
  delete_on_termination = "true"
}
network {
name = "oslomet"
 }
}

resource "openstack_compute_instance_v2" "install_instance" {
  name = "exec"
  image_name = "Ubuntu 24.04-LTS (Noble Numbat)"
  flavor_name = "aem.1c2r.50g"
  key_pair = "master"
  network {
    name = "oslomet"
  }
connection {
  type = "ssh"
  user = "ubuntu"
  private_key = "${file("~/.ssh/id_ed25519")}"
  host = openstack_compute_instance_v2.install_instance.access_ip_v4
}
provisioner "remote-exec" {
  inline = [
  "sleep 20",
  "sudo apt update",
  "sudo apt -y install puppet"
  ]
 }
}
