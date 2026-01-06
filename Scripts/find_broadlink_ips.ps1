# Script pour trouver les IP des appareils Broadlink
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

Write-Host "Recherche des appareils Broadlink..." -ForegroundColor Cyan

try {
    # Recuperer la liste de tous les appareils
    $config = Invoke-RestMethod -Uri "$HA_URL/api/config" -Headers $headers -Method Get
    Write-Host "Config recuperee`n" -ForegroundColor Green

    # Essayer de recuperer les entites et leurs attributs
    $allStates = Invoke-RestMethod -Uri "$HA_URL/api/states" -Headers $headers -Method Get

    # Filtrer les entites Broadlink
    $broadlinkEntities = $allStates | Where-Object {
        $_.entity_id -match "broadlink|clim_salon|clim_maeva|clim_axel"
    }

    Write-Host "Entites Broadlink trouvees:" -ForegroundColor Yellow
    foreach ($entity in $broadlinkEntities) {
        Write-Host "`n$($entity.entity_id)" -ForegroundColor Cyan
        Write-Host "  Nom: $($entity.attributes.friendly_name)" -ForegroundColor White
        Write-Host "  Etat: $($entity.state)" -ForegroundColor White

        # Afficher tous les attributs pour trouver l'IP
        $entity.attributes.PSObject.Properties | ForEach-Object {
            if ($_.Value -match "192\.168\.\d+\.\d+") {
                Write-Host "  $($_.Name): $($_.Value)" -ForegroundColor Green
            }
        }
    }

} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
}
