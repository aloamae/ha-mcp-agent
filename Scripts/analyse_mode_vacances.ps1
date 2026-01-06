# Script pour analyser l'activation du mode vacances
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
Write-Host "ANALYSE MODE VACANCES" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Etat actuel du mode vacances
Write-Host "1. ETAT ACTUEL" -ForegroundColor Yellow
try {
    $modeVacance = Invoke-RestMethod -Uri "$HA_URL/api/states/input_boolean.mode_vacance" -Headers $headers -Method Get

    $color = if ($modeVacance.state -eq "on") { "Red" } else { "Green" }
    Write-Host "  Etat: $($modeVacance.state)" -ForegroundColor $color
    Write-Host "  Derniere modification: $($modeVacance.last_changed)" -ForegroundColor White
    Write-Host "  Derniere mise a jour: $($modeVacance.last_updated)" -ForegroundColor White

} catch {
    Write-Host "  ERREUR: $_" -ForegroundColor Red
}

# 2. Historique du mode vacances (dernieres 24h)
Write-Host "`n2. HISTORIQUE (24 dernieres heures)" -ForegroundColor Yellow
try {
    $startTime = (Get-Date).AddHours(-24).ToString("yyyy-MM-ddTHH:mm:ss")
    $url = "$HA_URL/api/history/period/${startTime}?filter_entity_id=input_boolean.mode_vacance"

    $history = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

    if ($history -and $history.Count -gt 0) {
        $changes = $history[0] | Where-Object { $_.state }

        Write-Host "  Nombre de changements d'etat: $($changes.Count)" -ForegroundColor Cyan

        foreach ($change in $changes | Sort-Object last_changed) {
            $time = ([DateTime]$change.last_changed).ToString("yyyy-MM-dd HH:mm:ss")
            $stateColor = if ($change.state -eq "on") { "Red" } else { "Green" }
            Write-Host "  $time : $($change.state)" -ForegroundColor $stateColor
        }

        # Trouver la derniere activation (ON)
        $lastOn = $changes | Where-Object { $_.state -eq "on" } | Sort-Object last_changed -Descending | Select-Object -First 1

        if ($lastOn) {
            $activationTime = ([DateTime]$lastOn.last_changed).ToString("yyyy-MM-dd HH:mm:ss")
            Write-Host "`n  DERNIERE ACTIVATION: $activationTime" -ForegroundColor Red
        }
    } else {
        Write-Host "  Aucun changement dans les 24 dernieres heures" -ForegroundColor Gray
    }

} catch {
    Write-Host "  ERREUR historique: $_" -ForegroundColor Red
}

# 3. Rechercher les automations qui controlent le mode vacances
Write-Host "`n3. AUTOMATIONS GERANT LE MODE VACANCES" -ForegroundColor Yellow
try {
    $allStates = Invoke-RestMethod -Uri "$HA_URL/api/states" -Headers $headers -Method Get
    $automations = $allStates | Where-Object { $_.entity_id -like "automation.*" }

    # Chercher dans les noms
    $vacanceAutomations = $automations | Where-Object {
        $_.attributes.friendly_name -match "vacance|vacation" -or
        $_.entity_id -match "vacance|vacation"
    }

    if ($vacanceAutomations) {
        foreach ($auto in $vacanceAutomations) {
            Write-Host "`n  $($auto.entity_id)" -ForegroundColor Cyan
            Write-Host "    Nom: $($auto.attributes.friendly_name)" -ForegroundColor White
            Write-Host "    Etat: $($auto.state)" -ForegroundColor $(if ($auto.state -eq "on") { "Green" } else { "Red" })

            if ($auto.attributes.last_triggered) {
                Write-Host "    Dernier declenchement: $($auto.attributes.last_triggered)" -ForegroundColor Yellow
            } else {
                Write-Host "    Dernier declenchement: Jamais" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "  Aucune automation trouvee" -ForegroundColor Gray
    }

} catch {
    Write-Host "  ERREUR: $_" -ForegroundColor Red
}

# 4. Rechercher dans le logbook qui a modifie le mode vacances
Write-Host "`n4. LOGBOOK - QUI A ACTIVE LE MODE VACANCES?" -ForegroundColor Yellow
try {
    $startTime = (Get-Date).AddHours(-48).ToString("yyyy-MM-ddTHH:mm:ss")
    $url = "$HA_URL/api/logbook/${startTime}?entity=input_boolean.mode_vacance"

    $logbook = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction SilentlyContinue

    if ($logbook) {
        $events = $logbook | Where-Object {
            $_.entity_id -eq "input_boolean.mode_vacance" -or
            $_.message -match "mode.vacance"
        } | Sort-Object when -Descending | Select-Object -First 10

        foreach ($event in $events) {
            $time = ([DateTime]$event.when).ToString("yyyy-MM-dd HH:mm:ss")
            Write-Host "`n  [$time]" -ForegroundColor Cyan
            Write-Host "    Nom: $($event.name)" -ForegroundColor White
            Write-Host "    Message: $($event.message)" -ForegroundColor White

            if ($event.context_user_id) {
                Write-Host "    Utilisateur: $($event.context_user_id)" -ForegroundColor Yellow
            }

            if ($event.domain) {
                Write-Host "    Domaine: $($event.domain)" -ForegroundColor White
            }
        }
    } else {
        Write-Host "  Logbook non disponible ou vide" -ForegroundColor Gray
    }

} catch {
    Write-Host "  ERREUR logbook: $_" -ForegroundColor Yellow
    Write-Host "  (L'API logbook n'est peut-etre pas accessible)" -ForegroundColor Gray
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "FIN DE L'ANALYSE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
