variable "pvt_keys" {
	default={
		"aws_access_key_id" = "C:/Users/bprasadmahapatra/Documents/Terraform/files/S3_Lambda_Main_File/pvt_keys/a_key.txt"
		"aws_secret_access_key" = "C:/Users/bprasadmahapatra/Documents/Terraform/files/S3_Lambda_Main_File/pvt_keys/s_key.txt"
	}
}
variable "region" {
	default = "us-east-2"
}
variable "runtime" {
	default = "python3.8"
}