# Exemples Pratiques d'Utilisation MCP pour l'Optimisation Zigbee

**Date**: 2025-12-18
**Objectif**: Exemples concrets et copy-paste ready

---

## SCÉNARIO 1: Diagnostic Complet d'un Capteur

### Objectif
Vérifier pourquoi le capteur `th_cuisine` ne se met pas à jour rapidement

### Commandes

```bash
# 1. Vérifier l'état actuel de toutes les entités du capteur
echo "=== État Température ==="
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature

echo "=== État Humidité ==="
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_humidity

echo "=== État Batterie ==="
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_battery

echo "=== Qualité du Lien ==="
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_linkquality

# 2. Analyser les logs Zigbee2MQTT pour ce capteur
echo "=== Logs récents de th_cuisine ==="
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 200 | grep "th_cuisine"

# 3. Forcer une mise à jour et mesurer le temps de réponse
echo "=== Test de réactivité ==="
echo "Timestamp avant: $(date +%H:%M:%S)"

mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/th_cuisine/get" \
  --payload '{"temperature": "", "humidity": ""}'

echo "Commande envoyée à $(date +%H:%M:%S)"
echo "Attendre 10 secondes..."
sleep 10

mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature

echo "Timestamp après: $(date +%H:%M:%S)"
```

### Interprétation des Résultats

```
Si LQI < 50:
  → Capteur trop éloigné des routeurs
  → Solution: Ajouter une prise mesh ou rapprocher le capteur

Si Batterie < 20%:
  → Mode économie d'énergie activé
  → Solution: Remplacer la pile immédiatement

Si last_updated > 10 minutes:
  → Intervalle de reporting trop long
  → Solution: Appliquer la configuration optimisée

Si aucune réponse après "get":
  → Capteur probablement offline
  → Solution: Vérifier la pile, ré-appairer le capteur
```

---

## SCÉNARIO 2: Obtenir les IEEE Addresses de Tous les Capteurs

### Objectif
Récupérer les adresses IEEE nécessaires pour la configuration `device_options`

### Commandes

```bash
# Méthode 1: Via MQTT (requiert d'écouter la réponse)
echo "=== Demande de la liste des devices ==="
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/devices" \
  --payload '{}'

echo "=== Écoute de la réponse (Ctrl+C pour arrêter) ==="
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/bridge/devices"

# Méthode 2: Via les logs Zigbee2MQTT
echo "=== Recherche dans les logs ==="
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 500 | grep -E "th_cuisine|th_salon|th_loann|th_meva|th_axel|th_parents|th_terrasse"
```

### Alternative: Via Interface Web

```
1. Ouvrir http://192.168.0.166:8100
2. Onglet "Devices"
3. Cliquer sur "th_cuisine"
4. Noter l'IEEE address (exemple: 0xa4c138243da0ebf6)
5. Répéter pour les 7 capteurs
```

### Tableau à Remplir

```
| Capteur      | IEEE Address          | Model      | Batterie | LQI |
|--------------|-----------------------|------------|----------|-----|
| th_cuisine   | 0x__________________ | __________ | _____% | ____ |
| th_salon     | 0x__________________ | __________ | _____% | ____ |
| th_loann     | 0x__________________ | __________ | _____% | ____ |
| th_meva      | 0x__________________ | __________ | _____% | ____ |
| th_axel      | 0x__________________ | __________ | _____% | ____ |
| th_parents   | 0x__________________ | __________ | _____% | ____ |
| th_terrasse  | 0x__________________ | __________ | _____% | ____ |
```

---

## SCÉNARIO 3: Appliquer la Configuration de Reporting

### Objectif
Configurer les intervalles de reporting via la configuration Zigbee2MQTT

### Étapes Détaillées

#### 1. Backup de la Configuration Actuelle

```bash
# Via MCP (si accès fichiers disponible)
echo "=== Sauvegarde de la configuration actuelle ==="
mcp call homeassistant read_file --path "/config/zigbee2mqtt/configuration.yaml" > zigbee2mqtt_config_backup_$(date +%Y%m%d_%H%M%S).yaml

echo "Backup créé: zigbee2mqtt_config_backup_$(date +%Y%m%d_%H%M%S).yaml"
```

#### 2. Éditer la Configuration

**IMPORTANT**: Cette étape se fait manuellement car elle nécessite d'éditer un fichier

