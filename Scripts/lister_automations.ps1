# Script pour lister TOUTES les automations Home Assistant
$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = $env:HA_TOKEN

$headers = @{
    "Authorization" = "Bearer $HA_TOKEN"
    "Content-Type" = "application/json"
}

Write-Host "=== TOUTES LES AUTOMATIONS HOME ASSISTANT ===" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "$HA_URL/api/states" -Headers $headers -Method Get
    $automations = $response | Where-Object { $_.entity_id -like "automation.*chauff*" }

    if ($automations.Count -eq 0) {
        Write-Host "Aucune automation de chauffage trouvée. Listing de TOUTES les automations:" -ForegroundColor Yellow
        $automations = $response | Where-Object { $_.entity_id -like "automation.*" }
    }

    foreach ($auto in $automations) {
        $enabled = if ($auto.state -eq "on") { "ACTIVÉE" } else { "DÉSACTIVÉE" }
        $color = if ($auto.state -eq "on") { "Green" } else { "Red" }

        Write-Host "`n$($auto.entity_id)" -ForegroundColor $color
        Write-Host "  État: $enabled" -ForegroundColor $color
        Write-Host "  Nom: $($auto.attributes.friendly_name)"

        if ($auto.attributes.last_triggered) {
            Write-Host "  Dernier déclenchement: $($auto.attributes.last_triggered)"
        } else {
            Write-Host "  Dernier déclenchement: Jamais" -ForegroundColor Gray
        }
    }

    Write-Host "`n=== TOTAL: $($automations.Count) automation(s) ===" -ForegroundColor Cyan

} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
}
