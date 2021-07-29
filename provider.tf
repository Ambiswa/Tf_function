provider "aws" {
  access_key = var.pvt_keys["aws_access_key_id"]#file(var.pvt_keys["aws_access_key_id"])
  secret_key = var.pvt_keys["aws_secret_access_key"]#file(var.pvt_keys["aws_secret_access_key"])
  region  = "${var.region}" #Or var.region
}