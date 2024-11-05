# https://learn.microsoft.com/en-us/azure/container-apps/sessions-custom-container?tabs=azure-cli

# Create a custom container session pool

$rg = 'aca-session-demo'
$location = 'westus2'
$sessionPoolName = 'session-pool-custom'

$acaEnvironmnentName = 'aca-session-environment'
$imageName = 'docker.io/davidxw/webtest:latest'

az group create --name $rg --location $location

az containerapp env create -n $acaEnvironmnentName -g $rg --location $location --enable-workload-profiles

az containerapp sessionpool create `
    --name $sessionPoolName `
    --resource-group $rg `
    --environment $acaEnvironmnentName `
    --location $location `
    --image $imageName `
    --container-type CustomContainer `
    --max-sessions 100 `
    --cooldown-period 300 `
    --cpu 0.5 --memory 1.0Gi `
    --target-port 8080 `
    --network-status EgressEnabled

Write-Host "Session pool created: $sessionPoolName. Use the endpoint below to create and execute code in sessions."
 
az containerapp sessionpool show `
    --name $sessionPoolName `
    --resource-group $rg `
    --query 'properties.poolManagementEndpoint' -o tsv
