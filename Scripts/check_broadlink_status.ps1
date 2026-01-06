# Script pour diagnostiquer les entités Broadlink et climatisations
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

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC BROADLINK & CLIMATISATIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Charger les données si disponibles
$dataFile = "c:\DATAS\AI\Projets\Perso\Domotique\automation_data_export.json"
$data = $null

if (Test-Path $dataFile) {
    $data = Get-Content $dataFile -Raw | ConvertFrom-Json
    Write-Host "✓ Données chargées depuis: $dataFile`n" -ForegroundColor Green
} else {
    Write-Host "⚠ Collecte des données en direct...`n" -ForegroundColor Yellow
    try {
        $allStates = Invoke-RestMethod -Uri "$HA_URL/api/states" -Headers $headers -Method Get
    } catch {
        Write-Host "❌ Impossible de se connecter à Home Assistant: $_" -ForegroundColor Red
        exit 1
    }
}

# Identifier les entités Broadlink spécifiques
$climSalon = @{
    remote = "remote.clim_salon"
    climate = "climate.climatisation_salon"
    expected_ip = "192.168.0.???"  # À compléter
}

$climMaeva = @{
    remote = "remote.clim_maeva"
    climate = "climate.climatisation_maeva"
    expected_ip = "192.168.0.136"
}

$climAxel = @{
    remote = "remote.clim_axel"
    climate = "climate.climatisation_axel"
    expected_ip = "192.168.0.???"  # À compléter
}

$climates = @($climSalon, $climMaeva, $climAxel)
$diagnosticResults = @()

foreach ($clim in $climates) {
    Write-Host "`n========== $($clim.remote) ==========" -ForegroundColor Cyan

    $diagnostic = @{
        remote_entity = $clim.remote
        climate_entity = $clim.climate
        expected_ip = $clim.expected_ip
        remote_state = $null
        climate_state = $null
        issues = @()
        recommendations = @()
    }

    # Vérifier l'entité remote
    try {
        $remoteState = Invoke-RestMethod -Uri "$HA_URL/api/states/$($clim.remote)" -Headers $headers -Method Get
        $diagnostic.remote_state = @{
            state = $remoteState.state
            friendly_name = $remoteState.attributes.friendly_name
            last_changed = $remoteState.last_changed
        }

        $stateColor = switch ($remoteState.state) {
            "on" { "Green" }
            "off" { "Yellow" }
            "unavailable" { "Red" }
            default { "Gray" }
        }

        Write-Host "Remote: " -NoNewline
        Write-Host $remoteState.state.ToUpper() -ForegroundColor $stateColor

        if ($remoteState.state -eq "off") {
            $diagnostic.issues += "Remote entity est OFF - les commandes IR sont bloquées"
            $diagnostic.recommendations += "Activer l'entité remote via Home Assistant UI ou service turn_on"
        } elseif ($remoteState.state -eq "unavailable") {
            $diagnostic.issues += "Remote entity UNAVAILABLE - appareil Broadlink non accessible"
            $diagnostic.recommendations += "Vérifier que l'appareil Broadlink ($($clim.expected_ip)) est allumé et connecté au réseau"
            $diagnostic.recommendations += "Redémarrer l'intégration Broadlink dans HA"
        }

    } catch {
        Write-Host "Remote: " -NoNewline
        Write-Host "ERREUR - Entité introuvable" -ForegroundColor Red
        $diagnostic.issues += "Entité remote introuvable dans Home Assistant"
        $diagnostic.recommendations += "Vérifier que l'intégration Broadlink est configurée"
    }

    # Vérifier l'entité climate
    try {
        $climateState = Invoke-RestMethod -Uri "$HA_URL/api/states/$($clim.climate)" -Headers $headers -Method Get
        $diagnostic.climate_state = @{
            state = $climateState.state
            friendly_name = $climateState.attributes.friendly_name
            current_temp = $climateState.attributes.current_temperature
            target_temp = $climateState.attributes.temperature
            hvac_action = $climateState.attributes.hvac_action
            hvac_mode = $climateState.state
        }

        Write-Host "Climate: $($climateState.state) " -NoNewline
        if ($climateState.attributes.current_temperature) {
            Write-Host "($($climateState.attributes.current_temperature)C -> $($climateState.attributes.temperature)C)" -ForegroundColor Cyan
        } else {
            Write-Host "(Pas de temperature)" -ForegroundColor Gray
        }

        # Vérifier la cohérence remote <-> climate
        if ($remoteState.state -eq "off" -and $climateState.state -ne "off") {
            $diagnostic.issues += "Incohérence: Climate=$($climateState.state) mais Remote=OFF"
            $diagnostic.recommendations += "La climatisation ne peut pas fonctionner si le remote est OFF"
        }

    } catch {
        Write-Host "Climate: " -NoNewline
        Write-Host "ERREUR - Entité introuvable" -ForegroundColor Red
        $diagnostic.issues += "Entité climate introuvable dans Home Assistant"
        $diagnostic.recommendations += "Vérifier que SmartIR est configuré pour cette climatisation"
    }

    # Résumé des problèmes
    if ($diagnostic.issues.Count -gt 0) {
        Write-Host "`nProblèmes identifiés:" -ForegroundColor Red
        foreach ($issue in $diagnostic.issues) {
            Write-Host "  ❌ $issue" -ForegroundColor Red
        }
    } else {
        Write-Host "`n✓ Aucun problème détecté" -ForegroundColor Green
    }

    # Recommandations
    if ($diagnostic.recommendations.Count -gt 0) {
        Write-Host "`nRecommandations:" -ForegroundColor Yellow
        foreach ($rec in $diagnostic.recommendations) {
            Write-Host "  → $rec" -ForegroundColor Yellow
        }
    }

    $diagnosticResults += $diagnostic
}

