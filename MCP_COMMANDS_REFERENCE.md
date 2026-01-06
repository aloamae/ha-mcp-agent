# Référence des Commandes MCP Home Assistant

**Date**: 2025-12-18
**Serveur MCP**: Home Assistant Integration

---

## CONFIGURATION DU SERVEUR MCP

### Prérequis

1. **Serveur MCP Home Assistant installé** :
   ```bash
   npm install -g @modelcontextprotocol/homeassistant
   ```

2. **Configuration dans mcp.json** :
   ```json
   {
     "servers": {
       "homeassistant": {
         "type": "stdio",
         "command": "node",
         "args": ["path/to/homeassistant/build/index.js"],
         "env": {
           "HASS_URL": "http://homeassistant.local:8123",
           "HASS_TOKEN": "YOUR_LONG_LIVED_ACCESS_TOKEN"
         }
       }
     }
   }
   ```

3. **Générer un token d'accès longue durée** :
   - Home Assistant → Profil utilisateur (en bas à gauche)
   - Onglet "Sécurité"
   - Section "Jetons d'accès longue durée"
   - Cliquer sur "Créer un jeton"
   - Nommer : "MCP Home Assistant"
   - Copier le token (ne sera plus affiché)

### Tester la connexion MCP

```bash
# Via l'inspecteur MCP
npx @modelcontextprotocol/inspector --server homeassistant

# Ou directement dans Claude Code
# Le serveur MCP devrait apparaître automatiquement si configuré
```

---

## COMMANDES MCP POUR ZIGBEE2MQTT

### 1. Gestion des Add-ons

#### Lister tous les add-ons installés

**Commande MCP** :
```
mcp call homeassistant list_addons
```

**Résultat attendu** :
```json
{
  "addons": [
    {
      "name": "Mosquitto broker",
      "slug": "core_mosquitto",
      "state": "started",
      "version": "6.4.0"
    },
    {
      "name": "Zigbee2MQTT",
      "slug": "core_zigbee2mqtt",
      "state": "started",
      "version": "1.35.0"
    }
  ]
}
```

#### Obtenir les détails d'un add-on

**Commande MCP** :
```
mcp call homeassistant get_addon_info --addon core_zigbee2mqtt
```

**Résultat attendu** :
```json
{
  "name": "Zigbee2MQTT",
  "slug": "core_zigbee2mqtt",
  "state": "started",
  "version": "1.35.0",
  "auto_update": true,
  "boot": "auto",
  "network": {
    "8100/tcp": 8100
  },
  "options": {
    "mqtt": {
      "server": "mqtt://localhost:1883"
    }
  }
}
```

#### Démarrer un add-on

**Commande MCP** :
```
mcp call homeassistant start_addon --addon core_zigbee2mqtt
```

#### Arrêter un add-on

**Commande MCP** :
```
mcp call homeassistant stop_addon --addon core_zigbee2mqtt
```

#### Redémarrer un add-on

**Commande MCP** :
```
mcp call homeassistant restart_addon --addon core_zigbee2mqtt
```

**Utilisation recommandée** :
- Après modification de la configuration Zigbee2MQTT
- Pour appliquer les changements de canal ou de paramètres réseau

#### Obtenir les logs d'un add-on

**Commande MCP** :
```
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt
```

**Résultat attendu** :
```
[2025-12-18 10:15:23] INFO: Starting Zigbee2MQTT...
[2025-12-18 10:15:24] INFO: MQTT connected
[2025-12-18 10:15:25] INFO: Coordinator firmware version: 6.10.3.0
[2025-12-18 10:15:26] INFO: Zigbee2MQTT started!
```

**Options utiles** :
```
# Dernières 50 lignes
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 50

# Suivre les logs en temps réel (si supporté)
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --follow true
```

---

### 2. Gestion des Entités

#### Lister toutes les entités

**Commande MCP** :
```
mcp call homeassistant get_entities
```

