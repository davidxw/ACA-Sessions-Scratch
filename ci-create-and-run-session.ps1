param (
   [string]$endPoint,
   [string]$accessToken,
   [string]$sessionId,
   [string]$weatherApiKey
)

function Write-Host-With-TimeStamp {
    param (
        [string]$message
    )

    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    Write-Host "$date " -NoNewline -ForegroundColor Blue
    Write-Host $message
    
}

if (!$endPoint)
{
    Write-Host "usage: create-and-run-session.ps1 -endPoint <poolManagementEndpoint> -weatherApiKey <weatherApiKey> [-accessToken <accessToken>] [-sessionId <sessionId>]"
    Exit
}

if (![Uri]::IsWellFormedUriString($endPoint, [UriKind]::Absolute)) {
    Write-Output "$endPoint is not a valid URL."
    Exit
}

# https://www.weatherapi.com/my/
if (!$weatherApiKey)
{
    Write-Host "usage: create-and-run-session.ps1 -endPoint <poolManagementEndpoint> -weatherApiKey <weatherApiKey> [-accessToken <accessToken>] [-sessionId <sessionId>]"
    Exit
}

if (!$accessToken)
{
    $accessToken = az account get-access-token --resource https://dynamicsessions.io --query 'accessToken' -o tsv
}

if (!$sessionId)
{
    $sessionId = (New-Guid).Guid
}

Write-Host-With-TimeStamp -message "Session ID: $sessionId"

### Upload code file

Write-Host-With-TimeStamp -message "Uploading python script to session"

$fileName = 'cached_weather.py'
$filePath = ".\$fileName";
$url = "$endPoint/files/upload?api-version=2024-02-02-preview&identifier=$sessionId"

$fileBytes = [System.IO.File]::ReadAllBytes($filePath);
$fileEnc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes);
$boundary = [System.Guid]::NewGuid().ToString(); 
$LF = "`r`n";

$headers = @{
    "Content-Type" = "multipart/form-data; boundary=$boundary"
    "Authorization" = "Bearer $accessToken"
}

$body = ( 
    "--$boundary",
    "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",
    "Content-Type: application/octet-stream$LF",
    $fileEnc,
    "--$boundary--$LF" 
) -join $LF

$response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body 

Write-Host-With-TimeStamp -message "Upload complete"

### Run script

Write-Host-With-TimeStamp -message "Executing code in a session"

$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $accessToken"
}

#$code = "print('Hello, world!')"
$code = @"
import sys
sys.path.insert(1, '/mnt/data')
from cached_weather import get_local_weather

get_local_weather('$weatherApiKey')
"@

# Define the body
$body = @{
    properties = @{
        codeInputType = "inline"
        executionType = "synchronous"
        code = $code
    }
} | ConvertTo-Json

$url = "$endPoint/code/execute?api-version=2024-02-02-preview&identifier=$sessionId"

# Make the POST request
$response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body 

Write-Host-With-TimeStamp -message "Code execution completed"

# Output the response
Write-Host-With-TimeStamp -message "status: $($response.properties.status)" 
Write-Host-With-TimeStamp -message "execms: $($response.properties.executionTimeInMilliseconds)" 
Write-Host-With-TimeStamp -message "stdout:" 
Write-Host $($response.properties.stdout)
Write-Host-With-TimeStamp -message "stderr:"
Write-Host $($response.properties.stderr) 



