## password="$(terraform output -raw password)"
## az mysql flexible-server firewall-rule create --resource-group weather_group --name weather-fs1 --rule-name ClientAPIAllow --start-ip-address 76.34.99.14
## az mysql flexible-server firewall-rule create --resource-group weather_group --name weather-fs1 --rule-name "AllowAllWindowsAzureIps" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

# resource "random_password" "mysqldba_pwd" {
#   length      = 8
#   min_upper   = 1
#   min_lower   = 1
#   min_numeric = 1
#   min_special = 1
# }

resource "azurerm_mysql_flexible_server" "mysqlfs" {
  name                   = "weather-fs1"
  location               = var.location
  resource_group_name    = var.resource_group
  administrator_login    = var.admin_id
  administrator_password = var.db_password
  #sku_name               = "GP_Standard_D2ds_v4"
  sku_name                = "B_Standard_B1ms"
  version                 = "8.0.21"
  zone = 2

  tags = {
    environment = "development"
    database_name = var.database_name
  }

  provisioner "local-exec" {
    command = "az mysql flexible-server firewall-rule create --resource-group ${var.resource_group} --name ${azurerm_mysql_flexible_server.mysqlfs.name} --rule-name ${var.rule_name} --start-ip-address ${var.start_ip_address}"
  }

  #provisioner "local-exec" {
  #  command = "az mysql flexible-server execute --admin-password ${var.db_password} --admin-user ${var.admin_id} --name ${azurerm_mysql_flexible_server.mysqlfs.name} --file-path /Users/wayne/mysql-load-data.sql"
  #}
}

resource "azurerm_mysql_flexible_database" "default_db" {
  name                = var.database_name
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_flexible_server.mysqlfs.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# output "password" {
#   value     = random_password.mysqldba_pwd.result
#   sensitive = true
# }

# Enable Audit Logging
resource "azurerm_mysql_flexible_server_configuration" "audit_log_enabled" {
  name = "audit_log_enabled"
  resource_group_name = var.resource_group
  server_name = azurerm_mysql_flexible_server.mysqlfs.name
  value = var.audit_log_enabled
}

# Audit Log Events
resource "azurerm_mysql_flexible_server_configuration" "audit_log_events" {
  name = "audit_log_events"
  resource_group_name = var.resource_group
  server_name = azurerm_mysql_flexible_server.mysqlfs.name
  value = var.audit_log_events
}

resource "azurerm_mysql_flexible_server_configuration" "enable_logs" {
  name = "slow_query_log"
  resource_group_name = var.resource_group
  server_name = azurerm_mysql_flexible_server.mysqlfs.name
  value = "ON"
}

resource "azurerm_mysql_flexible_server_configuration" "server_logs" {
  name = "log_output"
  resource_group_name = var.resource_group
  server_name = azurerm_mysql_flexible_server.mysqlfs.name
  value = "FILE"
}

resource "azurerm_mysql_flexible_server_configuration" "long_query_time" {
  name = "long_query_time"
  resource_group_name = var.resource_group
  server_name = azurerm_mysql_flexible_server.mysqlfs.name
  value = "10"
}

resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name = "require_secure_transport"
  resource_group_name = var.resource_group
  server_name = azurerm_mysql_flexible_server.mysqlfs.name
  value = "ON"
}

resource "null_resource" "load_data" {

  provisioner "local-exec" {
    on_failure = continue
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
        /usr/local/mysql/bin/mysql -h ${azurerm_mysql_flexible_server.mysqlfs.name}.mysql.database.azure.com  -u ${var.admin_id} -p${var.db_password} < /Users/wayne/mysql-load-data.sql
     EOT
  }
}