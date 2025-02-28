terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.0.0"
    }
  }
}

provider "openstack" {
  #cloud = var.cloud_name
  cloud = "openstack_cred1"
}

resource "openstack_blockstorage_volume_v3" "myvol" {
  name = "myvol"
  size = 1
}

resource "openstack_compute_instance_v2" "myVM" {
  name            = "myVM"
  image_name      = "Ubuntu 24.04-LTS (Noble Numbat)"
  flavor_name     = "aem.1c2r.50g"
  key_pair        = "master"
  security_groups = ["default"]

  network {
    name = "oslomet"
  }
}

resource "openstack_compute_volume_attach_v2" "attached" {
  instance_id = openstack_compute_instance_v2.myVM.id
  volume_id   = openstack_blockstorage_volume_v3.myvol.id
}

output "ipv4" {
  description = " The IPv4 address of the compute instance"
  value       = openstack_compute_instance_v2.myVM.access_ip_v4
}