1. Accéder à `/config/zigbee2mqtt/configuration.yaml`
2. Copier la section `device_options` depuis `zigbee2mqtt_reporting_optimization.yaml`
3. Remplacer les IEEE addresses par les vraies valeurs
4. Vérifier la syntaxe YAML (espaces, pas de tabulations)

#### 3. Appliquer la Configuration

```bash
# Redémarrer Zigbee2MQTT pour appliquer les changements
echo "=== Redémarrage de Zigbee2MQTT ==="
mcp call homeassistant restart_addon --addon core_zigbee2mqtt

echo "Attendre 30 secondes pour que Z2M redémarre..."
sleep 30

# Vérifier que Z2M est bien redémarré
echo "=== Vérification de l'état de Zigbee2MQTT ==="
mcp call homeassistant get_addon_info --addon core_zigbee2mqtt
```

#### 4. Vérifier l'Application

```bash
# Chercher les messages de succès ou d'échec dans les logs
echo "=== Recherche des messages de configuration du reporting ==="
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 100 | grep -E "reporting|configured|th_cuisine|th_salon"

# Exemple de sortie attendue (SUCCÈS):
# [INFO] Successfully configured reporting for 'th_cuisine' - temperature
# [INFO] Successfully configured reporting for 'th_cuisine' - humidity

# Exemple de sortie en cas d'ÉCHEC:
# [WARNING] Device 'th_cuisine' does not support reporting configuration
```

#### 5. Si Échec: Activer Logs de Debug

```bash
# Activer temporairement le mode debug
echo "=== Activation du mode debug ==="
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/options" \
  --payload '{"options": {"advanced": {"log_level": "debug"}}}'

# Tenter à nouveau la configuration
mcp call homeassistant restart_addon --addon core_zigbee2mqtt

sleep 30

# Analyser les logs détaillés
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 200 | grep -E "reporting|bind|configure"

# Remettre le log level à info
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/options" \
  --payload '{"options": {"advanced": {"log_level": "info"}}}'
```

---

## SCÉNARIO 4: Créer l'Automation de Polling

### Objectif
Mettre en place le polling actif si la reconfiguration ne fonctionne pas

### Méthode: Via l'Interface Home Assistant

```
1. Ouvrir Home Assistant
2. Paramètres → Automations et Scènes
3. Créer une automation
4. Nom: "Zigbee - Polling capteurs T/H (3 min)"
5. Déclencheur:
   - Type: Motif horaire
   - Minutes: /3
6. Actions (répéter pour chaque capteur):
   - Service: mqtt.publish
   - Topic: zigbee2mqtt/th_cuisine/get
   - Payload: {"temperature": "", "humidity": ""}
7. Mode: Single
8. Sauvegarder
```

### Méthode: Via YAML

**Créer le fichier**: `/config/automations/zigbee_polling.yaml`

```yaml
# Automation de polling des capteurs Zigbee
- alias: "Zigbee - Polling capteurs T/H (3 min)"
  description: "Force la mise à jour des capteurs toutes les 3 minutes"
  trigger:
    - platform: time_pattern
      minutes: "/3"
  action:
    # Cuisine
    - service: mqtt.publish
      data:
        topic: "zigbee2mqtt/th_cuisine/get"
        payload: '{"temperature": "", "humidity": ""}'

    # Salon
    - service: mqtt.publish
      data:
        topic: "zigbee2mqtt/th_salon/get"
        payload: '{"temperature": "", "humidity": ""}'

    # Chambre Loann
    - service: mqtt.publish
      data:
        topic: "zigbee2mqtt/th_loann/get"
        payload: '{"temperature": "", "humidity": ""}'

    # Chambre Meva
    - service: mqtt.publish
      data:
        topic: "zigbee2mqtt/th_meva/get"
        payload: '{"temperature": "", "humidity": ""}'

    # Chambre Axel
    - service: mqtt.publish
      data:
        topic: "zigbee2mqtt/th_axel/get"
        payload: '{"temperature": "", "humidity": ""}'

    # Chambre Parents
    - service: mqtt.publish
      data:
        topic: "zigbee2mqtt/th_parents/get"
        payload: '{"temperature": "", "humidity": ""}'

    # Terrasse
    - service: mqtt.publish
      data:
        topic: "zigbee2mqtt/th_terrasse/get"
        payload: '{"temperature": "", "humidity": ""}'

  mode: single
```

