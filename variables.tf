# Define the variables used in the main.tf file
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "bucket_name" {
  description = "Name of the GCS bucket"
  type        = string
  default     = "bug-bucket-123"
}

