# Guide d'Optimisation des Intervalles de Reporting Zigbee2MQTT

**Date**: 2025-12-18
**Objectif**: Réduire le délai de mise à jour des capteurs température/humidité

---

## TABLE DES MATIÈRES

1. [Problème et Diagnostic](#problème-et-diagnostic)
2. [Solutions Disponibles](#solutions-disponibles)
3. [Méthode 1: Reconfiguration du Reporting Zigbee](#méthode-1-reconfiguration-du-reporting-zigbee)
4. [Méthode 2: Polling Actif via Home Assistant](#méthode-2-polling-actif-via-home-assistant)
5. [Validation et Tests](#validation-et-tests)
6. [Dépannage](#dépannage)

---

## PROBLÈME ET DIAGNOSTIC

### Symptômes

- Les capteurs de température/humidité mettent 10-30 minutes à se mettre à jour
- Les automations de chauffage réagissent trop lentement
- Les valeurs affichées dans Home Assistant sont obsolètes

### Causes Possibles

1. **Configuration par défaut du capteur**: Beaucoup de capteurs Zigbee ont des intervalles de reporting de 30-60 minutes par défaut
2. **Batterie faible**: Capteur < 20% → Mode économie d'énergie → Reports ralentis
3. **LQI faible**: Link Quality < 50 → Paquets perdus → Retards
4. **Firmware restrictif**: Certains capteurs (Xiaomi/Aqara) ignorent les commandes de reconfiguration

### Diagnostic Initial

#### Via MCP Home Assistant (RECOMMANDÉ)

```bash
# 1. Lister tous les capteurs de température
mcp call homeassistant get_entities --domain sensor

# 2. Vérifier l'état d'un capteur spécifique
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature

# 3. Consulter les logs Zigbee2MQTT
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 100

# 4. Filtrer les messages de reporting
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt | grep "temperature\|humidity\|report"
```

#### Via Interface Web Zigbee2MQTT

1. Ouvrir http://192.168.0.166:8100
2. Onglet "Devices"
3. Pour chaque capteur, vérifier:
   - **IEEE Address** (nécessaire pour la configuration)
   - **Model** (identifier le fabricant)
   - **Battery** (niveau de batterie)
   - **LQI** (qualité du lien, doit être > 50)
   - **Last Seen** (dernière activité)

#### Via Script de Diagnostic

```powershell
# Windows
.\diagnostic_zigbee2mqtt.ps1

# Linux/WSL
./diagnostic_zigbee2mqtt.sh
```

---

## SOLUTIONS DISPONIBLES

### Comparaison des Méthodes

| Critère | Méthode 1: Reconfiguration | Méthode 2: Polling |
|---------|----------------------------|-------------------|
| **Réactivité** | Excellente (1-3 min) | Bonne (selon intervalle) |
| **Impact Batterie** | Moyen | Faible |
| **Compatibilité** | Variable (selon modèle) | Universelle |
| **Complexité** | Moyenne | Facile |
| **Maintenance** | Aucune après config | Automation à maintenir |

### Recommandation

1. **Essayer d'abord la Méthode 1** (reconfiguration Zigbee)
2. **Si échec** (logs indiquent "device does not support reporting"), passer à la Méthode 2

---

## MÉTHODE 1: RECONFIGURATION DU REPORTING ZIGBEE

### Étape 1: Identifier les IEEE Addresses

#### Via MCP

```bash
# Publier une requête pour obtenir la liste des devices
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/devices" \
  --payload '{}'

# Écouter la réponse
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/bridge/devices"
```

#### Via Interface Web

1. Zigbee2MQTT Web UI (http://192.168.0.166:8100)
2. Cliquer sur chaque capteur
3. Noter l'IEEE Address (format: `0xaabbccddeeff0011`)

Exemple:
```
th_cuisine → 0xa4c138243da0ebf6
th_salon → 0xa4c138243da0ebf7
th_loann → 0xa4c138243da0ebf8
th_meva → 0xa4c138243da0ebf9
th_axel → 0xa4c138243da0ebfa
th_parents → 0xa4c138243da0ebfb
th_terrasse → 0xa4c138243da0ebfc
```

### Étape 2: Éditer la Configuration Zigbee2MQTT

#### Fichier de référence

Le fichier `zigbee2mqtt_reporting_optimization.yaml` contient une configuration complète.

#### Appliquer la Configuration

1. **Accéder au fichier de configuration**:
   - Via SSH/Console: `/config/zigbee2mqtt/configuration.yaml`
   - Via File Editor add-on dans Home Assistant
   - Via Samba/Network Share

2. **Remplacer les IEEE Addresses**:

   Ouvrir `zigbee2mqtt_reporting_optimization.yaml` et remplacer:
   ```yaml
   0x0000000000000003:  # REMPLACER PAR VOTRE IEEE ADDRESS
     friendly_name: th_cuisine
   ```

   Par vos vraies adresses:
   ```yaml
   0xa4c138243da0ebf6:
     friendly_name: th_cuisine
   ```

3. **Copier la section `device_options`**:

   Copier toute la section depuis `zigbee2mqtt_reporting_optimization.yaml`
   vers `/config/zigbee2mqtt/configuration.yaml`

4. **Vérifier la syntaxe YAML**:

   Attention aux indentations (espaces uniquement, PAS de tabulations)

### Étape 3: Redémarrer Zigbee2MQTT

#### Via MCP

```bash
# Redémarrer l'add-on Zigbee2MQTT
mcp call homeassistant restart_addon --addon core_zigbee2mqtt

# Attendre 30 secondes puis vérifier les logs
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 50
```

#### Via Interface Home Assistant

1. Paramètres → Modules complémentaires
2. Cliquer sur "Zigbee2MQTT"
3. Onglet "Info" → Bouton "Redémarrer"
4. Onglet "Journal" → Vérifier les logs

### Étape 4: Vérifier l'Application

Chercher dans les logs Zigbee2MQTT:

**Succès**:
```
[INFO] Successfully configured reporting for 'th_cuisine' - temperature
[INFO] Successfully configured reporting for 'th_cuisine' - humidity
```

**Échec** (capteur non compatible):
```
[WARNING] Device 'th_cuisine' does not support reporting configuration
[WARNING] Reporting configuration failed for 'th_cuisine'
```

Si échec → Passer à la Méthode 2

---

## MÉTHODE 2: POLLING ACTIF VIA HOME ASSISTANT

### Principe

Home Assistant envoie régulièrement une commande MQTT pour forcer la mise à jour des capteurs.

### Avantages

- Fonctionne avec TOUS les capteurs Zigbee
- Impact minimal sur la batterie
- Facile à configurer

### Configuration

#### Via MCP

```bash
# Créer une automation de polling
mcp call homeassistant mqtt_publish \
  --topic "homeassistant/automation/zigbee_sensor_polling/config" \
  --payload '{
    "alias": "Zigbee - Rafraîchir capteurs T/H toutes les 3 minutes",
    "description": "Force la mise à jour des capteurs qui ne reportent pas automatiquement",
    "trigger": [{
      "platform": "time_pattern",
      "minutes": "/3"
    }],
    "action": [
      {"service": "mqtt.publish", "data": {"topic": "zigbee2mqtt/th_cuisine/get", "payload": "{\"temperature\": \"\", \"humidity\": \"\"}"}},
      {"service": "mqtt.publish", "data": {"topic": "zigbee2mqtt/th_salon/get", "payload": "{\"temperature\": \"\", \"humidity\": \"\"}"}},
      {"service": "mqtt.publish", "data": {"topic": "zigbee2mqtt/th_loann/get", "payload": "{\"temperature\": \"\", \"humidity\": \"\"}"}},
      {"service": "mqtt.publish", "data": {"topic": "zigbee2mqtt/th_meva/get", "payload": "{\"temperature\": \"\", \"humidity\": \"\"}"}},
      {"service": "mqtt.publish", "data": {"topic": "zigbee2mqtt/th_axel/get", "payload": "{\"temperature\": \"\", \"humidity\": \"\"}"}},
      {"service": "mqtt.publish", "data": {"topic": "zigbee2mqtt/th_parents/get", "payload": "{\"temperature\": \"\", \"humidity\": \"\"}"}},
      {"service": "mqtt.publish", "data": {"topic": "zigbee2mqtt/th_terrasse/get", "payload": "{\"temperature\": \"\", \"humidity\": \"\"}"}}
    ],
    "mode": "single"
  }'
```

#### Via Interface Home Assistant

1. **Paramètres → Automations et Scènes → Créer une automation**

2. **Déclencheur**:
   - Type: Motif horaire
   - Minutes: `/3` (toutes les 3 minutes)

3. **Actions** (pour chaque capteur):
   - Type: Appeler un service
   - Service: `mqtt.publish`
   - Topic: `zigbee2mqtt/th_cuisine/get`
   - Payload: `{"temperature": "", "humidity": ""}`

4. **Répéter pour les 7 capteurs**

#### Via YAML (automations.yaml)

Copier depuis `zigbee2mqtt_reporting_optimization.yaml`:

```yaml
automation:
  - alias: "Zigbee - Rafraîchir capteurs T/H toutes les 3 minutes"
    description: "Force la mise à jour des capteurs qui ne reportent pas automatiquement"
    trigger:
      - platform: time_pattern
        minutes: "/3"
    action:
      - service: mqtt.publish
        data:
          topic: "zigbee2mqtt/th_cuisine/get"
          payload: '{"temperature": "", "humidity": ""}'
      - service: mqtt.publish
        data:
          topic: "zigbee2mqtt/th_salon/get"
          payload: '{"temperature": "", "humidity": ""}'
      - service: mqtt.publish
        data:
          topic: "zigbee2mqtt/th_loann/get"
          payload: '{"temperature": "", "humidity": ""}'
      - service: mqtt.publish
        data:
          topic: "zigbee2mqtt/th_meva/get"
          payload: '{"temperature": "", "humidity": ""}'
      - service: mqtt.publish
        data:
          topic: "zigbee2mqtt/th_axel/get"
          payload: '{"temperature": "", "humidity": ""}'
      - service: mqtt.publish
        data:
          topic: "zigbee2mqtt/th_parents/get"
          payload: '{"temperature": "", "humidity": ""}'
      - service: mqtt.publish
        data:
          topic: "zigbee2mqtt/th_terrasse/get"
          payload: '{"temperature": "", "humidity": ""}'
    mode: single
```

#### Recharger les Automations

```bash
# Via MCP
mcp call homeassistant call_service --service automation.reload

# Ou via interface: Outils de développement → YAML → Recharger Automations
```

---

## VALIDATION ET TESTS

### Script de Validation Automatique

#### Windows (PowerShell)

```powershell
# Définir le token Home Assistant
$env:HA_TOKEN = "VOTRE_TOKEN_LONGUE_DUREE"

# Lancer le monitoring pendant 30 minutes
.\validate_sensor_reporting.ps1 -DurationMinutes 30
```

#### Linux/WSL (Bash)

```bash
# Définir le mot de passe MQTT (optionnel)
export MQTT_PASSWORD="votre_mot_de_passe"

# Lancer le monitoring pendant 30 minutes
chmod +x validate_sensor_reporting.sh
./validate_sensor_reporting.sh 30
```

### Tests Manuels

#### Test 1: Vérifier une mise à jour rapide

```bash
# 1. Récupérer l'état actuel
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature

# 2. Forcer une mise à jour via MQTT
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/th_cuisine/get" \
  --payload '{"temperature": "", "humidity": ""}'

# 3. Attendre 10 secondes et vérifier à nouveau
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature

# 4. Comparer le champ "last_updated"
```

#### Test 2: Provoquer un changement de température

1. Souffler de l'air chaud sur le capteur
2. Attendre 1-3 minutes
3. Vérifier que la valeur a changé dans Home Assistant

#### Test 3: Analyser les logs en temps réel

```bash
# Suivre les logs Zigbee2MQTT
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --follow true

# Filtrer uniquement les updates de température
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/th_cuisine"
```

### Critères de Succès

| Critère | Valeur Cible | Résultat |
|---------|--------------|----------|
| Intervalle moyen | ≤ 3 minutes | ☐ |
| Taux de mise à jour | ≥ 20 updates/heure | ☐ |
| LQI moyen | ≥ 100 | ☐ |
| Batterie restante | ≥ 20% | ☐ |
| Aucune erreur dans les logs | Oui | ☐ |

---

## DÉPANNAGE

### Problème 1: "Device does not support reporting"

**Cause**: Le capteur a un firmware qui ignore les commandes de reconfiguration

**Solution**: Utiliser la Méthode 2 (Polling actif)

---

### Problème 2: Updates toujours lentes malgré la config

**Diagnostic**:

1. **Vérifier le LQI**:
   ```bash
   mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_linkquality
   ```

   Si LQI < 50 → Mauvaise connexion

2. **Vérifier la batterie**:
   ```bash
   mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_battery
   ```

   Si < 20% → Remplacer la pile

3. **Vérifier la topologie du réseau**:
   ```bash
   mcp call homeassistant mqtt_publish \
     --topic "zigbee2mqtt/bridge/request/networkmap" \
     --payload '{"type": "raw"}'
   ```

**Solutions**:

- **LQI faible**: Rapprocher le capteur d'un routeur mesh
- **Batterie faible**: Remplacer la pile
- **Pas de routeur à proximité**: Ajouter une prise mesh intermédiaire

---

### Problème 3: Automation de polling ne fonctionne pas

**Diagnostic**:

1. **Vérifier que l'automation est activée**:
   ```bash
   mcp call homeassistant get_entities --domain automation
   ```

2. **Tester manuellement une publication MQTT**:
   ```bash
   mcp call homeassistant mqtt_publish \
     --topic "zigbee2mqtt/th_cuisine/get" \
     --payload '{"temperature": "", "humidity": ""}'
   ```

3. **Vérifier les logs de l'automation**:
   Interface HA → Paramètres → Automations → Cliquer sur l'automation → Historique

**Solutions**:

- Recharger les automations: `automation.reload`
- Vérifier la syntaxe YAML
- S'assurer que MQTT est connecté

---

### Problème 4: Impact excessif sur la batterie

**Symptômes**:
- Batteries qui durent < 2 mois
- Capteurs qui passent en "unavailable" fréquemment

**Solutions**:

1. **Réduire la fréquence de polling**:
   - Passer de `/3` (toutes les 3 min) à `/5` (toutes les 5 min)

2. **Augmenter les intervalles de reporting**:
   ```yaml
   reporting:
     temperature:
       max_interval: 300  # 5 minutes au lieu de 3
   ```

3. **Utiliser des capteurs sur secteur**:
   - Sonoff SNZB-02P (USB)
   - Aqara Temperature Sensor T1 (USB)

---

### Problème 5: Certains capteurs ne répondent jamais

**Diagnostic**:

1. **Vérifier que le capteur est appairé**:
   ```bash
   mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/bridge/devices"
   ```

2. **Forcer un re-join du capteur**:
   - Activer permit join
   - Retirer et réinsérer la pile du capteur

3. **Vérifier s'il n'est pas trop éloigné**:
   - Distance max End Device → Router: ~10-15m en intérieur

**Solutions**:

- Ré-appairer le capteur
- Ajouter un routeur mesh intermédiaire
- Vérifier que la pile n'est pas morte (voltmètre: doit être > 2.8V pour CR2032)

---

## COMMANDES MCP DE RÉFÉRENCE

### Gestion des Add-ons

```bash
# Redémarrer Zigbee2MQTT
mcp call homeassistant restart_addon --addon core_zigbee2mqtt

# Consulter les logs
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 100

# Obtenir l'état de l'add-on
mcp call homeassistant get_addon_info --addon core_zigbee2mqtt
```

### Gestion MQTT

```bash
# Activer permit join
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/permit_join" \
  --payload '{"value": true, "time": 254}'

# Forcer une mise à jour d'un capteur
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/th_cuisine/get" \
  --payload '{"temperature": "", "humidity": ""}'

# Écouter les événements Zigbee
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/#"
```

### Gestion des Entités

```bash
# Lister tous les capteurs de température
mcp call homeassistant get_entities --domain sensor | grep temperature

# Obtenir l'état d'un capteur
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature

# Lister les entités unavailable
mcp call homeassistant get_entities --state unavailable
```

---

## CHECKLIST DE DÉPLOIEMENT

### Avant de Commencer

- [ ] Faire un backup complet de Home Assistant
- [ ] Noter les IEEE addresses de tous les capteurs
- [ ] Vérifier le niveau de batterie de chaque capteur (> 20%)
- [ ] Vérifier le LQI de chaque capteur (> 50)
- [ ] Créer un token d'accès longue durée pour l'API HA

### Déploiement Méthode 1 (Reconfiguration)

- [ ] Éditer `zigbee2mqtt_reporting_optimization.yaml` avec les vraies IEEE addresses
- [ ] Copier la section `device_options` dans `/config/zigbee2mqtt/configuration.yaml`
- [ ] Vérifier la syntaxe YAML (pas de tabulations)
- [ ] Redémarrer Zigbee2MQTT
- [ ] Vérifier les logs pour "Successfully configured reporting"
- [ ] Si échec → Passer à la Méthode 2

### Déploiement Méthode 2 (Polling)

- [ ] Créer l'automation de polling dans Home Assistant
- [ ] Recharger les automations
- [ ] Tester manuellement une publication MQTT
- [ ] Vérifier que l'automation se déclenche toutes les 3 minutes
- [ ] Ajuster l'intervalle si nécessaire (`/3` → `/5` par exemple)

### Validation

- [ ] Lancer le script de validation pendant 30 minutes
- [ ] Vérifier que l'intervalle moyen est ≤ 3 minutes
- [ ] Tester une automation de chauffage pour confirmer la réactivité
- [ ] Surveiller la batterie pendant 1 semaine
- [ ] Ajuster les paramètres si nécessaire

---

## ANNEXES

### A. Modèles de Capteurs Compatibles

| Fabricant | Modèle | Support Reporting | Recommandation |
|-----------|--------|-------------------|----------------|
| Sonoff | SNZB-02 | ⚠ Partiel | Utiliser Polling |
| Aqara | WSDCGQ11LM | ❌ Non | Utiliser Polling |
| Xiaomi | WSDCGQ01LM | ❌ Non | Utiliser Polling |
| Tuya | TS0201 | ✅ Oui | Reconfiguration OK |
| SmartThings | Multipurpose | ✅ Oui | Reconfiguration OK |

### B. Impact sur l'Autonomie

| Intervalle | Autonomie Estimée | Cas d'Usage |
|------------|-------------------|-------------|
| 1 minute | 2-3 mois | Très réactif (cuisine, salle de bain) |
| 3 minutes | 6-8 mois | Équilibré (chambres, salon) |
| 5 minutes | 10-12 mois | Économe (terrasse, garage) |
| 10 minutes | 18-24 mois | Maximum (pièces rarement utilisées) |

### C. Valeurs de Référence LQI

| LQI | Qualité | Action |
|-----|---------|--------|
| 200-255 | Excellente | Aucune |
| 100-199 | Bonne | Aucune |
| 50-99 | Acceptable | Surveiller |
| 20-49 | Faible | Rapprocher du routeur |
| 0-19 | Critique | Ajouter un routeur |

---

**Dernière mise à jour**: 2025-12-18
