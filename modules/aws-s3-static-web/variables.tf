variable "bucket_name" {
  description = "Name of the s3 bucket. Must be unique"
  type = string 
}

variable "tags" {
  description = "Map of tags to set on the website bucket"
  type = map(string)
  default = {}
}

variable "index_document_suffix" {
  description = "Suffix for index document of website bucket"
  type = string 
  default = "index.html"
}

variable "error_document_key" {
  description = "Key for error document of website bucket"
  type = string 
  default = "error.html"
}

variable "www_path" { 
  description = "Local absolute or relative path containing files to upload to website bucket"
  type = string 
  default = null
}

variable "terraform_managed_files" {
  description = "Flag to indicate whether Terraform should upload files to the bucket"
  type = bool 
  default = true
}