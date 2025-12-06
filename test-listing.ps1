$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjQwNTdhYi05MzdhLTQyOTItODcwNy01MWQ2OTc4YjQ0NjciLCJlbWFpbCI6ImphbmVAZXhhbXBsZS5jb20iLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NjQ5NjI4MDgsImV4cCI6MTc2NDk2MzcwOH0.lLpHN3xUsDWX--hq_W3fQJekXjOI2NPvG64KPrUDc9I"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "multipart/form-data"
}

$body = @{
    title = "Test Catering Service"
    description = "Professional catering service for events"
    category = "Catering"
    location = "Ghaziabad, 201005"
    pricePerDay = "2999"
}

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/v1/listings" `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -ContentType "multipart/form-data"
    
    Write-Host "Success!"
    Write-Host ($response.Content | ConvertFrom-Json | ConvertTo-Json)
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    Write-Host ($_.Exception.Response.Content | ConvertFrom-Json | ConvertTo-Json)
}
