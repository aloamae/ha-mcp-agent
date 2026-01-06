#!/bin/bash

# Script de diagnostic Zigbee2MQTT
# Date: 2025-12-18
# Usage: ./diagnostic_zigbee2mqtt.sh

echo "=========================================="
echo "DIAGNOSTIC ZIGBEE2MQTT - $(date)"
echo "=========================================="
echo ""

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de vérification avec code couleur
check_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}[OK]${NC} $2"
        return 0
    else
        echo -e "${RED}[ERREUR]${NC} $2"
        return 1
    fi
}

check_warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

echo "1. VÉRIFICATION DE LA CONNECTIVITÉ DU COORDINATEUR"
echo "---------------------------------------------------"

# Test de ping du coordinateur
ping -c 3 192.168.0.166 > /dev/null 2>&1
check_status $? "Ping du coordinateur SLZB-MR1-MEZZA (192.168.0.166)"

# Test du port TCP 6638
timeout 5 bash -c "echo > /dev/tcp/192.168.0.166/6638" 2>/dev/null
check_status $? "Port TCP 6638 accessible sur le coordinateur"

echo ""
echo "2. VÉRIFICATION DE HOME ASSISTANT"
echo "---------------------------------------------------"

# Vérifier si Home Assistant répond
curl -s -o /dev/null -w "%{http_code}" http://localhost:8123 | grep -q "200\|401"
check_status $? "Home Assistant accessible sur localhost:8123"

echo ""
echo "3. VÉRIFICATION DE MOSQUITTO (MQTT BROKER)"
echo "---------------------------------------------------"

# Vérifier si Mosquitto est en cours d'exécution
if command -v ha &> /dev/null; then
    ha addons info core_mosquitto > /dev/null 2>&1
    check_status $? "Add-on Mosquitto installé"

    # Vérifier l'état de Mosquitto
    ha addons info core_mosquitto | grep -q "started"
    check_status $? "Add-on Mosquitto démarré"
else
    check_warning "CLI 'ha' non disponible, impossible de vérifier Mosquitto"
fi

# Test de connexion MQTT (nécessite mosquitto_pub)
if command -v mosquitto_pub &> /dev/null; then
    mosquitto_pub -h localhost -p 1883 -t "test/diagnostic" -m "test" -u homeassistant -P "" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        check_status 0 "Connexion MQTT réussie (sans authentification)"
    else
        check_warning "Connexion MQTT refusée (authentification probablement requise)"
    fi
else
    check_warning "mosquitto_pub non disponible, test MQTT ignoré"
fi

echo ""
echo "4. VÉRIFICATION DE ZIGBEE2MQTT"
echo "---------------------------------------------------"

if command -v ha &> /dev/null; then
    # Vérifier si Z2M est installé
    ha addons list | grep -q "zigbee2mqtt"
    if [ $? -eq 0 ]; then
        check_status 0 "Add-on Zigbee2MQTT installé"

        # Vérifier l'état de Z2M
        ha addons info core_zigbee2mqtt | grep -q "started"
        check_status $? "Add-on Zigbee2MQTT démarré"

        # Vérifier l'interface Web Z2M (port 8100 - le 8099 est utilisé par HA Vibecode Agent)
        curl -s -o /dev/null -w "%{http_code}" http://localhost:8100 | grep -q "200\|401"
        check_status $? "Interface Web Zigbee2MQTT accessible (port 8100)"
    else
        check_status 1 "Add-on Zigbee2MQTT installé"
        echo -e "${YELLOW}>>> ZIGBEE2MQTT N'EST PAS INSTALLÉ <<<${NC}"
        echo "Installation nécessaire : Paramètres → Modules complémentaires → Boutique"
    fi
else
    check_warning "CLI 'ha' non disponible, vérification Z2M impossible"
fi

echo ""
echo "5. VÉRIFICATION DES FICHIERS DE CONFIGURATION"
echo "---------------------------------------------------"

