# Script pour analyser les détails complets des automations de chauffage
$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = $env:HA_TOKEN

if (-not $HA_TOKEN) {
    Write-Host "ERREUR: Variable d'environnement HA_TOKEN non définie" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $HA_TOKEN"
    "Content-Type" = "application/json"
}

# Charger les données exportées
$dataFile = "c:\DATAS\AI\Projets\Perso\Domotique\automation_data_export.json"
if (-not (Test-Path $dataFile)) {
    Write-Host "❌ Fichier $dataFile introuvable" -ForegroundColor Red
    Write-Host "Exécutez d'abord: .\collect_automation_data.ps1" -ForegroundColor Yellow
    exit 1
}

$data = Get-Content $dataFile -Raw | ConvertFrom-Json

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ANALYSE DÉTAILLÉE DES AUTOMATIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$detailedAutomations = @()

foreach ($auto in $data.automations_chauffage) {
    Write-Host "`n--- $($auto.entity_id) ---" -ForegroundColor Yellow
    Write-Host "Nom: $($auto.friendly_name)" -ForegroundColor White

    try {
        # Récupérer la configuration complète de l'automation
        $configUrl = "$HA_URL/api/config/automation/config/$($auto.entity_id)"
        $fullConfig = Invoke-RestMethod -Uri $configUrl -Headers $headers -Method Get -ErrorAction SilentlyContinue

        if ($fullConfig) {
            $autoDetail = @{
                entity_id = $auto.entity_id
                friendly_name = $auto.friendly_name
                state = $auto.state
                last_triggered = $auto.last_triggered
                alias = $fullConfig.alias
                triggers = $fullConfig.trigger
                conditions = $fullConfig.condition
                actions = $fullConfig.action
                mode = $fullConfig.mode
                description = $fullConfig.description
            }

            # Afficher les triggers
            Write-Host "`nTriggers:" -ForegroundColor Cyan
            if ($fullConfig.trigger) {
                foreach ($trigger in $fullConfig.trigger) {
                    if ($trigger.platform -eq "time") {
                        Write-Host "  - Time: $($trigger.at)" -ForegroundColor Green
                    } elseif ($trigger.platform -eq "state") {
                        Write-Host "  - State: $($trigger.entity_id) → $($trigger.to)" -ForegroundColor Green
                    } elseif ($trigger.platform -eq "time_pattern") {
                        Write-Host "  - Time Pattern: $($trigger.minutes)" -ForegroundColor Green
                    } else {
                        Write-Host "  - $($trigger.platform): $($trigger | ConvertTo-Json -Compress)" -ForegroundColor Green
                    }
                }
            } else {
                Write-Host "  (Aucun trigger)" -ForegroundColor Gray
            }

            # Afficher les conditions
            Write-Host "`nConditions:" -ForegroundColor Cyan
            if ($fullConfig.condition) {
                foreach ($condition in $fullConfig.condition) {
                    Write-Host "  - $($condition | ConvertTo-Json -Compress)" -ForegroundColor Magenta
                }
            } else {
                Write-Host "  (Aucune condition)" -ForegroundColor Gray
            }

            $detailedAutomations += $autoDetail
        } else {
            Write-Host "  ⚠ Configuration complète non accessible via API" -ForegroundColor Yellow
        }

    } catch {
        Write-Host "  ❌ Erreur: $_" -ForegroundColor Red
    }
}

# Exporter les données détaillées
$outputFile = "c:\DATAS\AI\Projets\Perso\Domotique\automation_details_export.json"
$detailedAutomations | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "`n✓ Détails exportés vers: $outputFile" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TIMELINE HORAIRE IDENTIFIÉE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Extraire les horaires
$timelineEvents = @()

foreach ($auto in $detailedAutomations) {
    if ($auto.triggers) {
        foreach ($trigger in $auto.triggers) {
            if ($trigger.platform -eq "time" -and $trigger.at) {
                $timelineEvents += @{
                    time = $trigger.at
                    automation = $auto.alias
                    entity_id = $auto.entity_id
                }
            }
        }
    }
}

$timelineEvents | Sort-Object time | ForEach-Object {
    Write-Host "$($_.time) - $($_.automation)" -ForegroundColor Cyan
}

if ($timelineEvents.Count -eq 0) {
    Write-Host "(Aucun déclencheur horaire détecté dans les automations)" -ForegroundColor Yellow
    Write-Host "Les automations utilisent probablement des triggers d'état ou des patterns" -ForegroundColor Yellow
}