# Vérifier les logs récents (si API disponible)
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RÉCUPÉRATION DES LOGS (si disponibles)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

try {
    # Tentative de récupération du logbook
    $logbookUrl = "$HA_URL/api/logbook"
    $logs = Invoke-RestMethod -Uri $logbookUrl -Headers $headers -Method Get -ErrorAction SilentlyContinue

    $broadlinkLogs = $logs | Where-Object {
        $_.entity_id -match "clim|broadlink" -or
        $_.message -match "broadlink|clim"
    } | Select-Object -First 20

    if ($broadlinkLogs) {
        Write-Host "Derniers événements Broadlink/Clim:" -ForegroundColor Cyan
        foreach ($log in $broadlinkLogs) {
            Write-Host "  [$($log.when)] $($log.name): $($log.message)" -ForegroundColor White
        }
    } else {
        Write-Host "⚠ Aucun log Broadlink récent trouvé (ou API logbook non accessible)" -ForegroundColor Yellow
    }

} catch {
    Write-Host "⚠ Impossible de récupérer les logs via API" -ForegroundColor Yellow
    Write-Host "Consultez les logs dans: Paramètres → Système → Logs" -ForegroundColor Yellow
}

# Export du diagnostic
$outputFile = "c:\DATAS\AI\Projets\Perso\Domotique\broadlink_diagnostic_export.json"
$diagnosticResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "`n✓ Diagnostic exporté vers: $outputFile" -ForegroundColor Green

# Résumé global
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RÉSUMÉ DU DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$totalIssues = ($diagnosticResults | ForEach-Object { $_.issues.Count } | Measure-Object -Sum).Sum
Write-Host "Climatisations analysées : $($climates.Count)" -ForegroundColor White
Write-Host "Problèmes détectés       : $totalIssues" -ForegroundColor $(if ($totalIssues -gt 0) { "Red" } else { "Green" })

Write-Host "`nActions recommandées:" -ForegroundColor Yellow
Write-Host "  1. Activer les entités remote qui sont OFF" -ForegroundColor White
Write-Host "  2. Vérifier la connectivité réseau des appareils Broadlink" -ForegroundColor White
Write-Host "  3. Consulter les logs détaillés dans Home Assistant" -ForegroundColor White
Write-Host "  4. Redémarrer l'intégration Broadlink si nécessaire" -ForegroundColor White
