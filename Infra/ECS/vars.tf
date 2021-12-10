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
  default = "10.0.0.0/16"
}

variable "subnet_count" {
  type    = number
  default = 3
}

variable "app-count" {
    type = number
    default = 1
}

variable "container-port" {
  type = list(number) 
  default = [80,3306]
}

variable "container-memory" {
  type = list(number)
  default = [512,512]
}

variable "container-cpu" {
  type = list(number)
  default = [256,256]
}