variable "s3_bucket_name" {
  default = ""
}

variable "test_1" {
  default = ""
  sensitive = true
}

variable "test_2" {
  default = ""
}

variable "test_3" {
  default = ""
}

output "test_11" {
   default = var.test_1
}

output "test_12" {
   default = var.test_2
}

