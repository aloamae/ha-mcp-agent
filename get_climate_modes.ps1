# Script pour recuperer tous les modes disponibles des climatisations
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
Write-Host "MODES DISPONIBLES - CLIMATISATIONS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$climates = @(
    "climate.climatisation_salon",
    "climate.climatisation_maeva",
    "climate.climatisation_axel"
)

foreach ($climate in $climates) {
    Write-Host "=== $climate ===" -ForegroundColor Yellow

    try {
        $state = Invoke-RestMethod -Uri "$HA_URL/api/states/$climate" -Headers $headers -Method Get

        Write-Host "`nEtat actuel: $($state.state)" -ForegroundColor White

        # HVAC Modes
        if ($state.attributes.hvac_modes) {
            Write-Host "`nHVAC MODES (modes de fonctionnement):" -ForegroundColor Cyan
            foreach ($mode in $state.attributes.hvac_modes) {
                $indicator = if ($state.state -eq $mode) { " <- ACTUEL" } else { "" }
                Write-Host "  - $mode$indicator" -ForegroundColor Green
            }
        }

        # Fan Modes
        if ($state.attributes.fan_modes) {
            Write-Host "`nFAN MODES (vitesses ventilateur):" -ForegroundColor Cyan
            foreach ($fanMode in $state.attributes.fan_modes) {
                $indicator = if ($state.attributes.fan_mode -eq $fanMode) { " <- ACTUEL" } else { "" }
                Write-Host "  - $fanMode$indicator" -ForegroundColor Green
            }
        }

        # Swing Modes
        if ($state.attributes.swing_modes) {
            Write-Host "`nSWING MODES (oscillation):" -ForegroundColor Cyan
            foreach ($swingMode in $state.attributes.swing_modes) {
                $indicator = if ($state.attributes.swing_mode -eq $swingMode) { " <- ACTUEL" } else { "" }
                Write-Host "  - $swingMode$indicator" -ForegroundColor Green
            }
        }

        # Preset Modes
        if ($state.attributes.preset_modes) {
            Write-Host "`nPRESET MODES (presets):" -ForegroundColor Cyan
            foreach ($presetMode in $state.attributes.preset_modes) {
                $indicator = if ($state.attributes.preset_mode -eq $presetMode) { " <- ACTUEL" } else { "" }
                Write-Host "  - $presetMode$indicator" -ForegroundColor Green
            }
        }

        # Temperatures
        Write-Host "`nTEMPERATURES:" -ForegroundColor Cyan
        Write-Host "  Actuelle: $($state.attributes.current_temperature)C" -ForegroundColor White
        Write-Host "  Cible: $($state.attributes.temperature)C" -ForegroundColor White
        Write-Host "  Min: $($state.attributes.min_temp)C" -ForegroundColor White
        Write-Host "  Max: $($state.attributes.max_temp)C" -ForegroundColor White

        # Features supportees
        if ($state.attributes.supported_features) {
            Write-Host "`nFEATURES SUPPORTEES (code binaire):" -ForegroundColor Cyan
            Write-Host "  Code: $($state.attributes.supported_features)" -ForegroundColor White

            # Decode features
            $features = $state.attributes.supported_features
            Write-Host "  Signification:" -ForegroundColor Gray
            if ($features -band 1) { Write-Host "    - Target temperature" -ForegroundColor Gray }
            if ($features -band 2) { Write-Host "    - Target temperature range" -ForegroundColor Gray }
            if ($features -band 4) { Write-Host "    - Target humidity" -ForegroundColor Gray }
            if ($features -band 8) { Write-Host "    - Fan mode" -ForegroundColor Gray }
            if ($features -band 16) { Write-Host "    - Preset mode" -ForegroundColor Gray }
            if ($features -band 32) { Write-Host "    - Swing mode" -ForegroundColor Gray }
            if ($features -band 64) { Write-Host "    - Aux heat" -ForegroundColor Gray }
        }

        Write-Host "`n" -NoNewline

    } catch {
        Write-Host "ERREUR: $_`n" -ForegroundColor Red
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CODE YAML POUR LOVELACE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "# EXEMPLE CARTE COMPLETE CLIMATISATION" -ForegroundColor Yellow
Write-Host @"
type: tile
entity: climate.climatisation_axel
features:
  - type: climate-hvac-modes
    hvac_modes:
      - off
      - heat
      - cool
      - heat_cool
      - dry
      - fan_only
    style: icons  # ou 'dropdown'
  - type: climate-fan-modes
    style: dropdown  # ou 'icons'
  - type: climate-preset-modes
    style: dropdown
  - type: climate-swing-modes
    style: dropdown

---

# EXEMPLE AVEC TOUS LES MODES DISPONIBLES
type: tile
entity: climate.climatisation_axel
name: Climatisation Axel
features:
  - type: climate-hvac-modes
    hvac_modes:
"@ -ForegroundColor White

# Recuperer les modes reels pour Axel
try {
    $axel = Invoke-RestMethod -Uri "$HA_URL/api/states/climate.climatisation_axel" -Headers $headers -Method Get

    foreach ($mode in $axel.attributes.hvac_modes) {
        Write-Host "      - $mode" -ForegroundColor Green
    }

    Write-Host "    style: icons  # ou 'dropdown'" -ForegroundColor White
    Write-Host "  - type: climate-fan-modes" -ForegroundColor White

    if ($axel.attributes.fan_modes) {
        Write-Host "    fan_modes:" -ForegroundColor White
        foreach ($fanMode in $axel.attributes.fan_modes) {
            Write-Host "      - $fanMode" -ForegroundColor Green
        }
    }

    Write-Host "    style: dropdown" -ForegroundColor White

} catch {
    Write-Host "# (Impossible de recuperer les modes automatiquement)" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
