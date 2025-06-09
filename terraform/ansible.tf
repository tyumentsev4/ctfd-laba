resource "local_file" "nfs_invenotry" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      nfs01_ip   = openstack_networking_floatingip_v2.floatingip_nfs01.address
      nfs01_user = var.ssh_user
    }
  )
  filename = "../nfs-playbook/inventories/selectel/hosts.yaml"
}

resource "null_resource" "ansible_provision" {
  depends_on = [
    openstack_compute_instance_v2.nfs01, 
    local_file.nfs_invenotry, 
    openstack_networking_floatingip_associate_v2.association_nfs01
  ]

  provisioner "local-exec" {
    working_dir = "../nfs-playbook"
    command     = "while ! nc -z ${openstack_networking_floatingip_v2.floatingip_nfs01.address} 22; do sleep 1; done; ansible-galaxy install -r requirements.yml && ansible-playbook -i inventories/selectel/hosts.yaml playbook.yml"
  }
}
