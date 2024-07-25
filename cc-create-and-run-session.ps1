# Create and run sessions in custom container session pool

param (
    [string]$endPoint,
    [string]$accessToken,
    [string]$sessionId
)

function Write-Host-With-TimeStamp {
    param (
        [string]$message
    )

    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    Write-Host "$date " -NoNewline -ForegroundColor Blue
    Write-Host $message
    
}

function Write-Usage-and-Exit {
    Write-Host "usage: cc-create-and-run-session.ps1 -endPoint <poolManagementEndpoint> [-accessToken <accessToken>] [-sessionId <sessionId>]"
    Exit
}

if (!$endPoint) {
    Write-Usage-and-Exit
}

if (![Uri]::IsWellFormedUriString($endPoint, [UriKind]::Absolute)) {
    Write-Usage-and-Exit
}

if (!$accessToken) {
    $accessToken = az account get-access-token --resource https://dynamicsessions.io --query 'accessToken' -o tsv
}

if (!$sessionId) {
    $sessionId = (New-Guid).Guid
}

Write-Host-With-TimeStamp -message "Session ID: $sessionId"


### Call API in custom session

Write-Host-With-TimeStamp -message "Calling API in a session"

$headers = @{
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer $accessToken"
}

# url to call. In this case "/api/environment" is a HTTP method exposed by the container

$url = "$endPoint/api/environment?identifier=$sessionId"

# Make the GET request
$response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

if ($response) {
    Write-Host-With-TimeStamp -message "Code execution completed"

    # Output the response
    Write-Host-With-TimeStamp -message "Response:" 
    Write-Host "Machine Nmae:    $($response.MachineName)"
    Write-Host "IP Addresses:    $($response.IpAddresses)"
    Write-Host "Processor Count: $($response.ProcessorCount)"
}