# Vérifier l'existence du fichier de configuration Z2M
if [ -f "/config/zigbee2mqtt/configuration.yaml" ]; then
    check_status 0 "Fichier configuration.yaml existe"

    # Vérifier les paramètres critiques
    grep -q "port: tcp://192.168.0.166:6638" /config/zigbee2mqtt/configuration.yaml
    check_status $? "Port coordinateur configuré (tcp://192.168.0.166:6638)"

    grep -q "adapter: ezsp" /config/zigbee2mqtt/configuration.yaml
    check_status $? "Adaptateur EZSP configuré"

    grep -q "homeassistant: true" /config/zigbee2mqtt/configuration.yaml
    check_status $? "Intégration Home Assistant activée"

    grep -q "server: mqtt://localhost:1883" /config/zigbee2mqtt/configuration.yaml
    check_status $? "Serveur MQTT configuré (localhost:1883)"
else
    check_status 1 "Fichier configuration.yaml existe"
    check_warning "Configuration Zigbee2MQTT non trouvée, création nécessaire"
fi

# Vérifier l'existence de la base de données Z2M
if [ -f "/config/zigbee2mqtt/database.db" ]; then
    check_status 0 "Base de données Zigbee2MQTT existe"

    # Compter les appareils dans la base
    DEVICE_COUNT=$(sqlite3 /config/zigbee2mqtt/database.db "SELECT COUNT(*) FROM devices;" 2>/dev/null || echo "0")
    echo "   → Nombre d'appareils dans la base : $DEVICE_COUNT"
else
    check_warning "Base de données Zigbee2MQTT non trouvée (normal si première installation)"
fi

echo ""
echo "6. VÉRIFICATION DES LOGS ZIGBEE2MQTT (20 dernières lignes)"
echo "---------------------------------------------------"

if command -v ha &> /dev/null; then
    ha addons logs core_zigbee2mqtt | tail -20
else
    check_warning "CLI 'ha' non disponible, impossible d'afficher les logs"
fi

echo ""
echo "7. RÉSUMÉ ET RECOMMANDATIONS"
echo "---------------------------------------------------"

# Compteur de problèmes
ISSUES=0

# Vérifier chaque composant critique
ping -c 1 192.168.0.166 > /dev/null 2>&1 || ((ISSUES++))
timeout 2 bash -c "echo > /dev/tcp/192.168.0.166/6638" 2>/dev/null || ((ISSUES++))

if command -v ha &> /dev/null; then
    ha addons info core_mosquitto | grep -q "started" || ((ISSUES++))
    ha addons list | grep -q "zigbee2mqtt" || ((ISSUES++))
fi

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓ Tous les composants critiques semblent opérationnels${NC}"
    echo ""
    echo "Prochaines étapes recommandées :"
    echo "1. Vérifier que Zigbee2MQTT est démarré et sans erreurs"
    echo "2. Activer le mode appairage (Permit Join)"
    echo "3. Réassocier les routeurs mesh en priorité"
    echo "4. Réassocier les capteurs après stabilisation du mesh"
else
    echo -e "${RED}✗ $ISSUES problème(s) détecté(s)${NC}"
    echo ""
    echo "Actions correctives nécessaires :"

    ping -c 1 192.168.0.166 > /dev/null 2>&1 || \
        echo "- Vérifier que le coordinateur SLZB-MR1-MEZZA est allumé et connecté au réseau"

    timeout 2 bash -c "echo > /dev/tcp/192.168.0.166/6638" 2>/dev/null || \
        echo "- Vérifier que le serveur TCP est activé sur le coordinateur (port 6638)"

    if command -v ha &> /dev/null; then
        ha addons info core_mosquitto | grep -q "started" || \
            echo "- Démarrer l'add-on Mosquitto"

        ha addons list | grep -q "zigbee2mqtt" || \
            echo "- Installer l'add-on Zigbee2MQTT"
    fi
fi

echo ""
echo "=========================================="
echo "FIN DU DIAGNOSTIC - $(date)"
echo "=========================================="

exit $ISSUES
