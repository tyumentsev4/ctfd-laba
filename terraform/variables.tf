variable "ssh_public_key_path" {
  type    = string
  default = "id_ssh.pub"
}

variable "ssh_user" {
  type    = string
  default = "ansible"
}

variable "selectel_pool" {
  type    = string
  default = "ru-9"
}

variable "selectel_segment" {
  type    = string
  default = "ru-9a"
}

variable "selectel_domain_name" {
  type = string
}


variable "selectel_username" {
  type = string
}


variable "selectel_password" {
  type = string
}

variable "project_serviceuser_username" {
  type = string
}

variable "project_serviceuser_password" {
  type = string
}

variable "project_name" {
  type    = string
  default = "new project"
}

variable "mariadb_root_password" {
  type      = string
  sensitive = true
}

variable "mariadb_mariabackup_password" {
  type      = string
  sensitive = true
}

variable "mariadb_password" {
  type      = string
  sensitive = true
}

variable "redis_password" {
  type      = string
  sensitive = true
}

variable "subnet_cidr" {
  type    = string
  default = "192.168.199.0/24"
}

variable "domain_zone" {
  type = string
}
