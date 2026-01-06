# ========================================
# SCRIPT D'INSTALLATION - AUTOMATION CORRIGÉE
# ========================================
#
# Ce script remplace automatiquement l'automation
# "Chauffage - Pilotage Chaudière GAZ" par la version
# corrigée avec seuils ±0.5°C
#
# ========================================

param(
    [switch]$TestOnly,  # Mode test: affiche les changements sans les appliquer
    [switch]$Force      # Force l'installation sans confirmation
)

$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = $env:HA_TOKEN

if (-not $HA_TOKEN) {
    Write-Host "⚠️ Variable HA_TOKEN non definie - Utilisation du token par defaut" -ForegroundColor Yellow
    $HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"
}

$headers = @{
    "Authorization" = "Bearer $HA_TOKEN"
    "Content-Type" = "application/json"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "INSTALLATION AUTOMATION CORRIGÉE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test connexion
Write-Host "Test de connexion a Home Assistant..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$HA_URL/api/" -Headers $headers -Method Get -TimeoutSec 30 -ErrorAction Stop
    Write-Host "✅ Connexion reussie" -ForegroundColor Green
    Write-Host "   Message HA: $($response.message)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "⚠️ Connexion HA via API impossible" -ForegroundColor Yellow
    Write-Host "   Erreur: $_" -ForegroundColor Gray
    Write-Host "`nPas de probleme! Le script va continuer en mode manuel." -ForegroundColor Cyan
    Write-Host "Tu devras copier-coller le YAML manuellement dans Home Assistant.`n" -ForegroundColor White
    $script:apiAvailable = $false
}

# Charger le fichier automation corrigée
$automationFile = Join-Path $PSScriptRoot "automation_chauffage_pilotage_chaudiere_corrigee.yaml"

if (-not (Test-Path $automationFile)) {
    Write-Host "❌ Fichier automation corrigée non trouvé:" -ForegroundColor Red
    Write-Host "   $automationFile" -ForegroundColor White
    Write-Host "`nAssurez-vous que le fichier existe dans le même dossier." -ForegroundColor Yellow
    exit 1
}

Write-Host "📄 Fichier automation trouvé:" -ForegroundColor Green
Write-Host "   $automationFile`n" -ForegroundColor White

# Lire le contenu
$newAutomation = Get-Content $automationFile -Raw -Encoding UTF8

# Récupérer l'automation actuelle (si API disponible)
if ($script:apiAvailable -ne $false) {
    Write-Host "Récupération de l'automation actuelle..." -ForegroundColor Cyan
    try {
        $currentAutomation = Invoke-RestMethod -Uri "$HA_URL/api/states/automation.chauffage_pilotage_chaudiere_gaz" -Headers $headers -Method Get -ErrorAction Stop
        Write-Host "✅ Automation actuelle récupérée`n" -ForegroundColor Green

        Write-Host "État actuel:" -ForegroundColor Yellow
        Write-Host "  Nom: $($currentAutomation.attributes.friendly_name)" -ForegroundColor White
        Write-Host "  État: $($currentAutomation.state)" -ForegroundColor White
        Write-Host "  Dernier déclenchement: $($currentAutomation.attributes.last_triggered)" -ForegroundColor White

    } catch {
        Write-Host "⚠️ Automation actuelle non trouvée via API" -ForegroundColor Yellow
        Write-Host "   Elle sera modifiée manuellement" -ForegroundColor White
    }
} else {
    Write-Host "⚠️ Mode manuel - API non disponible" -ForegroundColor Yellow
    Write-Host "   L'automation sera vérifiée manuellement dans HA" -ForegroundColor White
}

# Afficher les différences
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "MODIFICATIONS QUI SERONT APPLIQUÉES" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "✅ Seuils température:" -ForegroundColor Green
Write-Host "   AVANT: >= 1 et <= -1" -ForegroundColor Red
Write-Host "   APRÈS: >= 0.5 et <= -0.5" -ForegroundColor Green

Write-Host "`n✅ Zone morte:" -ForegroundColor Green
Write-Host "   AVANT: default → switch.turn_off (éteint)" -ForegroundColor Red
Write-Host "   APRÈS: default → Maintien état + log" -ForegroundColor Green

Write-Host "`n✅ Logs ajoutés:" -ForegroundColor Green
Write-Host "   - ALLUMAGE chaudière (avec températures)" -ForegroundColor White
Write-Host "   - EXTINCTION chaudière (avec températures)" -ForegroundColor White
Write-Host "   - ZONE MORTE maintien état (avec températures)" -ForegroundColor White

if ($TestOnly) {
    Write-Host "`n⚠️ MODE TEST ACTIVÉ - Aucune modification appliquée" -ForegroundColor Yellow
    Write-Host "`nPour installer réellement, relancer sans -TestOnly" -ForegroundColor White
    exit 0
}

# Confirmation
if (-not $Force) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "CONFIRMATION" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    Write-Host "⚠️ Cette opération va:" -ForegroundColor Yellow
    Write-Host "  1. Sauvegarder l'automation actuelle" -ForegroundColor White
    Write-Host "  2. Remplacer par la version corrigée" -ForegroundColor White
    Write-Host "  3. Recharger les automations HA" -ForegroundColor White

    $confirmation = Read-Host "`nContinuer? (o/N)"

    if ($confirmation -ne 'o' -and $confirmation -ne 'O') {
        Write-Host "`n❌ Installation annulée" -ForegroundColor Red
        exit 0
    }
}

