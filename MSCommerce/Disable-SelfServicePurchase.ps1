# REQUIRED -- Run PowerShell as an adminstrator

# MSCommerce Module is required
Install-Module MSCommerce -Confirm:$false

# Save the origianl Security Procols and display.
$Original = [System.Net.ServicePointManager]::SecurityProtocol; Write-Output $Original

# Set the Service Point Manager Security Protocol to TLS12
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Microsoft will prompt for credentials.
Connect-MSCommerce
Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase

# This will enumerate through each product and set the policy value from enabled to disabled. 
Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase | Where-Object {$_.PolicyValue -eq "Enabled" } | ForEach-Object { Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $_.ProductId -Enabled $False }

# Revert the Security Procotol back to the original
[System.Net.ServicePointManager]::SecurityProtocol = $Original
