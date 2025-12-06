@echo off
setlocal enabledelayedexpansion

set TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjQwNTdhYi05MzdhLTQyOTItODcwNy01MWQ2OTc4YjQ0NjciLCJlbWFpbCI6ImphbmVAZXhhbXBsZS5jb20iLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NjQ5NjI4MDgsImV4cCI6MTc2NDk2MzcwOH0.lLpHN3xUsDWX--hq_W3fQJekXjOI2NPvG64KPrUDc9I

echo Testing listing creation with multipart form data...

curl -X POST http://localhost:3000/api/v1/listings ^
  -H "Authorization: Bearer %TOKEN%" ^
  -F "title=Test Catering Service" ^
  -F "description=Professional catering service for events" ^
  -F "category=Catering" ^
  -F "location=Ghaziabad, 201005" ^
  -F "pricePerDay=2999"

pause
