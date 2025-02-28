terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = "acit4430"
  region  = "us-central1"
  zone    = "us-central1-c"
}

#resource "google_compute_ssh_key" "my_key" {
#  name       = "master"
#  public_key = file("~/.ssh/id_ed25519.pub") # Ensure this file exists with your public key
#}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_firewall" "allow_ssh_http" {
  name    = "allow-ssh-http"
  network = google_compute_network.vpc_network.name #Adjust if using a custom network

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"] # Adjust for more restricted access if needed
}



resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      #image = "ubuntu-cloud/ubuntu-24"

    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
 metadata = {
    "ssh-keys" = <<EOT
     debian:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP2p5FpJJm3xh7fQV//bGpIXGbChqiK4LlpgweooigI5 ubuntu@iot10-vm1      
     test:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILg6UtHDNyMNAh0GjaytsJdrUxjtLy3APXqZfNZhvCeT test
     EOT
  }
  #metadata = {
  #  ssh-keys = "${google_compute_ssh_key.my_key.name}:${file("~/.ssh/id_ed25519.pub")}"
  #}
}

output "instance_ip_address" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config[0].nat_ip
}



