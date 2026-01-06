# Script diagnostic Broadlink simplifie
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
Write-Host "DIAGNOSTIC BROADLINK & CLIMATISATIONS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Liste des entites a verifier
$remotes = @("remote.clim_salon", "remote.clim_maeva", "remote.clim_axel")
$climates = @("climate.climatisation_salon", "climate.climatisation_maeva", "climate.climatisation_axel")

# Verifier les remotes
Write-Host "=== ENTITES REMOTE ===" -ForegroundColor Yellow
foreach ($remote in $remotes) {
    try {
        $state = Invoke-RestMethod -Uri "$HA_URL/api/states/$remote" -Headers $headers -Method Get
        $color = switch ($state.state) {
            "on" { "Green" }
            "off" { "Yellow" }
            "unavailable" { "Red" }
            default { "Gray" }
        }
        Write-Host "$remote : $($state.state)" -ForegroundColor $color

        if ($state.state -eq "off") {
            Write-Host "  -> PROBLEME: Remote est OFF - commandes IR bloquees" -ForegroundColor Red
        } elseif ($state.state -eq "unavailable") {
            Write-Host "  -> PROBLEME: Appareil Broadlink non accessible sur le reseau" -ForegroundColor Red
        }
    } catch {
        Write-Host "$remote : ERREUR - $_" -ForegroundColor Red
    }
}

# Verifier les climates
Write-Host "`n=== ENTITES CLIMATE ===" -ForegroundColor Yellow
foreach ($climate in $climates) {
    try {
        $state = Invoke-RestMethod -Uri "$HA_URL/api/states/$climate" -Headers $headers -Method Get
        Write-Host "$climate : $($state.state)" -ForegroundColor Cyan

        if ($state.attributes.current_temperature) {
            Write-Host "  Temperature actuelle: $($state.attributes.current_temperature)C" -ForegroundColor White
            Write-Host "  Temperature cible: $($state.attributes.temperature)C" -ForegroundColor White
        }

        if ($state.attributes.hvac_action) {
            Write-Host "  Action HVAC: $($state.attributes.hvac_action)" -ForegroundColor White
        }
    } catch {
        Write-Host "$climate : ERREUR - $_" -ForegroundColor Red
    }
}

# Recommandations
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RECOMMANDATIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Activer les entites remote qui sont OFF:" -ForegroundColor Yellow
Write-Host "   Home Assistant -> Outils de developpement -> Services" -ForegroundColor White
Write-Host "   Service: homeassistant.turn_on" -ForegroundColor White
Write-Host "   Entity: remote.clim_salon (ou maeva, ou axel)" -ForegroundColor White
Write-Host "`n2. Pour les remotes unavailable:" -ForegroundColor Yellow
Write-Host "   Verifier connectivite reseau des appareils Broadlink" -ForegroundColor White
Write-Host "   Redemarrer integration Broadlink dans HA si necessaire" -ForegroundColor White
