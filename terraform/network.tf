resource "openstack_networking_network_v2" "network_1" {
  name           = "private-network"
  admin_state_up = "true"

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "private-subnet"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = var.subnet_cidr

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}

resource "openstack_networking_floatingip_v2" "floatingip_nfs01" {
  pool       = data.openstack_networking_network_v2.external_network_1.name
  subnet_ids = data.openstack_networking_subnet_ids_v2.ext_subnets.ids
  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}

resource "openstack_networking_floatingip_associate_v2" "association_nfs01" {
  floating_ip = openstack_networking_floatingip_v2.floatingip_nfs01.address
  port_id     = openstack_networking_port_v2.port_1_nfs01.id

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}

resource "openstack_networking_port_v2" "port_1_nfs01" {
  name       = "port_1"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = cidrhost(var.subnet_cidr, 4)
  }

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}

resource "openstack_networking_floatingip_v2" "ingress_loadbalancer_ip" {
  pool       = data.openstack_networking_network_v2.external_network_1.name
  subnet_ids = data.openstack_networking_subnet_ids_v2.ext_subnets.ids

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}
