# Script pour tester la connectivite reseau des appareils Broadlink
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
Write-Host "TEST CONNECTIVITE BROADLINK" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Recuperer les IP des appareils Broadlink depuis les entites
$remotes = @("remote.clim_salon", "remote.clim_maeva", "remote.clim_axel")
$broadlinkDevices = @()

foreach ($remote in $remotes) {
    try {
        $state = Invoke-RestMethod -Uri "$HA_URL/api/states/$remote" -Headers $headers -Method Get

        $ip = $null
        if ($state.attributes.host) {
            $ip = $state.attributes.host
        } elseif ($state.attributes.friendly_name -match "192\.168\.\d+\.\d+") {
            $ip = $matches[0]
        }

        $device = @{
            entity = $remote
            name = $state.attributes.friendly_name
            state = $state.state
            ip = $ip
        }

        $broadlinkDevices += $device

        Write-Host "$remote" -ForegroundColor Yellow
        Write-Host "  Nom: $($device.name)" -ForegroundColor White
        Write-Host "  Etat: $($device.state)" -ForegroundColor $(if ($device.state -eq "on") { "Green" } else { "Red" })

        if ($ip) {
            Write-Host "  IP: $ip" -ForegroundColor Cyan

            # Test ping
            $pingResult = Test-Connection -ComputerName $ip -Count 2 -Quiet -ErrorAction SilentlyContinue
            if ($pingResult) {
                Write-Host "  Ping: OK" -ForegroundColor Green
            } else {
                Write-Host "  Ping: ECHEC - Appareil non accessible" -ForegroundColor Red
            }
        } else {
            Write-Host "  IP: Non trouvee dans les attributs" -ForegroundColor Gray
        }

        Write-Host ""
    } catch {
        Write-Host "$remote : ERREUR - $_" -ForegroundColor Red
    }
}

# Tenter de retrouver les IP depuis les logs ou la configuration
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RECHERCHE IP DANS CONFIGURATION HA" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# IP connues d'apres la documentation precedente
$knownIPs = @{
    "Broadlink Maeva" = "192.168.0.136"
    "Broadlink Salon" = "192.168.0.???"
    "Broadlink Axel" = "192.168.0.???"
}

foreach ($device in $knownIPs.GetEnumerator()) {
    Write-Host "$($device.Key): $($device.Value)" -ForegroundColor White

    if ($device.Value -notmatch "\?") {
        $pingResult = Test-Connection -ComputerName $device.Value -Count 2 -Quiet -ErrorAction SilentlyContinue
        if ($pingResult) {
            Write-Host "  Ping: OK" -ForegroundColor Green
        } else {
            Write-Host "  Ping: ECHEC" -ForegroundColor Red
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RECOMMANDATIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Verifier que les appareils Broadlink sont branches et allumes" -ForegroundColor Yellow
Write-Host "2. Si ping echoue: redemarrer l'appareil Broadlink physiquement" -ForegroundColor Yellow
Write-Host "3. Dans HA: Parametres -> Appareils et services -> Broadlink" -ForegroundColor Yellow
Write-Host "4. Tester une commande IR pour confirmer le bon fonctionnement" -ForegroundColor Yellow
