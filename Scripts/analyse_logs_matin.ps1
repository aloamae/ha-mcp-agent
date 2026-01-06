# Script d'analyse des logs Home Assistant (5h-10h ce matin)
# Date: 2025-12-18

$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = $env:HA_TOKEN

if (-not $HA_TOKEN) {
    Write-Host "ERREUR: Variable HA_TOKEN non définie" -ForegroundColor Red
    Write-Host "Définissez-la avec: `$env:HA_TOKEN = 'VOTRE_TOKEN'" -ForegroundColor Yellow
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ANALYSE LOGS HOME ASSISTANT" -ForegroundColor Cyan
Write-Host "Période: 05:00 - 10:00 (ce matin)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Fonction pour appeler l'API HA
function Get-HAState {
    param($EntityId, $Time)

    $headers = @{
        "Authorization" = "Bearer $HA_TOKEN"
        "Content-Type" = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri "$HA_URL/api/states/$EntityId" -Headers $headers -Method Get
        return $response
    } catch {
        Write-Host "Erreur pour $EntityId : $_" -ForegroundColor Red
        return $null
    }
}

# Fonction pour obtenir l'historique
function Get-HAHistory {
    param($EntityId, $StartTime, $EndTime)

    $headers = @{
        "Authorization" = "Bearer $HA_TOKEN"
        "Content-Type" = "application/json"
    }

    $url = "$HA_URL/api/history/period/${StartTime}?filter_entity_id=$EntityId&end_time=$EndTime"

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        return $response
    } catch {
        Write-Host "Erreur historique pour $EntityId : $_" -ForegroundColor Red
        return $null
    }
}

# Date d'aujourd'hui
$today = Get-Date -Format "yyyy-MM-dd"
$startTime = "${today}T05:00:00"
$endTime = "${today}T10:00:00"

Write-Host "1. ÉTAT DU MODE VACANCES" -ForegroundColor Yellow
$modeVacance = Get-HAState -EntityId "input_boolean.mode_vacance"
if ($modeVacance) {
    Write-Host "  État actuel: $($modeVacance.state)" -ForegroundColor $(if ($modeVacance.state -eq "on") { "Red" } else { "Green" })
    Write-Host "  Dernière mise à jour: $($modeVacance.last_changed)"
}

Write-Host "`n2. ÉTAT DE LA CHAUDIÈRE (switch.thermostat)" -ForegroundColor Yellow
$thermostat = Get-HAState -EntityId "switch.thermostat"
if ($thermostat) {
    Write-Host "  État actuel: $($thermostat.state)" -ForegroundColor $(if ($thermostat.state -eq "on") { "Green" } else { "Red" })
    Write-Host "  Dernière mise à jour: $($thermostat.last_changed)"
}

Write-Host "`n3. HISTORIQUE CHAUDIÈRE (05:00 - 10:00)" -ForegroundColor Yellow
$history = Get-HAHistory -EntityId "switch.thermostat" -StartTime $startTime -EndTime $endTime
if ($history -and $history.Count -gt 0) {
    $changes = $history[0] | Where-Object { $_.state }
    foreach ($change in $changes) {
        $time = ([DateTime]$change.last_changed).ToString("HH:mm:ss")
        $state = $change.state
        $color = if ($state -eq "on") { "Green" } else { "Red" }
        Write-Host "  $time : $state" -ForegroundColor $color
    }
} else {
    Write-Host "  Aucun changement d'état détecté" -ForegroundColor Red
}

Write-Host "`n4. CAPTEURS DE TEMPÉRATURE (ce matin)" -ForegroundColor Yellow
$capteurs = @(
    "sensor.th_cuisine_temperature",
    "sensor.th_salon_temperature",
    "sensor.th_loann_temperature",
    "sensor.th_parents_temperature"
)

foreach ($capteur in $capteurs) {
    $state = Get-HAState -EntityId $capteur
    if ($state) {
        $color = if ($state.state -eq "unavailable") { "Red" } else { "Green" }
        Write-Host "  $capteur : $($state.state)°C" -ForegroundColor $color
    }
}

Write-Host "`n5. ÉTAT DES AUTOMATIONS DE CHAUFFAGE" -ForegroundColor Yellow
$automations = @(
    "automation.chauffage_planning_horaire",
    "automation.chauffage_allumage_matin",
    "automation.chauffage_gaz_control"
)

foreach ($auto in $automations) {
    $state = Get-HAState -EntityId $auto
    if ($state) {
        $enabled = if ($state.state -eq "on") { "ACTIVÉE" } else { "DÉSACTIVÉE" }
        $color = if ($state.state -eq "on") { "Green" } else { "Red" }
        Write-Host "  $auto : $enabled" -ForegroundColor $color

        if ($state.attributes.last_triggered) {
            Write-Host "    Dernier déclenchement: $($state.attributes.last_triggered)"
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Analyse terminée" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
