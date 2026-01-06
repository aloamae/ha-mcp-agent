# Active tous les remotes Broadlink (climatisations)

$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = $env:HA_TOKEN

if (-not $HA_TOKEN) {
    Write-Host "Variable HA_TOKEN non definie - Utilisation du token par defaut" -ForegroundColor Yellow
    $HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"
}

$headers = @{
    "Authorization" = "Bearer $HA_TOKEN"
    "Content-Type" = "application/json"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ACTIVATION REMOTES BROADLINK" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$remotes = @("remote.clim_salon", "remote.clim_maeva", "remote.clim_axel")

foreach ($remote in $remotes) {
    Write-Host "Activation de $remote..." -ForegroundColor Yellow

    try {
        $body = @{
            entity_id = $remote
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri "$HA_URL/api/services/homeassistant/turn_on" `
            -Headers $headers -Method POST -Body $body -TimeoutSec 10

        Write-Host "  OK - $remote active" -ForegroundColor Green
    }
    catch {
        Write-Host "  ERREUR - $remote : $_" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "`nVerification des etats..." -ForegroundColor Cyan

foreach ($remote in $remotes) {
    try {
        $state = Invoke-RestMethod -Uri "$HA_URL/api/states/$remote" `
            -Headers $headers -Method Get -TimeoutSec 10

        $color = if ($state.state -eq "on") { "Green" } else { "Red" }
        Write-Host "$remote : $($state.state)" -ForegroundColor $color
    }
    catch {
        Write-Host "$remote : ERREUR - $_" -ForegroundColor Red
    }
}

Write-Host "`nTermine`n" -ForegroundColor Green
