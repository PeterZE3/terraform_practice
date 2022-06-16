#works, but independatly of the vm

# resource "azurerm_storage_account" "storage" {
#   name                     = "peterze3storage"
#   resource_group_name      = azurerm_resource_group.vm-group.name
#   location                 = azurerm_resource_group.vm-group.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   account_kind             = "StorageV2"

#   static_website {
#     index_document = "index.html"
#   }
# }

# resource "azurerm_storage_blob" "files" {
#   name                   = "index.html"
#   storage_account_name   = azurerm_storage_account.storage.name
#   storage_container_name = "$web"
#   type                   = "Block"
#   content_type           = "text/html"
#   source                 = "index.html"

#   depends_on = [
#     azurerm_storage_account.storage
#   ]
# }