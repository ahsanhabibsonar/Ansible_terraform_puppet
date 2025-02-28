  output "instance_ip_address" {
    description = " The IPv4 address of the compute instance"
    value       = [for instance in openstack_compute_instance_v2.myVM : instance.access_ip_v4]
    #value       = openstack_compute_instance_v2.myVM[count.index].access_ip_v4
  } 

