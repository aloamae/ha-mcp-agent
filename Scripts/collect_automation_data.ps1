# Script complet pour collecter toutes les données des automations de chauffage et entités Broadlink
# URL de Home Assistant
$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = $env:HA_TOKEN

if (-not $HA_TOKEN) {
    Write-Host "ERREUR: Variable d'environnement HA_TOKEN non définie" -ForegroundColor Red
    Write-Host "Définissez-la avec: `$env:HA_TOKEN = 'votre_token'" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $HA_TOKEN"
    "Content-Type" = "application/json"
}

$outputFile = "c:\DATAS\AI\Projets\Perso\Domotique\automation_data_export.json"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "COLLECTE DES DONNÉES HOME ASSISTANT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$allData = @{
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    automations_chauffage = @()
    automations_all = @()
    entities_broadlink = @()
    entities_climate = @()
    helpers = @()
    errors = @()
}

try {
    Write-Host "`n[1/5] Récupération de toutes les entités..." -ForegroundColor Yellow
    $allStates = Invoke-RestMethod -Uri "$HA_URL/api/states" -Headers $headers -Method Get
    Write-Host "  ✓ $($allStates.Count) entités récupérées" -ForegroundColor Green

    # ========== AUTOMATIONS ==========
    Write-Host "`n[2/5] Extraction des automations de chauffage..." -ForegroundColor Yellow
    $automations = $allStates | Where-Object { $_.entity_id -like "automation.*" }

    foreach ($auto in $automations) {
        $autoData = @{
            entity_id = $auto.entity_id
            friendly_name = $auto.attributes.friendly_name
            state = $auto.state
            last_triggered = $auto.attributes.last_triggered
            mode = $auto.attributes.mode
            current = $auto.attributes.current
            last_changed = $auto.last_changed
            last_updated = $auto.last_updated
        }

        $allData.automations_all += $autoData

        # Filtrer les automations de chauffage
        if ($auto.entity_id -match "chauff" -or $auto.attributes.friendly_name -match "chauff|climat|temperature") {
            $allData.automations_chauffage += $autoData
            Write-Host "    ✓ $($auto.entity_id) [$($auto.state)]" -ForegroundColor $(if ($auto.state -eq "on") { "Green" } else { "Gray" })
        }
    }
    Write-Host "  ✓ $($allData.automations_chauffage.Count) automations de chauffage identifiées" -ForegroundColor Green

    # ========== BROADLINK ==========
    Write-Host "`n[3/5] Extraction des entités Broadlink..." -ForegroundColor Yellow
    $broadlinkEntities = $allStates | Where-Object {
        $_.entity_id -match "broadlink|clim|remote\.clim"
    }

    foreach ($entity in $broadlinkEntities) {
        $entityData = @{
            entity_id = $entity.entity_id
            friendly_name = $entity.attributes.friendly_name
            state = $entity.state
            domain = $entity.entity_id.Split('.')[0]
            last_changed = $entity.last_changed
            last_updated = $entity.last_updated
            attributes = $entity.attributes
        }
        $allData.entities_broadlink += $entityData

        $statusColor = switch ($entity.state) {
            "on" { "Green" }
            "off" { "Yellow" }
            "unavailable" { "Red" }
            default { "Gray" }
        }
        Write-Host "    ✓ $($entity.entity_id) [$($entity.state)]" -ForegroundColor $statusColor
    }
    Write-Host "  ✓ $($allData.entities_broadlink.Count) entités Broadlink trouvées" -ForegroundColor Green

    # ========== CLIMATE ==========
    Write-Host "`n[4/5] Extraction des entités climate..." -ForegroundColor Yellow
    $climateEntities = $allStates | Where-Object { $_.entity_id -like "climate.*" }

    foreach ($climate in $climateEntities) {
        $climateData = @{
            entity_id = $climate.entity_id
            friendly_name = $climate.attributes.friendly_name
            state = $climate.state
            current_temperature = $climate.attributes.current_temperature
            target_temperature = $climate.attributes.temperature
            hvac_action = $climate.attributes.hvac_action
            hvac_modes = $climate.attributes.hvac_modes
            preset_mode = $climate.attributes.preset_mode
            last_changed = $climate.last_changed
            last_updated = $climate.last_updated
        }
        $allData.entities_climate += $climateData
        Write-Host "    ✓ $($climate.entity_id) [$($climate.state)] - Temp: $($climate.attributes.current_temperature)°C → $($climate.attributes.temperature)°C" -ForegroundColor Cyan
    }
    Write-Host "  ✓ $($allData.entities_climate.Count) entités climate trouvées" -ForegroundColor Green

    # ========== HELPERS ==========
    Write-Host "`n[5/5] Extraction des helpers..." -ForegroundColor Yellow
    $helpers = $allStates | Where-Object {
        $_.entity_id -match "^input_(boolean|number|select|text|datetime)\."
    }

    foreach ($helper in $helpers) {
        $helperData = @{
            entity_id = $helper.entity_id
            friendly_name = $helper.attributes.friendly_name
            state = $helper.state
            domain = $helper.entity_id.Split('.')[0]
        }
        $allData.helpers += $helperData
    }
    Write-Host "  ✓ $($allData.helpers.Count) helpers trouvés" -ForegroundColor Green

} catch {
    $errorMsg = "Erreur lors de la récupération des données: $_"
    Write-Host "`n❌ $errorMsg" -ForegroundColor Red
    $allData.errors += $errorMsg
}

# ========== EXPORT JSON ==========
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "EXPORT DES DONNÉES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

try {
    $jsonOutput = $allData | ConvertTo-Json -Depth 10
    $jsonOutput | Out-File -FilePath $outputFile -Encoding UTF8
    Write-Host "✓ Données exportées vers: $outputFile" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de l'export: $_" -ForegroundColor Red
}

# ========== RÉSUMÉ ==========
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RÉSUMÉ" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Automations de chauffage : $($allData.automations_chauffage.Count)" -ForegroundColor White
Write-Host "Entités Broadlink        : $($allData.entities_broadlink.Count)" -ForegroundColor White
Write-Host "Entités Climate          : $($allData.entities_climate.Count)" -ForegroundColor White
Write-Host "Helpers                  : $($allData.helpers.Count)" -ForegroundColor White
Write-Host "Erreurs                  : $($allData.errors.Count)" -ForegroundColor $(if ($allData.errors.Count -gt 0) { "Red" } else { "Green" })
Write-Host "`nFichier exporté: $outputFile" -ForegroundColor Cyan
Write-Host "`nProchaines étapes:" -ForegroundColor Yellow
Write-Host "  1. Exécutez: .\analyze_automation_details.ps1" -ForegroundColor White
Write-Host "  2. Vérifiez les logs Broadlink: .\check_broadlink_status.ps1" -ForegroundColor White
