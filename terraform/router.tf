data "openstack_networking_network_v2" "external_network_1" {
  external = true
  name     = "external-network"

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}

data "openstack_networking_subnet_ids_v2" "ext_subnets" {
  network_id = data.openstack_networking_network_v2.external_network_1.id
  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "router"
  external_network_id = data.openstack_networking_network_v2.external_network_1.id

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}
