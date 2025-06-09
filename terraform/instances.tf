data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 22.04 LTS 64-bit"
  most_recent = true
  visibility  = "public"

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}

resource "openstack_blockstorage_volume_v3" "volume_nfs01" {
  name                 = "boot-volume-for-nfs-server"
  size                 = "40"
  image_id             = data.openstack_images_image_v2.ubuntu.id
  volume_type          = "fast.${var.selectel_segment}"
  availability_zone    = var.selectel_segment
  enable_online_resize = true

  lifecycle {
    ignore_changes = [image_id]
  }

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}

resource "openstack_compute_instance_v2" "nfs01" {
  name = "nfs01"
  // https://docs.selectel.ru/en/cloud/servers/create/configurations/
  flavor_id         = "1011" // 1 vCPU; 1 GiB RAM
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.selectel_segment

  user_data = templatefile("${path.module}/templates/user-data.tpl", {
    ssh_user       = var.ssh_user
    ssh_public_key = file(var.ssh_public_key_path)
  })

  network {
    port = openstack_networking_port_v2.port_1_nfs01.id
  }

  lifecycle {
    ignore_changes = [image_id]
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_nfs01.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }
  vendor_options {
    ignore_resize_confirmation = true
  }
  tags = ["preemptible"]

  depends_on = [
    selectel_vpc_project_v2.project,
    selectel_iam_serviceuser_v1.serviceuser_1
  ]
}
