# Script pour recuperer le detail d'une automation
param(
    [string]$AutomationId = "automation.telegram_chauffage_off_vacances"
)

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

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DETAIL DE L'AUTOMATION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

try {
    $state = Invoke-RestMethod -Uri "$HA_URL/api/states/$AutomationId" -Headers $headers -Method Get

    Write-Host "Entity ID: $($state.entity_id)" -ForegroundColor Yellow
    Write-Host "Nom: $($state.attributes.friendly_name)" -ForegroundColor White
    Write-Host "Etat: $($state.state)" -ForegroundColor $(if ($state.state -eq "on") { "Green" } else { "Red" })
    Write-Host "Dernier declenchement: $($state.attributes.last_triggered)" -ForegroundColor Cyan
    Write-Host "Mode: $($state.attributes.mode)" -ForegroundColor White

    Write-Host "`n--- ATTRIBUTS COMPLETS ---" -ForegroundColor Yellow
    $state.attributes | ConvertTo-Json -Depth 10 | Write-Host

} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
}
