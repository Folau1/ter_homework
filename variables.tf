###cloud vars


variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  default     = "b1gv7lvg8rc9365h90lt"
}


variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  default     = "b1g40q4ai8pdtrbga82v"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}


###ssh vars
/*
variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7ddeviVfE+Hr6gOpz1kAiFIPfL/rqUhN4VitUwAFJOzbXwZlll/7mBLkHQ1xD+Nvy0+z0UEihyS5hilTi9Hp6WB4dLfASR1xs2j0AXS/7BUolX1HyBfIe53jBM38tKj14COG2XjV+6N5TlgQm7WOUJyIxIznfXhC2G/+EjOdvpJ3AN6S9Ew8F01AlCBPCLouMXP+bbh/X9po5NHhRF33Y7zVAqp4/2hxOL/sw7Innv6Mb2K817qk7a08n0v46WsPFf/tS/HTJ/4KpjOyJl9c6U+zJjofNBpW5l0jTv4FsJyCVR9Ji/9Ib3nSnAK9314rk3YFllVtrHop0OP5MUUQX"
  description = "ssh-keygen -t ed25519"
}
*/
variable "test" {
  type = list(map(list(string)))
}