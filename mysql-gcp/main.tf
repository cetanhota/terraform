provider "google" {
  project     = "zinc-primer-321323"
  region      = "us-east1"  # Change to your desired region
}

resource "random_password" "mysqldba_pwd" {
  length = 8
  min_upper = 1
  min_lower = 1
  min_numeric = 1
  min_special = 1
}

resource "google_sql_database_instance" "weather-srv1" {
  name             = "weather-srv1"
  database_version = "MYSQL_8_0"
  region           = "us-east1"  # Change to your desired region
  settings {
    #tier = "db-n1-standard-1"  # Change to your desired machine type
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "admin_user" {
  name     = "mysqldba"
  instance = google_sql_database_instance.weather-srv1.name
  password = random_password.mysqldba_pwd.result  # Replace with your desired user password
}

resource "google_sql_database" "db_name" {
    name = "sbtest"
    instance = google_sql_database_instance.weather-srv1.name
}

output "password" {
  value     = random_password.mysqldba_pwd.result
  sensitive = true
}