**Résultat attendu** :
```json
{
  "entities": [
    {
      "entity_id": "switch.prise_mesh_salon",
      "state": "on",
      "attributes": {
        "friendly_name": "Prise Mesh Salon"
      }
    },
    {
      "entity_id": "sensor.th_cuisine_temperature",
      "state": "22.5",
      "attributes": {
        "unit_of_measurement": "°C",
        "friendly_name": "Cuisine Température"
      }
    }
  ]
}
```

#### Filtrer les entités par domaine

**Commande MCP** :
```
# Lister uniquement les switches (prises)
mcp call homeassistant get_entities --domain switch

# Lister uniquement les sensors (capteurs)
mcp call homeassistant get_entities --domain sensor

# Lister les entités MQTT
mcp call homeassistant get_entities --integration mqtt
```

#### Lister les entités unavailable

**Commande MCP** :
```
mcp call homeassistant get_entities --state unavailable
```

**Utilisation** :
- Identifier les entités orphelines après restauration
- Nettoyer les anciennes entités Zigbee

#### Obtenir l'état d'une entité

**Commande MCP** :
```
mcp call homeassistant get_entity_state --entity_id switch.prise_mesh_salon
```

**Résultat attendu** :
```json
{
  "entity_id": "switch.prise_mesh_salon",
  "state": "on",
  "attributes": {
    "friendly_name": "Prise Mesh Salon",
    "linkquality": 255,
    "power": 0,
    "current": 0.0,
    "voltage": 230
  },
  "last_changed": "2025-12-18T10:30:00+00:00",
  "last_updated": "2025-12-18T10:30:00+00:00"
}
```

#### Contrôler une entité

**Commande MCP** :
```
# Allumer une prise
mcp call homeassistant turn_on --entity_id switch.prise_mesh_salon

# Éteindre une prise
mcp call homeassistant turn_off --entity_id switch.prise_mesh_salon

# Basculer l'état (toggle)
mcp call homeassistant toggle --entity_id switch.prise_mesh_salon
```

#### Supprimer une entité

**Commande MCP** :
```
mcp call homeassistant remove_entity --entity_id switch.prise_mesh_salon_old
```

**ATTENTION** :
- Cette action est irréversible
- Utiliser uniquement pour les entités orphelines
- Les nouvelles entités Zigbee seront recréées automatiquement lors de l'appairage

---

### 3. Appels de Services

#### Recharger les configurations

**Commande MCP** :
```
# Recharger les automations
mcp call homeassistant call_service --service automation.reload

# Recharger les scripts
mcp call homeassistant call_service --service script.reload

# Recharger les helpers (input_*)
mcp call homeassistant call_service --service input_boolean.reload
mcp call homeassistant call_service --service input_number.reload
mcp call homeassistant call_service --service input_select.reload
```

#### Redémarrer Home Assistant

**Commande MCP** :
```
mcp call homeassistant call_service --service homeassistant.restart
```

**ATTENTION** : Déconnectera tous les clients pendant 1-2 minutes

#### Vérifier la configuration

**Commande MCP** :
```
mcp call homeassistant call_service --service homeassistant.check_config
```

**Utilisation** :
- Avant de redémarrer Home Assistant
- Après modification de configuration.yaml

---

### 4. Opérations MQTT (via Zigbee2MQTT)

#### Publier un message MQTT

**Commande MCP** :
```
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/permit_join" \
  --payload '{"value": true}'
```

**Exemples utiles** :

##### Activer le mode appairage (permit join)
```
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/permit_join" \
  --payload '{"value": true, "time": 254}'
```

##### Désactiver le mode appairage
```
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/permit_join" \
  --payload '{"value": false}'
```

##### Renommer un appareil Zigbee
```
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/device/rename" \
  --payload '{"from": "0xaabbccddeeff0011", "to": "th_cuisine"}'
```

##### Retirer un appareil Zigbee
```
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/device/remove" \
  --payload '{"id": "th_cuisine"}'
```

