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



resource "openstack_compute_instance_v2" "count_instance" {
  count           = 3
  name            = "mini-${count.index}"
  image_name      = "Ubuntu 24.04-LTS (Noble Numbat)"
  flavor_name     = "aem.1c2r.50g"
  key_pair        = "master"
  security_groups = ["ssh"]
  network {
    name = "oslomet"
  }
}
