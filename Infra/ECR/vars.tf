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

variable "vpc-cidr" {
  type = string
  default = "10.2.0.0/16"
}