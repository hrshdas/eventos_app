# EVENTOS Backend API Test Script (PowerShell)
# Run this script to test all endpoints

$BASE_URL = "http://localhost:3000"
$accessToken = ""
$refreshToken = ""
$listingId = ""
$bookingId = ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EVENTOS Backend API Test Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "1. Testing Health Check..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/health" -Method Get
    Write-Host "   ✅ Health check passed" -ForegroundColor Green
    Write-Host "   Database: $($response.database)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Health check failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 2: Sign Up
Write-Host "2. Testing Sign Up..." -ForegroundColor Yellow
try {
    $body = @{
        name = "Test User"
        email = "test$(Get-Random)@example.com"
        password = "test123456"
        role = "CONSUMER"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/v1/auth/signup" -Method Post -Body $body -ContentType "application/json"
    $accessToken = $response.data.accessToken
    $refreshToken = $response.data.refreshToken
    Write-Host "   ✅ Sign up successful" -ForegroundColor Green
    Write-Host "   User ID: $($response.data.user.id)" -ForegroundColor Gray
    Write-Host "   Email: $($response.data.user.email)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Sign up failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 3: Get Profile
Write-Host "3. Testing Get Profile..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/v1/users/me" -Method Get -Headers $headers
    Write-Host "   ✅ Get profile successful" -ForegroundColor Green
    Write-Host "   Name: $($response.data.name)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Get profile failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 4: Sign Up as Owner
Write-Host "4. Testing Sign Up as Owner..." -ForegroundColor Yellow
try {
    $body = @{
        name = "Owner User"
        email = "owner$(Get-Random)@example.com"
        password = "test123456"
        role = "OWNER"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/v1/auth/signup" -Method Post -Body $body -ContentType "application/json"
    $ownerToken = $response.data.accessToken
    Write-Host "   ✅ Owner sign up successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Owner sign up failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 5: Create Listing
Write-Host "5. Testing Create Listing..." -ForegroundColor Yellow
try {
    $body = @{
        title = "Test Venue"
        description = "A beautiful test venue for events"
        category = "venue"
        pricePerDay = 5000
        location = "Test City"
        images = @("https://example.com/image.jpg")
    } | ConvertTo-Json
    
    $headers = @{
        "Authorization" = "Bearer $ownerToken"
    }
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/v1/listings" -Method Post -Body $body -ContentType "application/json" -Headers $headers
    $listingId = $response.data.id
    Write-Host "   ✅ Create listing successful" -ForegroundColor Green
    Write-Host "   Listing ID: $listingId" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Create listing failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 6: Get Listings
Write-Host "6. Testing Get Listings..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/v1/listings" -Method Get
    Write-Host "   ✅ Get listings successful" -ForegroundColor Green
    Write-Host "   Total listings: $($response.data.total)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Get listings failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 7: Create Booking
Write-Host "7. Testing Create Booking..." -ForegroundColor Yellow
if ($listingId) {
    try {
        $startDate = (Get-Date).AddDays(30).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        $endDate = (Get-Date).AddDays(32).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        
        $body = @{
            listingId = $listingId
            startDate = $startDate
            endDate = $endDate
        } | ConvertTo-Json
        
        $headers = @{
            "Authorization" = "Bearer $accessToken"
        }
        $response = Invoke-RestMethod -Uri "$BASE_URL/api/v1/bookings" -Method Post -Body $body -ContentType "application/json" -Headers $headers
        $bookingId = $response.data.id
        Write-Host "   ✅ Create booking successful" -ForegroundColor Green
        Write-Host "   Booking ID: $bookingId" -ForegroundColor Gray
        Write-Host "   Total Amount: $($response.data.totalAmount)" -ForegroundColor Gray
    } catch {
        Write-Host "   ❌ Create booking failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "   ⚠️  Skipped (no listing ID)" -ForegroundColor Yellow
}
Write-Host ""

# Test 8: Create Payment
Write-Host "8. Testing Create Payment..." -ForegroundColor Yellow
if ($bookingId) {
    try {
        $body = @{
            bookingId = $bookingId
            currency = "USD"
        } | ConvertTo-Json
        
        $headers = @{
            "Authorization" = "Bearer $accessToken"
        }
        $response = Invoke-RestMethod -Uri "$BASE_URL/api/v1/payments/create" -Method Post -Body $body -ContentType "application/json" -Headers $headers
        Write-Host "   ✅ Create payment successful" -ForegroundColor Green
        Write-Host "   Payment ID: $($response.data.paymentId)" -ForegroundColor Gray
        Write-Host "   Payment Intent ID: $($response.data.paymentIntentId)" -ForegroundColor Gray
    } catch {
        Write-Host "   ❌ Create payment failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "   ⚠️  Skipped (no booking ID)" -ForegroundColor Yellow
}
Write-Host ""

# Test 9: AI Planner
Write-Host "9. Testing AI Planner..." -ForegroundColor Yellow
try {
    $body = @{
        eventType = "wedding"
        budget = 10000
        guests = 100
        location = "outdoor"
        date = "2024-06-15"
        vibe = "elegant"
        theme = "rustic"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/v1/ai-planner/suggest" -Method Post -Body $body -ContentType "application/json"
    Write-Host "   ✅ AI Planner successful" -ForegroundColor Green
    Write-Host "   Theme: $($response.data.theme)" -ForegroundColor Gray
    Write-Host "   Total Estimated Cost: $($response.data.totalEstimatedCost)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ AI Planner failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 10: Error Handling
Write-Host "10. Testing Error Handling..." -ForegroundColor Yellow
try {
    $body = @{
        email = "invalid-email"
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$BASE_URL/api/v1/auth/signup" -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
    Write-Host "   ❌ Should have failed validation" -ForegroundColor Red
} catch {
    $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
    if ($errorResponse.code -eq "VALIDATION_ERROR") {
        Write-Host "   ✅ Validation error handling works" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Unexpected error: $($errorResponse.code)" -ForegroundColor Yellow
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ All tests completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

