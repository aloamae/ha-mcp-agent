# Script pour analyser tous les modes de chauffage et leurs priorites
$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = $env:HA_TOKEN

if (-not $HA_TOKEN) {
    Write-Host "⚠️ Variable HA_TOKEN non definie - Utilisation du token par defaut" -ForegroundColor Yellow
    $HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"
}

$headers = @{
    "Authorization" = "Bearer $HA_TOKEN"
    "Content-Type" = "application/json"
}

# Test de connexion
Write-Host "Test de connexion a Home Assistant..." -ForegroundColor Cyan
try {
    $null = Invoke-RestMethod -Uri "$HA_URL/api/" -Headers $headers -Method Get -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✅ Connexion reussie`n" -ForegroundColor Green
} catch {
    Write-Host "❌ ERREUR DE CONNEXION: $_" -ForegroundColor Red
    Write-Host "`nVerifier:" -ForegroundColor Yellow
    Write-Host "  1. Home Assistant est accessible sur $HA_URL" -ForegroundColor White
    Write-Host "  2. Le token est valide" -ForegroundColor White
    Write-Host "  3. Pas de firewall bloquant" -ForegroundColor White
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ANALYSE DES MODES DE CHAUFFAGE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

try {
    $allStates = Invoke-RestMethod -Uri "$HA_URL/api/states" -Headers $headers -Method Get

    # Mode Vacances
    Write-Host "=== MODE VACANCES ===" -ForegroundColor Yellow
    $modeVacance = $allStates | Where-Object { $_.entity_id -eq "input_boolean.mode_vacance" }
    if ($modeVacance) {
        $color = if ($modeVacance.state -eq "on") { "Red" } else { "Green" }
        Write-Host "  input_boolean.mode_vacance : $($modeVacance.state)" -ForegroundColor $color
    }

    # Mode Nuit
    Write-Host "`n=== MODE NUIT ===" -ForegroundColor Yellow
    $modeNuit = $allStates | Where-Object { $_.entity_id -eq "input_boolean.mode_nuit" }
    if ($modeNuit) {
        Write-Host "  input_boolean.mode_nuit : $($modeNuit.state)" -ForegroundColor White
    }

    # Mode Presence
    Write-Host "`n=== MODE PRESENCE ===" -ForegroundColor Yellow
    $presence = $allStates | Where-Object { $_.entity_id -like "*presence*" -or $_.entity_id -like "zone.home" }
    foreach ($p in $presence | Select-Object -First 5) {
        Write-Host "  $($p.entity_id) : $($p.state)" -ForegroundColor White
    }

    # Mode Global
    Write-Host "`n=== MODE CHAUFFAGE GLOBAL ===" -ForegroundColor Yellow
    $modeGlobal = $allStates | Where-Object { $_.entity_id -eq "sensor.mode_chauffage_global" }
    if ($modeGlobal) {
        Write-Host "  sensor.mode_chauffage_global : $($modeGlobal.state)" -ForegroundColor Cyan
    }

    $inputModeGlobal = $allStates | Where-Object { $_.entity_id -like "input_select.mode_chauffage_global" }
    if ($inputModeGlobal) {
        Write-Host "  input_select.mode_chauffage_global : $($inputModeGlobal.state)" -ForegroundColor Cyan
    }

    # Modes Manuels par piece
    Write-Host "`n=== MODES MANUELS PAR PIECE ===" -ForegroundColor Yellow
    $modesPieces = $allStates | Where-Object {
        $_.entity_id -like "input_select.mode_chauffage_*" -and
        $_.entity_id -notlike "*global*"
    }

    foreach ($mode in $modesPieces) {
        $pieceName = $mode.entity_id -replace "input_select.mode_chauffage_", ""
        Write-Host "  $pieceName : $($mode.state)" -ForegroundColor White
    }

    # Temperatures de consigne
    Write-Host "`n=== TEMPERATURES DE CONSIGNE ===" -ForegroundColor Yellow
    $climates = $allStates | Where-Object { $_.entity_id -like "climate.*" }
    foreach ($climate in $climates) {
        if ($climate.attributes.temperature) {
            Write-Host "  $($climate.entity_id)" -ForegroundColor Cyan
            Write-Host "    Consigne: $($climate.attributes.temperature)C" -ForegroundColor White
            Write-Host "    Actuelle: $($climate.attributes.current_temperature)C" -ForegroundColor White
        }
    }

    # Capteurs de temperature
    Write-Host "`n=== CAPTEURS TEMPERATURE ===" -ForegroundColor Yellow
    $tempSensors = $allStates | Where-Object { $_.entity_id -like "sensor.th_*_temperature" }
    foreach ($sensor in $tempSensors) {
        Write-Host "  $($sensor.entity_id) : $($sensor.state)C" -ForegroundColor White
    }

    # Automations chauffage actives
    Write-Host "`n=== AUTOMATIONS CHAUFFAGE ACTIVES ===" -ForegroundColor Yellow
    $automations = $allStates | Where-Object {
        $_.entity_id -like "automation.*chauff*" -and
        $_.state -eq "on"
    }

    foreach ($auto in $automations) {
        Write-Host "  $($auto.attributes.friendly_name)" -ForegroundColor Green
        if ($auto.attributes.last_triggered) {
            Write-Host "    Dernier: $($auto.attributes.last_triggered)" -ForegroundColor Gray
        }
    }

} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
