# https://learn.microsoft.com/en-us/azure/container-apps/sessions-code-interpreter

# Create a code interpreter session pool

$rg = 'aca-session-scratch'
$location = 'westus2'
$sessionPoolName = 'session-pool-1'

az group create --name $rg --location $location

az containerapp sessionpool create `
    --name $sessionPoolName `
    --resource-group $rg `
    --location $location `
    --container-type PythonLTS `
    --max-sessions 100 `
    --cooldown-period 300 `
    --network-status EgressEnabled

Write-Host "Session pool created: $sessionPoolName. Use the endpoint below to create and execute code in sessions."
 
az containerapp sessionpool show `
    --name $sessionPoolName `
    --resource-group $rg `
    --query 'properties.poolManagementEndpoint' -o tsv
