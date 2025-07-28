{
  # Configure the source directory (where .ncl files are located)
  source_dir = "nickel",
  
  # Configure the output directory (where Terraform .tf files will be generated)
  output_dir = "terraform",
  
  # Optional: Set resource name mappings
  resource_name_format = "%s",
  
  # Optional: Configure provider-specific settings
  providers = {
    azurerm = {
      # You can add provider-specific configuration here
    },
  },
}