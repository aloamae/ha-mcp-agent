# Script pour trouver le service de notification iPhone
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

Write-Host "Recherche des services de notification iPhone..." -ForegroundColor Cyan

try {
    # Recuperer tous les services
    $services = Invoke-RestMethod -Uri "$HA_URL/api/services" -Headers $headers -Method Get

    # Filtrer les services notify
    $notifyServices = $services | Where-Object { $_.domain -eq "notify" }

    Write-Host "`nServices notify disponibles:" -ForegroundColor Yellow
    foreach ($service in $notifyServices.services) {
        $serviceName = $service.PSObject.Properties.Name
        Write-Host "  - notify.$serviceName" -ForegroundColor Green
    }

    # Filtrer les services mobile_app
    Write-Host "`nServices mobile_app (iPhone/Android):" -ForegroundColor Yellow
    $mobileServices = $notifyServices.services.PSObject.Properties.Name | Where-Object { $_ -like "*mobile*" -or $_ -like "*iphone*" -or $_ -like "*fredo*" }

    if ($mobileServices) {
        foreach ($service in $mobileServices) {
            Write-Host "  - notify.$service" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  Aucun service mobile trouve" -ForegroundColor Red
    }

    # Lister tous les appareils mobile_app
    Write-Host "`nAppareils mobile_app enregistres:" -ForegroundColor Yellow
    $allStates = Invoke-RestMethod -Uri "$HA_URL/api/states" -Headers $headers -Method Get
    $mobileDevices = $allStates | Where-Object { $_.entity_id -like "sensor.*battery_level" -or $_.entity_id -like "device_tracker.*" }

    $uniqueDevices = @()
    foreach ($device in $mobileDevices) {
        if ($device.attributes.friendly_name -match "iPhone|iOS|mobile") {
            $deviceInfo = "$($device.entity_id) - $($device.attributes.friendly_name)"
            if ($uniqueDevices -notcontains $deviceInfo) {
                $uniqueDevices += $deviceInfo
                Write-Host "  - $deviceInfo" -ForegroundColor White
            }
        }
    }

} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
}

Write-Host "`nPour tester un service:" -ForegroundColor Cyan
Write-Host 'Invoke-RestMethod -Uri "$HA_URL/api/services/notify/XXXXX" -Headers $headers -Method Post -Body ''{"message":"test"}''' -ForegroundColor Gray
