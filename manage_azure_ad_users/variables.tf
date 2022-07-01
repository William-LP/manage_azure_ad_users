variable "internal_users_csv_file" {
  type        = string
  description = "(Required) Path of CSV file with internal users to create. Must match following format : first_name,last_name,department,job_title"
}

variable "internal_domain" {
  type        = string
  description = "(Required) Internal DNS name used in mail addresses"
}

variable "group_projects" {
  type        = string
  description = "(Required) Path of CSV files with group project. Must match following format : email"
}