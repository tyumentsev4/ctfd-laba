resource "selectel_iam_serviceuser_v1" "serviceuser_1" {
  name     = var.project_serviceuser_username
  password = var.project_serviceuser_password
  role {
    role_name  = "member"
    scope      = "project"
    project_id = selectel_vpc_project_v2.project.id
  }
}
