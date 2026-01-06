# =====================================
# SCRIPT NETTOYAGE AUTOMATIONS DOUBLONS
# Date: 22 décembre 2025
# =====================================

$ErrorActionPreference = "Stop"

Write-Host "`n===================================" -ForegroundColor Cyan
Write-Host "NETTOYAGE AUTOMATIONS DOUBLONS" -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Cyan

# Chemin du fichier automations.yaml
$automationsFile = "C:\Users\fcartier\AppData\Local\Temp\scp59968\homeassistant\automations.yaml"

# Vérifier que le fichier existe
if (-not (Test-Path $automationsFile)) {
    Write-Host "[ERREUR] Fichier automations.yaml introuvable: $automationsFile" -ForegroundColor Red
    exit 1
}

# Créer une sauvegarde
$backupFile = "$automationsFile.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $automationsFile $backupFile -Force
Write-Host "[OK] Sauvegarde créée: $backupFile" -ForegroundColor Green

# Lire le contenu
$content = Get-Content $automationsFile -Raw

# Séparer les automations (chaque automation commence par "- id:")
$automations = $content -split '(?=^- id:)' -ne ''

Write-Host "`n[INFO] Nombre total d'automations trouvées: $($automations.Count)" -ForegroundColor Yellow

# Détecter les doublons
$seenIds = @{}
$uniqueAutomations = @()
$duplicatesRemoved = 0

foreach ($automation in $automations) {
    # Extraire l'ID (première ligne "- id: xxx")
    if ($automation -match '- id:\s*(\S+)') {
        $id = $matches[1]

        if ($seenIds.ContainsKey($id)) {
            # C'est un doublon, on le saute
            Write-Host "[DOUBLON] Supprimé: $id" -ForegroundColor Red
            $duplicatesRemoved++
        } else {
            # Première occurrence, on la garde
            $seenIds[$id] = $true
            $uniqueAutomations += $automation
            Write-Host "[OK] Gardé: $id" -ForegroundColor Green
        }
    } else {
        # Pas d'ID trouvé, on garde quand même (header du fichier, etc.)
        $uniqueAutomations += $automation
    }
}

# Reconstruire le fichier
$newContent = $uniqueAutomations -join ""

# Écrire le nouveau contenu
Set-Content -Path $automationsFile -Value $newContent -NoNewline -Encoding UTF8

Write-Host "`n===================================" -ForegroundColor Cyan
Write-Host "RÉSUMÉ" -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Cyan
Write-Host "Automations totales: $($automations.Count)" -ForegroundColor Yellow
Write-Host "Doublons supprimés: $duplicatesRemoved" -ForegroundColor Red
Write-Host "Automations uniques: $($uniqueAutomations.Count)" -ForegroundColor Green
Write-Host "`nSauvegarde: $backupFile" -ForegroundColor Cyan

if ($duplicatesRemoved -gt 0) {
    Write-Host "`n[SUCCESS] Nettoyage terminé avec succès!" -ForegroundColor Green
    Write-Host "`n[IMPORTANT] Redémarrez Home Assistant pour appliquer les changements:" -ForegroundColor Yellow
    Write-Host "  ha core restart" -ForegroundColor White
} else {
    Write-Host "`n[INFO] Aucun doublon trouvé" -ForegroundColor Yellow
}

Write-Host "`n===================================`n" -ForegroundColor Cyan
