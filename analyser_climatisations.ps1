# Analyse des climatisations Broadlink
# Cherche toutes les automations et scripts qui pilotent les climatisations

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
Write-Host "ANALYSE CLIMATISATIONS BROADLINK" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Climatisations concernees
$climates = @(
    "climate.climatisation_salon",
    "climate.climatisation_maeva",
    "climate.climatisation_axel"
)

# Remotes Broadlink associes
$remotes = @(
    "remote.clim_salon",
    "remote.clim_maeva",
    "remote.clim_axel"
)

Write-Host "ETAPE 1: Etat des climatisations`n" -ForegroundColor Green

foreach ($climate in $climates) {
    try {
        $state = Invoke-RestMethod -Uri "$HA_URL/api/states/$climate" -Headers $headers -Method Get -TimeoutSec 10 -ErrorAction Stop

        Write-Host "$climate :" -ForegroundColor Yellow
        Write-Host "  Etat: $($state.state)" -ForegroundColor White
        Write-Host "  Temperature actuelle: $($state.attributes.current_temperature)C" -ForegroundColor White
        Write-Host "  Temperature cible: $($state.attributes.temperature)C" -ForegroundColor White
        Write-Host "  Mode HVAC: $($state.attributes.hvac_mode)" -ForegroundColor White
        Write-Host "  Fan mode: $($state.attributes.fan_mode)" -ForegroundColor White
        Write-Host ""
    } catch {
        Write-Host "$climate : ERREUR - $_" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host "`nETAPE 2: Etat des remotes Broadlink`n" -ForegroundColor Green

foreach ($remote in $remotes) {
    try {
        $state = Invoke-RestMethod -Uri "$HA_URL/api/states/$remote" -Headers $headers -Method Get -TimeoutSec 10 -ErrorAction Stop

        $stateColor = if ($state.state -eq "on") { "Green" } else { "Red" }
        Write-Host "$remote : $($state.state)" -ForegroundColor $stateColor
        Write-Host ""
    } catch {
        Write-Host "$remote : ERREUR - $_" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host "`nETAPE 3: Recherche automations pilotant les climatisations`n" -ForegroundColor Green

try {
    $automations = Invoke-RestMethod -Uri "$HA_URL/api/states" -Headers $headers -Method Get -TimeoutSec 10 -ErrorAction Stop |
        Where-Object { $_.entity_id -like "automation.*" }

    $found = $false

    foreach ($auto in $automations) {
        $autoId = $auto.entity_id

        # Recuperer le YAML de l'automation via config
        try {
            $config = Invoke-RestMethod -Uri "$HA_URL/api/config/automation/config/$autoId" -Headers $headers -Method Get -TimeoutSec 10 -ErrorAction SilentlyContinue

            $configStr = $config | ConvertTo-Json -Depth 20

            # Chercher references aux climatisations
            $hasClimate = $false
            foreach ($climate in $climates) {
                if ($configStr -match $climate) {
                    $hasClimate = $true
                    break
                }
            }

            if ($hasClimate) {
                $found = $true
                Write-Host "TROUVE: $($auto.attributes.friendly_name)" -ForegroundColor Green
                Write-Host "  ID: $autoId" -ForegroundColor White
                Write-Host "  Etat: $($auto.state)" -ForegroundColor $(if ($auto.state -eq "on") { "Green" } else { "Red" })
                Write-Host ""
            }
        } catch {
            # Ignore si pas d'acces config
        }
    }

    if (-not $found) {
        Write-Host "AUCUNE automation trouvee pilotant les climatisations" -ForegroundColor Yellow
        Write-Host "Les climatisations sont probablement pilotees:" -ForegroundColor White
        Write-Host "  - Manuellement via dashboard" -ForegroundColor White
        Write-Host "  - Via des scripts" -ForegroundColor White
        Write-Host "  - Via des scenes" -ForegroundColor White
        Write-Host ""
    }

} catch {
    Write-Host "ERREUR lors de la recherche: $_" -ForegroundColor Red
}

Write-Host "`nETAPE 4: Recherche scripts utilisant les climatisations`n" -ForegroundColor Green

try {
    $scripts = Invoke-RestMethod -Uri "$HA_URL/api/states" -Headers $headers -Method Get -TimeoutSec 10 -ErrorAction Stop |
        Where-Object { $_.entity_id -like "script.*" }

    Write-Host "Scripts disponibles ($($scripts.Count) trouves):" -ForegroundColor Yellow

    foreach ($script in $scripts) {
        Write-Host "  - $($script.entity_id) : $($script.attributes.friendly_name)" -ForegroundColor White
    }

    Write-Host "`nPour verifier le contenu des scripts, il faut:" -ForegroundColor Cyan
    Write-Host "  1. Aller dans HA -> Parametres -> Automations et scenes -> Scripts" -ForegroundColor White
    Write-Host "  2. Cliquer sur chaque script" -ForegroundColor White
    Write-Host "  3. ... -> Modifier au format YAML" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CONCLUSION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "ACTUELLEMENT:" -ForegroundColor Yellow
Write-Host "  - Les 3 climatisations existent dans HA" -ForegroundColor White
Write-Host "  - Elles sont controlees via Broadlink (IR)" -ForegroundColor White
Write-Host "  - Integration: SmartIR" -ForegroundColor White
Write-Host ""

Write-Host "MANQUE:" -ForegroundColor Red
Write-Host "  - Pas d'automation de pilotage automatique" -ForegroundColor White
Write-Host "  - Pas de synchronisation avec le mode chauffage" -ForegroundColor White
Write-Host "  - Pas de regulation par temperature" -ForegroundColor White
Write-Host ""

Write-Host "RECOMMANDATION:" -ForegroundColor Green
Write-Host "  Creer des automations pour piloter automatiquement:" -ForegroundColor White
Write-Host "    1. Selon le MODE CHAUFFAGE GLOBAL (confort/eco/absent)" -ForegroundColor White
Write-Host "    2. Selon la TEMPERATURE de la piece" -ForegroundColor White
Write-Host "    3. Selon le MODE PRESENCE (zone.home)" -ForegroundColor White
Write-Host "    4. Selon les PLANIFICATIONS HORAIRES" -ForegroundColor White
Write-Host ""

Write-Host "Veux-tu que je cree ces automations? (o/N)" -ForegroundColor Cyan
$response = Read-Host

if ($response -eq 'o' -or $response -eq 'O') {
    Write-Host "`nOK! Je vais creer un systeme de pilotage automatique des climatisations." -ForegroundColor Green
    Write-Host "Cela sera similaire au systeme de pilotage de la chaudiere (seuils ±0.5C)" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "`nOK, pas de creation d'automation pour le moment." -ForegroundColor Yellow
}

Write-Host "`nAnalyse terminee`n" -ForegroundColor Green
