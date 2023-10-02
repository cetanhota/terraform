## password="$(terraform output -raw password)"
## az mysql flexible-server firewall-rule create --resource-group weather_group --name weather-fs1 --rule-name ClientAPIAllow --start-ip-address 76.34.99.14
## az mysql flexible-server firewall-rule create --resource-group weather_group --name weather-fs1 --rule-name "AllowAllWindowsAzureIps" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0


provider "azurerm" {
  features {

  }
}

resource "random_password" "mysqldba_pwd" {
  length = 8
  min_upper = 1
  min_lower = 1
  min_numeric = 1
  min_special = 1
}

resource "azurerm_mysql_flexible_server" "mysqlfs" {
  name                = "weather-fs1"
  location            = var.location
  resource_group_name = var.resource_group
  administrator_login = "mysqldba"
  administrator_password = random_password.mysqldba_pwd.result
  sku_name            = "GP_Standard_D2ds_v4"
  version             = "8.0.21"

  tags = {
    environment = "development"
  }

provisioner "local-exec" {
    command = "az mysql flexible-server firewall-rule create --resource-group ${var.resource_group} --name ${azurerm_mysql_flexible_server.mysqlfs.name} --rule-name ${var.rule_name} --start-ip-address ${var.start_ip_address}"
        }

provisioner "local-exec" {
    command = "az mysql flexible-server db create --resource-group ${var.resource_group} --server-name ${azurerm_mysql_flexible_server.mysqlfs.name} --database-name sbtest"
    }
}


output "password" {
  value     = random_password.mysqldba_pwd.result
  sensitive = true
}

