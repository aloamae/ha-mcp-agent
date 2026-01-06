# Script de déploiement vers Linux
# Usage: .\deploy_to_linux.ps1 -LinuxIP "192.168.0.XXX" -LinuxUser "votre_user"

param(
    [Parameter(Mandatory=$true)]
    [string]$LinuxIP,
    [Parameter(Mandatory=$true)]
    [string]$LinuxUser,
    [string]$RemotePath = "~/domotique_project"
)

$ErrorActionPreference = "Stop"
$CurrentDir = Get-Location
$ZipFile = "$CurrentDir\project_backup.zip"

Write-Host "=== DÉBUT DU DÉPLOIEMENT VERS LINUX ===" -ForegroundColor Cyan

# 1. Nettoyage des fichiers temporaires précédents
if (Test-Path $ZipFile) { Remove-Item $ZipFile }

# 2. Compression du projet (exclusion des dossiers lourds/inutiles si besoin)
Write-Host "1. Compression des fichiers..." -ForegroundColor Yellow
Compress-Archive -Path ".\*" -DestinationPath $ZipFile -CompressionLevel Optimal -Force

# 3. Transfert vers Linux
Write-Host "2. Transfert vers $LinuxUser@$LinuxIP..." -ForegroundColor Yellow
Write-Host "   (Entrez votre mot de passe Linux si demandé)" -ForegroundColor Gray

# Création du dossier distant
ssh "$LinuxUser@$LinuxIP" "mkdir -p $RemotePath"

# Copie du fichier
scp $ZipFile "$LinuxUser@$LinuxIP`:$RemotePath/"

# 4. Extraction et Setup sur Linux
Write-Host "3. Installation sur Linux..." -ForegroundColor Yellow
$RemoteScript = @"
cd $RemotePath
unzip -o project_backup.zip
rm project_backup.zip
chmod +x linux_setup.sh
./linux_setup.sh
"@

ssh "$LinuxUser@$LinuxIP" $RemoteScript

# 5. Nettoyage local
Remove-Item $ZipFile

Write-Host ""
Write-Host "=== DÉPLOIEMENT TERMINÉ AVEC SUCCÈS ! ===" -ForegroundColor Green
Write-Host "Le projet est disponible sur votre Linux dans : $RemotePath"
Write-Host "Vous pouvez maintenant vous connecter et lancer 'code .' dans ce dossier."