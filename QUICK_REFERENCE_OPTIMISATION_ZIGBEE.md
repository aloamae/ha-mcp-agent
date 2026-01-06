# Quick Reference - Optimisation Reporting Zigbee

**Date**: 2025-12-18

---

## DIAGNOSTIC RAPIDE

### Commandes MCP Essentielles

```bash
# État d'un capteur
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature

# Logs Zigbee2MQTT (100 dernières lignes)
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 100

# Liste des appareils Zigbee
mcp call homeassistant mqtt_publish --topic "zigbee2mqtt/bridge/request/devices" --payload '{}'

# Écouter les updates en temps réel
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/th_cuisine"
```

### Indicateurs de Santé

| Indicateur | Valeur OK | Action si KO |
|------------|-----------|--------------|
| **LQI** | > 100 | Rapprocher routeur |
| **Batterie** | > 20% | Remplacer pile |
| **Intervalle** | < 3 min | Appliquer config |
| **Last Seen** | < 5 min | Vérifier réseau |

---

## 2 MÉTHODES D'OPTIMISATION

### Méthode 1: Reconfiguration Reporting (Recommandée en premier)

**Avantages**: Réactivité maximale, automatique
**Inconvénient**: Ne fonctionne pas avec tous les capteurs

#### Étapes Rapides

1. **Identifier IEEE addresses** (Interface Zigbee2MQTT → Devices)
2. **Éditer config**: Copier `device_options` depuis `zigbee2mqtt_reporting_optimization.yaml`
3. **Remplacer addresses**: `0x0000000000000003` → `0xVOTRE_ADRESSE_REELLE`
4. **Redémarrer Z2M**:
   ```bash
   mcp call homeassistant restart_addon --addon core_zigbee2mqtt
   ```
5. **Vérifier logs**: Chercher "Successfully configured reporting"

#### Si Échec

Logs montrent "Device does not support reporting" → Passer à Méthode 2

---

### Méthode 2: Polling Actif (Solution Universelle)

**Avantages**: Fonctionne avec TOUS les capteurs
**Inconvénient**: Automation à maintenir

#### Configuration Rapide

**Copier cette automation dans Home Assistant**:

```yaml
automation:
  - alias: "Zigbee - Polling capteurs T/H (3 min)"
    trigger:
      - platform: time_pattern
        minutes: "/3"
    action:
      - service: mqtt.publish
        data:
          topic: "zigbee2mqtt/th_cuisine/get"
          payload: '{"temperature": "", "humidity": ""}'
      # Répéter pour chaque capteur
    mode: single
```

**Activer**:
```bash
mcp call homeassistant call_service --service automation.reload
```

---

## VALIDATION RAPIDE

### Test Manuel (30 secondes)

```bash
# 1. État actuel
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature

# 2. Forcer update
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/th_cuisine/get" \
  --payload '{"temperature": "", "humidity": ""}'

# 3. Vérifier à nouveau (attendre 10s)
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature
```

### Script Automatique (30 minutes)

```powershell
# Windows
$env:HA_TOKEN = "VOTRE_TOKEN"
.\validate_sensor_reporting.ps1 -DurationMinutes 30

# Linux/WSL
export MQTT_PASSWORD="votre_mdp"
./validate_sensor_reporting.sh 30
```

---

## DÉPANNAGE EXPRESS

### Problème: Updates toujours lentes

```bash
# 1. Vérifier LQI
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_linkquality

# Si LQI < 50:
# → Rapprocher capteur d'un routeur mesh
# → Ajouter une prise mesh intermédiaire

# 2. Vérifier batterie
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_battery

# Si < 20%:
# → Remplacer pile immédiatement
```

### Problème: Polling ne fonctionne pas

```bash
# 1. Tester manuellement MQTT
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/th_cuisine/get" \
  --payload '{"temperature": "", "humidity": ""}'

# 2. Vérifier automation
mcp call homeassistant get_entities --domain automation

# 3. Recharger automations
mcp call homeassistant call_service --service automation.reload
```

---

## CONFIGURATION OPTIMALE

### Capteurs Intérieurs (Chambres, Salon, Cuisine)

```yaml
reporting:
  temperature:
    min_interval: 60      # 1 min
    max_interval: 180     # 3 min
    min_change: 0.3       # 0.3°C
  humidity:
    min_interval: 60
    max_interval: 180
    min_change: 3         # 3%
```

**Impact batterie**: 6-8 mois d'autonomie

### Capteur Extérieur (Terrasse)

```yaml
reporting:
  temperature:
    min_interval: 60
    max_interval: 300     # 5 min (variations plus rapides)
    min_change: 0.5       # 0.5°C (tolérance plus large)
  humidity:
    min_interval: 60
    max_interval: 300
    min_change: 5         # 5%
```

**Impact batterie**: 10-12 mois d'autonomie

---

## COMMANDES PRATIQUES

### Activer Mode Appairage

```bash
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/permit_join" \
  --payload '{"value": true, "time": 254}'
```

### Carte Réseau Zigbee

```bash
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/networkmap" \
  --payload '{"type": "raw"}'
```

### Forcer Update Tous les Capteurs

```bash
for sensor in th_cuisine th_salon th_loann th_meva th_axel th_parents th_terrasse; do
  mcp call homeassistant mqtt_publish \
    --topic "zigbee2mqtt/$sensor/get" \
    --payload '{"temperature": "", "humidity": ""}'
done
```

---

## CHECKLIST DE DÉPLOIEMENT

### Avant

- [ ] Backup Home Assistant
- [ ] Noter IEEE addresses (Interface Z2M)
- [ ] Vérifier batterie > 20%
- [ ] Vérifier LQI > 50

### Déploiement

- [ ] Choisir méthode (1: Reconfiguration, 2: Polling)
- [ ] Appliquer configuration
- [ ] Redémarrer Z2M ou recharger automations
- [ ] Vérifier logs

### Validation

- [ ] Lancer script validation 30 min
- [ ] Intervalle moyen < 3 min
- [ ] Tester automation chauffage
- [ ] Surveiller batterie 1 semaine

---

## FICHIERS DE RÉFÉRENCE

| Fichier | Description |
|---------|-------------|
| `zigbee2mqtt_reporting_optimization.yaml` | Configuration device_options complète |
| `validate_sensor_reporting.ps1` | Script validation Windows |
| `validate_sensor_reporting.sh` | Script validation Linux |
| `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` | Documentation complète |

---

## SUPPORT

### Logs Zigbee2MQTT

```bash
# Temps réel
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --follow true

# Filtrer température/humidité
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/#" | grep -E "temperature|humidity"
```

### Interface Zigbee2MQTT

- URL: http://192.168.0.166:8100
- Onglet "Map": Visualiser le réseau
- Onglet "Devices": Gérer les appareils
- Onglet "Settings": Configuration

---

**Dernière mise à jour**: 2025-12-18
**Version**: 1.0
