# =====================================
# SCRIPT SUPPRESSION FICHIERS OBSOLETES
# Date: 21 decembre 2025
# =====================================

$ErrorActionPreference = "Continue"

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "SUPPRESSION FICHIERS OBSOLETES" -ForegroundColor Cyan
Write-Host "==================================`n" -ForegroundColor Cyan

# Changer vers le bon repertoire
Set-Location "C:\DATAS\AI\Projets\Perso\Domotique"

$compteur = 0
$erreurs = 0

# Liste des fichiers a supprimer
$fichiers = @(
    # Groupe 1: Chauffage GAZ
    "automation_chauffage_FINAL_avec_mode_manuel.yaml",
    "automation_chauffage_GAZ_FINAL.yaml",
    "automation_chauffage_GAZ_v2.yaml",
    "automation_chauffage_pilotage_chaudiere_corrigee.yaml",

    # Groupe 2: Climatisation Salon
    "automation_climatisation_SALON.yaml",
    "automation_climatisation_SALON_sans_logs.yaml",
    "automation_climatisation_SALON_v2.yaml",

    # Groupe 3: Climatisation Axel
    "automation_climatisation_AXEL.yaml",
    "automation_climatisation_AXEL_sans_logs.yaml",
    "automation_climatisation_AXEL_v2.yaml",

    # Groupe 4: Climatisation Maeva
    "automation_climatisation_MAEVA.yaml",
    "automation_climatisation_MAEVA_sans_logs.yaml",
    "automation_climatisation_MAEVA_v2.yaml",

    # Groupe 5: Depart/Retour
    "automation_depart_simple.yaml",
    "automation_depart_corrigee.yaml",
    "automation_retour_corrigee.yaml"
)

Write-Host "Verification et suppression de $($fichiers.Count) fichiers...`n" -ForegroundColor Yellow

foreach ($fichier in $fichiers) {
    if (Test-Path $fichier) {
        try {
            Remove-Item $fichier -Force
            Write-Host "[OK] Supprime: $fichier" -ForegroundColor Green
            $compteur++
        }
        catch {
            Write-Host "[ERREUR] Impossible de supprimer: $fichier" -ForegroundColor Red
            $erreurs++
        }
    }
    else {
        Write-Host "[INFO] Fichier inexistant (deja supprime?): $fichier" -ForegroundColor Gray
    }
}

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "RESUME" -ForegroundColor Cyan
Write-Host "==================================`n" -ForegroundColor Cyan
Write-Host "Fichiers supprimes: $compteur" -ForegroundColor Green
Write-Host "Fichiers inexistants: $($fichiers.Count - $compteur - $erreurs)" -ForegroundColor Gray
Write-Host "Erreurs: $erreurs" -ForegroundColor $(if ($erreurs -gt 0) { "Red" } else { "Green" })

if ($compteur -gt 0) {
    Write-Host "`n[SUCCESS] Nettoyage termine avec succes!" -ForegroundColor Green
}
else {
    Write-Host "`n[INFO] Aucun fichier a supprimer (deja nettoye)" -ForegroundColor Yellow
}

Write-Host "`nFichiers CONSERVES (versions V3):" -ForegroundColor Cyan
$fichiers_gardes = @(
    "automation_chauffage_GAZ_v3.yaml",
    "automation_climatisation_SALON_v3.yaml",
    "automation_climatisation_AXEL_v3.yaml",
    "automation_climatisation_MAEVA_v3.yaml",
    "automation_depart_retour_FINAL.yaml"
)

foreach ($fichier in $fichiers_gardes) {
    if (Test-Path $fichier) {
        Write-Host "  [OK] $fichier" -ForegroundColor Green
    }
    else {
        Write-Host "  [ATTENTION] MANQUANT: $fichier" -ForegroundColor Red
    }
}

Write-Host "`n==================================`n" -ForegroundColor Cyan
