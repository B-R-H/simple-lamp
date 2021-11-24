variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "env-tag" {
    type = string
    default = "LAMP"
}

variable "registries" {
    type = list(string)
    default = [ "lamp","lampsql" ]
}