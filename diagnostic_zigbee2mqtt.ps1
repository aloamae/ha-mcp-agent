# Script de diagnostic Zigbee2MQTT pour Windows
# Date: 2025-12-18
# Usage: .\diagnostic_zigbee2mqtt.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC ZIGBEE2MQTT - $(Get-Date)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Fonction de vérification avec code couleur
function Check-Status {
    param(
        [bool]$Success,
        [string]$Message
    )

    if ($Success) {
        Write-Host "[OK] " -ForegroundColor Green -NoNewline
        Write-Host $Message
        return $true
    } else {
        Write-Host "[ERREUR] " -ForegroundColor Red -NoNewline
        Write-Host $Message
        return $false
    }
}

function Check-Warning {
    param([string]$Message)
    Write-Host "[ATTENTION] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

$IssuesCount = 0

Write-Host "1. VÉRIFICATION DE LA CONNECTIVITÉ DU COORDINATEUR"
Write-Host "---------------------------------------------------"

# Test de ping du coordinateur
$pingResult = Test-Connection -ComputerName 192.168.0.166 -Count 3 -Quiet -ErrorAction SilentlyContinue
if (-not (Check-Status $pingResult "Ping du coordinateur SLZB-MR1-MEZZA (192.168.0.166)")) {
    $IssuesCount++
}

# Test du port TCP 6638
try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $connection = $tcpClient.BeginConnect("192.168.0.166", 6638, $null, $null)
    $success = $connection.AsyncWaitHandle.WaitOne(5000, $false)
    $tcpClient.Close()

    if (-not (Check-Status $success "Port TCP 6638 accessible sur le coordinateur")) {
        $IssuesCount++
    }
} catch {
    Check-Status $false "Port TCP 6638 accessible sur le coordinateur"
    $IssuesCount++
}

Write-Host ""
Write-Host "2. VÉRIFICATION DE HOME ASSISTANT"
Write-Host "---------------------------------------------------"

# Vérifier si Home Assistant répond
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8123" -TimeoutSec 5 -ErrorAction Stop
    $haAccessible = $response.StatusCode -eq 200 -or $response.StatusCode -eq 401
} catch {
    $haAccessible = $false
}

Check-Status $haAccessible "Home Assistant accessible sur localhost:8123"

Write-Host ""
Write-Host "3. VÉRIFICATION DE MOSQUITTO (MQTT BROKER)"
Write-Host "---------------------------------------------------"

# Test de connexion au port MQTT
try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $connection = $tcpClient.BeginConnect("localhost", 1883, $null, $null)
    $mqttPortOpen = $connection.AsyncWaitHandle.WaitOne(3000, $false)
    $tcpClient.Close()

    if (-not (Check-Status $mqttPortOpen "Port MQTT 1883 accessible")) {
        $IssuesCount++
    }
} catch {
    Check-Status $false "Port MQTT 1883 accessible"
    $IssuesCount++
}

Write-Host ""
Write-Host "4. VÉRIFICATION DE ZIGBEE2MQTT"
Write-Host "---------------------------------------------------"

# Vérifier l'interface Web Z2M (port 8100 - le 8099 est utilisé par HA Vibecode Agent)
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8100" -TimeoutSec 5 -ErrorAction Stop
    $z2mAccessible = $response.StatusCode -eq 200 -or $response.StatusCode -eq 401
} catch {
    $z2mAccessible = $false
}

if ($z2mAccessible) {
    Check-Status $true "Interface Web Zigbee2MQTT accessible (port 8100)"
    Write-Host "   → Zigbee2MQTT semble démarré et opérationnel"
} else {
    Check-Status $false "Interface Web Zigbee2MQTT accessible (port 8100)"
    Check-Warning "Zigbee2MQTT n'est probablement pas démarré ou pas installé"
    $IssuesCount++
}

Write-Host ""
Write-Host "5. VÉRIFICATION DES FICHIERS DE CONFIGURATION (via réseau)"
Write-Host "---------------------------------------------------"

Check-Warning "Cette vérification nécessite un accès direct aux fichiers Home Assistant"
Write-Host "   → Connexion SSH ou accès au système de fichiers requis"
Write-Host "   → Fichier attendu : /config/zigbee2mqtt/configuration.yaml"

