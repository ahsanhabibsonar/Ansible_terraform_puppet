output "instance_ip_address" {
  description = " The IPv4 address of the compute instance"
  value       = openstack_compute_instance_v2.myVM.access_ip_v4
}

#output "vm_name" {
#value = openstack_compute_instance_v2.myVM.name
#}

