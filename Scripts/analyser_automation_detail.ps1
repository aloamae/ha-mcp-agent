# Analyser le détail d'une automation
param(
    [string]$AutomationId = "automation.chauffage_planning_automatique_horaire"
)

$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = $env:HA_TOKEN

$headers = @{
    "Authorization" = "Bearer $HA_TOKEN"
    "Content-Type" = "application/json"
}

Write-Host "=== DÉTAIL DE L'AUTOMATION ===" -ForegroundColor Cyan
Write-Host $AutomationId -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$HA_URL/api/states/$AutomationId" -Headers $headers -Method Get

    Write-Host "`nÉtat: $($response.state)" -ForegroundColor $(if ($response.state -eq "on") { "Green" } else { "Red" })
    Write-Host "Nom: $($response.attributes.friendly_name)"
    Write-Host "Dernier déclenchement: $($response.attributes.last_triggered)"
    Write-Host "Mode: $($response.attributes.mode)"

    if ($response.attributes.current) {
        Write-Host "`nÉtat actuel: $($response.attributes.current)"
    }

    Write-Host "`n--- ATTRIBUTS COMPLETS ---" -ForegroundColor Cyan
    $response.attributes | ConvertTo-Json -Depth 10 | Write-Host

} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
}