##### Forcer suppression d'un appareil offline
```
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/device/remove" \
  --payload '{"id": "th_cuisine", "force": true}'
```

##### Obtenir la liste des appareils Zigbee
```
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/devices" \
  --payload '{}'
```

##### Redémarrer Zigbee2MQTT via MQTT
```
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/restart" \
  --payload '{}'
```

#### S'abonner à un topic MQTT (écouter)

**Commande MCP** :
```
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/#"
```

**Exemples utiles** :

##### Écouter tous les événements Zigbee2MQTT
```
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/#"
```

##### Écouter uniquement les logs du bridge
```
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/bridge/log"
```

##### Écouter un appareil spécifique
```
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/th_cuisine"
```

---

## WORKFLOWS MCP POUR LA RECONSTRUCTION ZIGBEE

### Workflow 1 : Diagnostic complet

```bash
# 1. Vérifier l'état de Zigbee2MQTT
mcp call homeassistant get_addon_info --addon core_zigbee2mqtt

# 2. Consulter les logs récents
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 50

# 3. Lister les entités unavailable
mcp call homeassistant get_entities --state unavailable

# 4. Vérifier l'état de Mosquitto
mcp call homeassistant get_addon_info --addon core_mosquitto
```

### Workflow 2 : Activer le mode appairage

```bash
# 1. S'assurer que Z2M est démarré
mcp call homeassistant get_addon_info --addon core_zigbee2mqtt

# 2. Activer permit join via MQTT
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/permit_join" \
  --payload '{"value": true, "time": 254}'

# 3. Écouter les événements d'appairage
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/bridge/event"
```

### Workflow 3 : Nettoyage des entités orphelines

```bash
# 1. Lister toutes les entités MQTT unavailable
mcp call homeassistant get_entities --integration mqtt --state unavailable

# 2. Pour chaque entité identifiée comme obsolète :
mcp call homeassistant remove_entity --entity_id switch.prise_mesh_salon_old

# 3. Vérifier qu'il ne reste aucune entité unavailable
mcp call homeassistant get_entities --state unavailable
```

### Workflow 4 : Validation post-reconstruction

```bash
# 1. Vérifier que Z2M est Online
mcp call homeassistant get_addon_info --addon core_zigbee2mqtt

# 2. Lister toutes les entités switch (routeurs)
mcp call homeassistant get_entities --domain switch

# 3. Lister toutes les entités sensor (capteurs T/H)
mcp call homeassistant get_entities --domain sensor

# 4. Tester ON/OFF des routeurs
mcp call homeassistant toggle --entity_id switch.prise_mesh_salon
mcp call homeassistant get_entity_state --entity_id switch.prise_mesh_salon

# 5. Vérifier les données des capteurs
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_humidity

# 6. Désactiver le mode appairage
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/permit_join" \
  --payload '{"value": false}'
```

---

## TOPICS MQTT ZIGBEE2MQTT

### Topics de contrôle (bridge)

| Topic | Description | Payload |
|-------|-------------|---------|
| `zigbee2mqtt/bridge/request/permit_join` | Activer/désactiver l'appairage | `{"value": true/false, "time": 254}` |
| `zigbee2mqtt/bridge/request/restart` | Redémarrer Z2M | `{}` |
| `zigbee2mqtt/bridge/request/devices` | Liste des appareils | `{}` |
| `zigbee2mqtt/bridge/request/device/remove` | Retirer un appareil | `{"id": "nom_appareil"}` |
| `zigbee2mqtt/bridge/request/device/rename` | Renommer un appareil | `{"from": "ancien", "to": "nouveau"}` |
| `zigbee2mqtt/bridge/request/options` | Modifier la config | `{"options": {...}}` |

### Topics de données (appareils)

| Topic | Description |
|-------|-------------|
| `zigbee2mqtt/NOM_APPAREIL` | État de l'appareil |
| `zigbee2mqtt/NOM_APPAREIL/set` | Commande à envoyer |
| `zigbee2mqtt/NOM_APPAREIL/get` | Demander une mise à jour |