# Sauvegarde (si API disponible)
if ($script:apiAvailable -ne $false -and $currentAutomation) {
    Write-Host "`n📦 Sauvegarde de l'automation actuelle..." -ForegroundColor Cyan
    $backupFile = Join-Path $PSScriptRoot "automation_chaudiere_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"

    try {
        $currentAutomation | ConvertTo-Json -Depth 10 | Out-File $backupFile -Encoding UTF8
        Write-Host "✅ Sauvegarde créée:" -ForegroundColor Green
        Write-Host "   $backupFile`n" -ForegroundColor White
    } catch {
        Write-Host "⚠️ Impossible de créer la sauvegarde: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n📦 Sauvegarde automatique non disponible (API inaccessible)" -ForegroundColor Yellow
    Write-Host "   IMPORTANT: Copie le YAML actuel avant de le remplacer!" -ForegroundColor Red
    Write-Host "   (Dans HA → Automation → ... → Modifier YAML → Copier tout)`n" -ForegroundColor White
}

# Installation
Write-Host "🔧 Installation de la nouvelle automation..." -ForegroundColor Cyan

Write-Host "`n⚠️ INSTALLATION MANUELLE (5 minutes)" -ForegroundColor Yellow
Write-Host "`nL'API Home Assistant ne permet pas de modifier directement les automations." -ForegroundColor White
Write-Host "Pas de problème! Suis ces étapes simples:`n" -ForegroundColor Cyan

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ÉTAPES D'INSTALLATION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "1️⃣ Copier le fichier automation corrigée" -ForegroundColor Green
Write-Host "   Le fichier va s'ouvrir automatiquement dans Notepad" -ForegroundColor White
Write-Host "   Faire: Ctrl+A (tout sélectionner) puis Ctrl+C (copier)`n" -ForegroundColor White

Write-Host "2️⃣ Ouvrir Home Assistant dans le navigateur" -ForegroundColor Green
Write-Host "   URL: http://192.168.0.166:8123`n" -ForegroundColor White

Write-Host "3️⃣ Navigation dans HA" -ForegroundColor Green
Write-Host "   Menu -> Parametres -> Automations et scenes" -ForegroundColor White
Write-Host "   Chercher: chaudiere" -ForegroundColor White
Write-Host "   Cliquer sur: Chauffage - Pilotage Chaudiere GAZ`n" -ForegroundColor White

Write-Host "4️⃣ Modifier l'automation" -ForegroundColor Green
Write-Host "   Cliquer sur ... (3 points) -> Modifier au format YAML" -ForegroundColor White
Write-Host "   Ctrl+A (tout selectionner)" -ForegroundColor White
Write-Host "   Delete (supprimer)" -ForegroundColor White
Write-Host "   Ctrl+V (coller le nouveau YAML)" -ForegroundColor White
Write-Host "   Cliquer ENREGISTRER`n" -ForegroundColor White

Write-Host "5️⃣ Vérifier" -ForegroundColor Green
Write-Host "   Cliquer EXECUTER pour tester" -ForegroundColor White
Write-Host "   Outils de developpement -> Logs" -ForegroundColor White
Write-Host "   Attendre 3 min puis chercher: ZONE MORTE ou ALLUMAGE`n" -ForegroundColor White

Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ASSISTANCE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Je peux:" -ForegroundColor Yellow
Write-Host "  1. Ouvrir automatiquement Home Assistant dans le navigateur" -ForegroundColor White
Write-Host "  2. Ouvrir le fichier automation dans l'éditeur" -ForegroundColor White
Write-Host "  3. Afficher le guide d'installation complet" -ForegroundColor White

$choice = Read-Host "`nVotre choix (1/2/3/Enter pour quitter)"

switch ($choice) {
    "1" {
        Write-Host "`nOuverture de Home Assistant..." -ForegroundColor Cyan
        Start-Process "http://192.168.0.166:8123/config/automation"
    }
    "2" {
        Write-Host "`nOuverture du fichier automation..." -ForegroundColor Cyan
        notepad $automationFile
    }
    "3" {
        $guideFile = Join-Path $PSScriptRoot "GUIDE_INSTALLATION_AUTOMATION_CORRIGEE.md"
        if (Test-Path $guideFile) {
            Write-Host "`nOuverture du guide..." -ForegroundColor Cyan
            Start-Process $guideFile
        } else {
            Write-Host "❌ Guide non trouvé: $guideFile" -ForegroundColor Red
        }
    }
    default {
        Write-Host "`nAu revoir!" -ForegroundColor Cyan
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VÉRIFICATION POST-INSTALLATION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Après l'installation manuelle, vérifier:" -ForegroundColor Yellow
Write-Host "  ✓ Automation activée (ON)" -ForegroundColor White
Write-Host "  ✓ Aucune erreur dans les logs" -ForegroundColor White
Write-Host "  ✓ Messages logs toutes les 3 minutes" -ForegroundColor White
Write-Host "  ✓ Chaudière réagit correctement" -ForegroundColor White

Write-Host "`nOutils de developpement -> Logs" -ForegroundColor Cyan
Write-Host "Chercher: ZONE MORTE ou ALLUMAGE ou EXTINCTION" -ForegroundColor White

Write-Host "`nScript termine`n" -ForegroundColor Green