### Activer l'Automation

```bash
# Recharger les automations
echo "=== Rechargement des automations ==="
mcp call homeassistant call_service --service automation.reload

# Vérifier que l'automation existe
echo "=== Vérification de l'automation ==="
mcp call homeassistant get_entities --domain automation | grep -i "polling\|zigbee"

# Activer l'automation si elle est désactivée
mcp call homeassistant turn_on --entity_id automation.zigbee_polling_capteurs_t_h_3_min
```

---

## SCÉNARIO 5: Monitoring en Temps Réel

### Objectif
Surveiller les mises à jour des capteurs pendant 10 minutes

### Script Bash

```bash
#!/bin/bash

echo "=== Monitoring des capteurs Zigbee ==="
echo "Durée: 10 minutes"
echo "Début: $(date)"
echo ""

# Créer un fichier de log avec timestamp
LOGFILE="monitoring_$(date +%Y%m%d_%H%M%S).log"

# S'abonner à tous les topics des capteurs
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/th_#" | while read -r line; do
    # Ajouter un timestamp
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $line" | tee -a "$LOGFILE"
done &

MQTT_PID=$!

# Attendre 10 minutes
sleep 600

# Arrêter l'écoute MQTT
kill $MQTT_PID

echo ""
echo "=== Monitoring terminé ==="
echo "Fichier de log: $LOGFILE"
echo ""

# Analyser le log
echo "=== Résumé des mises à jour ==="
for sensor in th_cuisine th_salon th_loann th_meva th_axel th_parents th_terrasse; do
    count=$(grep -c "zigbee2mqtt/$sensor " "$LOGFILE" || echo "0")
    echo "$sensor: $count mises à jour"
done
```

### Script PowerShell

```powershell
# Monitoring en temps réel (nécessite un client MQTT)
Write-Host "=== Monitoring des capteurs Zigbee ===" -ForegroundColor Cyan
Write-Host "Pour un monitoring temps réel, utilisez MQTT Explorer:" -ForegroundColor Yellow
Write-Host "  1. Télécharger: http://mqtt-explorer.com/" -ForegroundColor White
Write-Host "  2. Connecter à: localhost:1883" -ForegroundColor White
Write-Host "  3. S'abonner à: zigbee2mqtt/#" -ForegroundColor White
Write-Host ""
Write-Host "Alternative: Utiliser le script validate_sensor_reporting.ps1" -ForegroundColor Yellow
```

---

## SCÉNARIO 6: Test de Charge (Forcer Updates Simultanées)

### Objectif
Tester la réactivité du système en forçant simultanément la mise à jour de tous les capteurs

### Commandes

```bash
#!/bin/bash

echo "=== Test de charge - Update simultanée de tous les capteurs ==="
echo "Timestamp début: $(date +%H:%M:%S.%3N)"
echo ""

# Tableau pour stocker les timestamps
declare -A start_times
declare -A end_times

sensors=("th_cuisine" "th_salon" "th_loann" "th_meva" "th_axel" "th_parents" "th_terrasse")

# 1. Capturer les états initiaux
echo "1. États initiaux:"
for sensor in "${sensors[@]}"; do
    state=$(mcp call homeassistant get_entity_state --entity_id "sensor.${sensor}_temperature" 2>/dev/null)
    temp=$(echo "$state" | jq -r '.state // "N/A"' 2>/dev/null)
    last_updated=$(echo "$state" | jq -r '.last_updated // "N/A"' 2>/dev/null)
    echo "  $sensor: $temp°C (last: $last_updated)"
done

echo ""
echo "2. Envoi des commandes de mise à jour (simultané)..."

# 2. Envoyer toutes les commandes en parallèle
for sensor in "${sensors[@]}"; do
    start_times[$sensor]=$(date +%s.%3N)

    mcp call homeassistant mqtt_publish \
      --topic "zigbee2mqtt/$sensor/get" \
      --payload '{"temperature": "", "humidity": ""}' &
done

wait  # Attendre que toutes les commandes soient envoyées

echo "Toutes les commandes envoyées à $(date +%H:%M:%S.%3N)"
echo ""

# 3. Attendre et vérifier les mises à jour
echo "3. Attente de 30 secondes pour les réponses..."
sleep 30

echo ""
echo "4. États après mise à jour:"
for sensor in "${sensors[@]}"; do
    state=$(mcp call homeassistant get_entity_state --entity_id "sensor.${sensor}_temperature" 2>/dev/null)
    temp=$(echo "$state" | jq -r '.state // "N/A"' 2>/dev/null)
    last_updated=$(echo "$state" | jq -r '.last_updated // "N/A"' 2>/dev/null)

    echo "  $sensor: $temp°C (last: $last_updated)"

    # Calculer le temps de réponse
    end_times[$sensor]=$(date +%s.%3N)

    if [[ "${start_times[$sensor]}" != "" && "${end_times[$sensor]}" != "" ]]; then
        response_time=$(echo "${end_times[$sensor]} - ${start_times[$sensor]}" | bc)
        echo "    → Temps de réponse: ${response_time}s"
    fi
done

echo ""
echo "=== Test terminé ==="
```

