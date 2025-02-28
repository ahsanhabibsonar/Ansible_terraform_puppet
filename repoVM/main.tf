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

resource "openstack_compute_instance_v2" "myRepo" {
  name            = "slave3"
  image_name      = "Ubuntu 24.04-LTS (Noble Numbat)"
  flavor_name     = "aem.1c2r.50g"
  key_pair        = "master"
  security_groups = ["default"]

  network {
    name = "oslomet"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    host        = openstack_compute_instance_v2.myRepo.access_ip_v4
  }
  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "git clone https://github.com/ahsanhabibsonar/acit4420-final",
    ]
  }
}