Write-Host ""
Write-Host "6. TESTS DE CONNECTIVITÉ AVANCÉS"
Write-Host "---------------------------------------------------"

# Test de résolution DNS locale
$dnsTest = Test-Connection -ComputerName "homeassistant.local" -Count 1 -Quiet -ErrorAction SilentlyContinue
Check-Status $dnsTest "Résolution DNS 'homeassistant.local'"

# Test des ports Home Assistant
$ports = @{
    "8123" = "Home Assistant Web UI"
    "8099" = "HA Vibecode Agent (MCP)"
    "8100" = "Zigbee2MQTT Frontend"
    "1883" = "Mosquitto MQTT"
}

foreach ($port in $ports.Keys) {
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connection = $tcpClient.BeginConnect("localhost", $port, $null, $null)
        $success = $connection.AsyncWaitHandle.WaitOne(2000, $false)
        $tcpClient.Close()

        Check-Status $success "Port $port ouvert ($($ports[$port]))"
    } catch {
        Check-Status $false "Port $port ouvert ($($ports[$port]))"
    }
}

Write-Host ""
Write-Host "7. RÉSUMÉ ET RECOMMANDATIONS"
Write-Host "---------------------------------------------------"

if ($IssuesCount -eq 0) {
    Write-Host "✓ Tous les composants critiques semblent opérationnels" -ForegroundColor Green
    Write-Host ""
    Write-Host "Prochaines étapes recommandées :"
    Write-Host "1. Accéder à l'interface Zigbee2MQTT : http://homeassistant.local:8100"
    Write-Host "2. Vérifier les logs pour toute erreur"
    Write-Host "3. Activer le mode appairage (Permit Join)"
    Write-Host "4. Réassocier les routeurs mesh en priorité :"
    Write-Host "   - Prise_Mesh_Salon"
    Write-Host "   - Prise_Mesh_Cuisine"
    Write-Host "5. Attendre 5-10 minutes pour stabilisation du mesh"
    Write-Host "6. Réassocier les 7 capteurs température/humidité"
} else {
    Write-Host "✗ $IssuesCount problème(s) détecté(s)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Actions correctives nécessaires :" -ForegroundColor Yellow

    if (-not $pingResult) {
        Write-Host "- Vérifier que le coordinateur SLZB-MR1-MEZZA est allumé et connecté au réseau"
        Write-Host "  Accéder à l'interface web : http://192.168.0.166"
    }

    if (-not $z2mAccessible) {
        Write-Host "- Installer ou démarrer l'add-on Zigbee2MQTT dans Home Assistant"
        Write-Host "  Paramètres → Modules complémentaires → Boutique des modules complémentaires"
    }

    if (-not $mqttPortOpen) {
        Write-Host "- Vérifier que Mosquitto MQTT broker est installé et démarré"
        Write-Host "  Paramètres → Modules complémentaires → Mosquitto broker"
    }
}

Write-Host ""
Write-Host "8. OUTILS UTILES POUR LE DIAGNOSTIC APPROFONDI"
Write-Host "---------------------------------------------------"

Write-Host "Interface Web Coordinateur : http://192.168.0.166" -ForegroundColor Cyan
Write-Host "Interface Web Zigbee2MQTT : http://homeassistant.local:8100 ou http://192.168.0.166:8100" -ForegroundColor Cyan
Write-Host "Interface Web Home Assistant : http://homeassistant.local:8123" -ForegroundColor Cyan
Write-Host "Interface MCP HA Vibecode Agent : http://localhost:8099 (NE PAS CONFONDRE avec Z2M)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Pour accéder aux logs Zigbee2MQTT :" -ForegroundColor Cyan
Write-Host "1. Interface Home Assistant → Paramètres → Modules complémentaires"
Write-Host "2. Cliquer sur Zigbee2MQTT → Onglet Journal"
Write-Host ""

Write-Host "Pour tester la connectivité MQTT (avec mosquitto_pub installé) :" -ForegroundColor Cyan
Write-Host 'mosquitto_pub -h localhost -p 1883 -t "test/diagnostic" -m "test" -u homeassistant -P VOTRE_MOT_DE_PASSE'
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "FIN DU DIAGNOSTIC - $(Get-Date)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Code de sortie basé sur le nombre de problèmes
exit $IssuesCount
