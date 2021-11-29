variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "env-tag" {
  type    = string
  default = "LAMP"
}
variable "vpc-cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "subnet-count" {
  type    = number
  default = 2
}

variable "app-count" {
    type = number
    default = 1
}