---

## SCÉNARIO 7: Nettoyage et Maintenance

### Objectif
Nettoyer les anciennes entités et vérifier la santé globale du système

### Commandes

```bash
# 1. Lister toutes les entités unavailable
echo "=== Entités Unavailable ==="
mcp call homeassistant get_entities --state unavailable

# 2. Lister les entités MQTT orphelines
echo "=== Entités MQTT ==="
mcp call homeassistant get_entities --integration mqtt

# 3. Vérifier l'état de tous les add-ons critiques
echo "=== État des Add-ons ==="
mcp call homeassistant get_addon_info --addon core_zigbee2mqtt
mcp call homeassistant get_addon_info --addon core_mosquitto

# 4. Analyser les erreurs récentes dans les logs
echo "=== Erreurs récentes Zigbee2MQTT ==="
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 500 | grep -i "error\|warning\|failed"

# 5. Vérifier la santé du réseau Zigbee
echo "=== Carte réseau Zigbee ==="
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/networkmap" \
  --payload '{"type": "raw"}'

# Écouter la réponse
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/bridge/response/networkmap"
```

---

## SCÉNARIO 8: Rollback en Cas de Problème

### Objectif
Revenir à la configuration précédente si l'optimisation cause des problèmes

### Commandes

```bash
# 1. Restaurer le backup de configuration
echo "=== Restauration de la configuration ==="
# ATTENTION: Cela suppose que vous avez fait un backup avant

# Option A: Via interface Home Assistant
# File Editor → /config/zigbee2mqtt/configuration.yaml
# Coller le contenu du backup

# Option B: Via MCP (si disponible)
mcp call homeassistant write_file \
  --path "/config/zigbee2mqtt/configuration.yaml" \
  --content "$(cat zigbee2mqtt_config_backup_*.yaml)"

# 2. Redémarrer Zigbee2MQTT
echo "=== Redémarrage de Zigbee2MQTT ==="
mcp call homeassistant restart_addon --addon core_zigbee2mqtt

sleep 30

# 3. Vérifier que tout est revenu à la normale
echo "=== Vérification ==="
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 50

# 4. Désactiver l'automation de polling si elle était activée
echo "=== Désactivation de l'automation de polling ==="
mcp call homeassistant turn_off --entity_id automation.zigbee_polling_capteurs_t_h_3_min
```

---

## NOTES IMPORTANTES

### Limitations MCP

Certaines commandes nécessitent des outils supplémentaires:

1. **Édition de fichiers**: MCP ne peut pas éditer directement les fichiers de configuration
   - Solution: Utiliser File Editor add-on ou SSH

2. **Monitoring en temps réel**: Nécessite `mosquitto_sub`
   - Solution Windows: Utiliser MQTT Explorer (interface graphique)
   - Solution Linux: Installer `mosquitto-clients`

3. **Parsing JSON**: Nécessite `jq`
   - Solution: Installer `jq` sur votre système

### Alternative Claude Desktop

Si vous utilisez Claude Desktop avec le serveur MCP configuré, vous avez accès direct aux outils MCP.

Configuration dans `~/.claude/mcp.json`:
```json
{
  "servers": {
    "home-assistant": {
      "command": "npx",
      "args": ["-y", "@coolver/home-assistant-mcp@latest"],
      "env": {
        "HA_AGENT_URL": "http://192.168.0.166:8099",
        "HA_AGENT_KEY": "VOTRE_CLE_API"
      }
    }
  }
}
```

---

**Dernière mise à jour**: 2025-12-18
