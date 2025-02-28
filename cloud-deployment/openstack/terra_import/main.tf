
locals {
  instances = {
    web = "7bd0a229-ccd0-4f42-a128-3e003c37f97d"
    dev = "8ad1b339-eed1-4f53-a229-4f113c37b98e"
  }
}

resource "openstack_compute_instance_v2" "my_instance" {
  for_each        = local.instances
  name            = each.key
  flavor_name     = "aem.1c2r.50g"
  key_pair        = "new_key"
  image_name      = "Ubuntu 24.04-LTS (Noble Numbat)"
  security_groups = ["default"]

  network {
    name = "oslomet"
  }
}
#locals {
#  instance_names = ["web", "dev"]
#}
#
#resource "openstack_compute_instance_v2" "myvm" {
#  count           = length(local.instance_names)
#  name            = element(local.instance_names, count.index)
#  flavor_name     = "aem.1c2r.50g"
#  key_pair        = "new_key"
#  image_name      = "Ubuntu 24.04-LTS (Noble Numbat)"
#  security_groups = ["default"]
#
#  network {
#    name = "oslomet"
#  }
#}