### Topics d'événements

| Topic | Description |
|-------|-------------|
| `zigbee2mqtt/bridge/event` | Événements (appairage, erreurs) |
| `zigbee2mqtt/bridge/log` | Logs du bridge |
| `zigbee2mqtt/bridge/state` | État du bridge (online/offline) |
| `zigbee2mqtt/bridge/info` | Informations système |

---

## EXEMPLES DE PAYLOADS MQTT

### Contrôler une prise (switch)

```json
// Allumer
Topic: zigbee2mqtt/Prise_Mesh_Salon/set
Payload: {"state": "ON"}

// Éteindre
Topic: zigbee2mqtt/Prise_Mesh_Salon/set
Payload: {"state": "OFF"}

// Basculer
Topic: zigbee2mqtt/Prise_Mesh_Salon/set
Payload: {"state": "TOGGLE"}
```

### Forcer une mise à jour d'un capteur

```json
Topic: zigbee2mqtt/th_cuisine/get
Payload: {"temperature": "", "humidity": ""}
```

### Obtenir la carte du réseau

```json
Topic: zigbee2mqtt/bridge/request/networkmap
Payload: {"type": "raw"}
```

### Modifier la configuration Zigbee2MQTT

```json
Topic: zigbee2mqtt/bridge/request/options
Payload: {
  "options": {
    "permit_join": false,
    "advanced": {
      "log_level": "debug"
    }
  }
}
```

---

## SCRIPTS AUTOMATISÉS

### Script Bash : Activer appairage et surveiller

```bash
#!/bin/bash

echo "Activation du mode appairage Zigbee2MQTT..."

# Activer permit join
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/permit_join" \
  --payload '{"value": true, "time": 254}'

echo "Mode appairage activé pour 254 secondes (4 min)"
echo "Surveillance des événements..."

# Écouter les événements (Ctrl+C pour arrêter)
mcp call homeassistant mqtt_subscribe --topic "zigbee2mqtt/bridge/event"
```

### Script Bash : Nettoyer toutes les entités unavailable

```bash
#!/bin/bash

echo "Recherche des entités unavailable..."

# Obtenir la liste des entités unavailable (JSON)
unavailable=$(mcp call homeassistant get_entities --state unavailable)

# Extraire les entity_id et supprimer (nécessite jq)
echo "$unavailable" | jq -r '.entities[].entity_id' | while read entity; do
  echo "Suppression de : $entity"
  mcp call homeassistant remove_entity --entity_id "$entity"
done

echo "Nettoyage terminé."
```

---

## DÉPANNAGE MCP

### Erreur : "Server homeassistant not found"

**Solution** :
1. Vérifier que le serveur est configuré dans mcp.json
2. Redémarrer Claude Code
3. Tester avec l'inspecteur MCP :
   ```bash
   npx @modelcontextprotocol/inspector --server homeassistant
   ```

### Erreur : "Unauthorized" ou "401"

**Solution** :
1. Vérifier le token d'accès longue durée dans mcp.json
2. Régénérer un nouveau token dans Home Assistant
3. Mettre à jour la variable d'environnement HASS_TOKEN

### Erreur : "Connection refused"

**Solution** :
1. Vérifier que Home Assistant est accessible : http://homeassistant.local:8123
2. Vérifier la variable HASS_URL dans mcp.json
3. Tester avec curl :
   ```bash
   curl http://homeassistant.local:8123/api/
   ```

---

## RÉFÉRENCES

- **Documentation MCP Home Assistant** : https://github.com/modelcontextprotocol/servers/tree/main/homeassistant
- **API Home Assistant** : https://developers.home-assistant.io/docs/api/rest/
- **MQTT Zigbee2MQTT** : https://www.zigbee2mqtt.io/guide/usage/mqtt_topics_and_messages.html

---

**Document créé le : 2025-12-18**
**Dernière mise à jour : 2025-12-18**
