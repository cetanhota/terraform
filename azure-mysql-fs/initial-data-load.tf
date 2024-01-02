resource "null_resource" "load_data" {

  provisioner "local-exec" {
    on_failure = continue
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
        /usr/local/mysql/bin/mysql -h ${azurerm_mysql_flexible_server.mysqlfs.name}.mysql.database.azure.com  -u ${var.admin_id} -p${var.db_password} < /Users/wayne/mysql-load-data.sql
     EOT
  }
}