# Script pour activer les entites remote Broadlink
$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = $env:HA_TOKEN

if (-not $HA_TOKEN) {
    Write-Host "ERREUR: Variable HA_TOKEN non definie" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $HA_TOKEN"
    "Content-Type" = "application/json"
}

Write-Host "Activation des remotes Broadlink..." -ForegroundColor Cyan

# Activer remote.clim_maeva
try {
    $body = @{entity_id = "remote.clim_maeva"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$HA_URL/api/services/homeassistant/turn_on" -Headers $headers -Method Post -Body $body
    Write-Host "[OK] remote.clim_maeva active" -ForegroundColor Green
} catch {
    Write-Host "[ERREUR] remote.clim_maeva : $_" -ForegroundColor Red
}

# Activer remote.clim_axel
try {
    $body = @{entity_id = "remote.clim_axel"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$HA_URL/api/services/homeassistant/turn_on" -Headers $headers -Method Post -Body $body
    Write-Host "[OK] remote.clim_axel active" -ForegroundColor Green
} catch {
    Write-Host "[ERREUR] remote.clim_axel : $_" -ForegroundColor Red
}

Write-Host "`nVerification des etats..." -ForegroundColor Cyan
Start-Sleep -Seconds 2

# Verifier les etats
$remotes = @("remote.clim_salon", "remote.clim_maeva", "remote.clim_axel")
foreach ($remote in $remotes) {
    try {
        $state = Invoke-RestMethod -Uri "$HA_URL/api/states/$remote" -Headers $headers -Method Get
        $color = if ($state.state -eq "on") { "Green" } else { "Red" }
        Write-Host "$remote : $($state.state)" -ForegroundColor $color
    } catch {
        Write-Host "$remote : ERREUR" -ForegroundColor Red
    }
}
