variable "resource_group" {
  default = "weather_group"
}

variable "location" {
  default = "East US"
}

variable "rule_name" {
  default = "ClientIPAllow"
}

variable "start_ip_address" {
  default = "76.34.99.14"
}

variable "database_name" {
  default = "sbtest"
}

variable "audit_log_enabled" {
    default = "ON"
}

variable "audit_log_events" {
    default = "CONNECTION,GENERAL,TABLE_ACCESS"
}

variable "admin_id" {
  default = "mysqldba"
}