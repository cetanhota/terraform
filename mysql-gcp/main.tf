provider "google" {
  project = var.project
  #region      = "us-east1"  # Change to your desired region
}

# resource "random_password" "mysqldba_pwd" {
#   length      = 8
#   min_upper   = 1
#   min_lower   = 1
#   min_numeric = 1
#   min_special = 1
# }

resource "google_sql_database_instance" "gcp_cloud_mysql" {
  name             = var.server-name
  database_version = var.mysql_version
  region           = var.region 
  settings {
    tier = "db-f1-micro"
    #deletion_protection_enabled = var.deletion_protection_enabled
    availability_type = "REGIONAL"
    edition = var.edition
    backup_configuration {
      enabled = true
      binary_log_enabled = true
      backup_retention_settings {
        retained_backups = 7
      }
    }
    ip_configuration {
      authorized_networks {
        name  = var.network
        value = var.ip_address
      }
    }
    database_flags {
      name  = "audit_log"
      value = "ON"
    }
    database_flags {
      name = "long_query_time"
      value = "10"
    }
    database_flags {
      name = "slow_query_log"
      value = "ON"
    }
    database_flags {
      name = "skip_show_database"
      value = "ON"
    }
  }
  deletion_protection = false
}

resource "google_sql_user" "admin_user" {
  name     = var.admin_id
  host     = "%"
  instance = google_sql_database_instance.gcp_cloud_mysql.name
  #password = random_password.mysqldba_pwd.result # Replace with your desired user password
  password = var.db_password
}

resource "google_sql_database" "db_name" {
  name     = var.db_name
  instance = google_sql_database_instance.gcp_cloud_mysql.name
}

# output "password" {
#   value     = random_password.mysqldba_pwd.result
#   sensitive = true
# }