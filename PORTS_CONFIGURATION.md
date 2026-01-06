# Configuration des Ports - Infrastructure Domotique

**Date de création**: 2025-12-18
**Dernière mise à jour**: 2025-12-18

---

## Vue d'ensemble

Ce document centralise tous les ports utilisés par l'infrastructure domotique pour éviter les conflits et faciliter le dépannage.

---

## Ports Utilisés

### Home Assistant Core

| Port | Service | Description | Accès |
|------|---------|-------------|-------|
| **8123** | Home Assistant Web UI | Interface web principale | http://homeassistant.local:8123 |
| **1883** | Mosquitto MQTT Broker | Broker MQTT pour les communications | mqtt://localhost:1883 |

**Notes**:
- Port 8123: Utilisé pour l'interface web, l'API REST et les WebSockets
- Port 1883: Port standard MQTT (non sécurisé, utilisé en local uniquement)
- Port 8883: MQTT sécurisé (TLS/SSL) - non utilisé actuellement

---

### Zigbee2MQTT

| Port | Service | Description | Accès |
|------|---------|-------------|-------|
| **8100** | Zigbee2MQTT Frontend | Interface web de gestion Zigbee | http://homeassistant.local:8100 ou http://192.168.0.166:8100 |
| **6638** | SLZB-MR1-MEZZA (TCP) | Coordinateur Zigbee via réseau | tcp://192.168.0.166:6638 |

**Notes**:
- Port 8100: CHANGÉ depuis 8099 pour éviter conflit avec HA Vibecode Agent
- Port 6638: Port TCP du coordinateur SLZB-MR1-MEZZA (Silicon Labs EZSP)
- Le coordinateur possède aussi une interface web sur http://192.168.0.166

**ATTENTION**: Ne pas confondre avec le port 8099 qui est maintenant utilisé par HA Vibecode Agent

---

### HA Vibecode Agent (MCP)

| Port | Service | Description | Accès |
|------|---------|-------------|-------|
| **8099** | HA Vibecode Agent | Serveur MCP pour intégration Claude | http://localhost:8099 |

**Notes**:
- Port 8099: Utilisé par l'agent MCP Home Assistant (Model Context Protocol)
- Ce service permet l'automatisation via Claude Code
- NE PAS confondre avec Zigbee2MQTT qui utilise maintenant le port 8100

---

## Historique des Changements

### 2025-12-18: Correction du conflit de port

**Problème**:
- Zigbee2MQTT et HA Vibecode Agent utilisaient tous deux le port 8099
- Conflit empêchant les deux services de fonctionner simultanément

**Solution**:
- Zigbee2MQTT déplacé du port 8099 → 8100
- HA Vibecode Agent conserve le port 8099
- Tous les fichiers de documentation mis à jour

**Fichiers modifiés**:
- `zigbee2mqtt_configuration.yaml`
- `ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md`
- `QUICK_START.md`
- `README_ZIGBEE_RECONSTRUCTION.md`
- `diagnostic_zigbee2mqtt.ps1`
- `diagnostic_zigbee2mqtt.sh`
- `MCP_COMMANDS_REFERENCE.md`
- `INDEX_DOCUMENTATION.md`

---

## Ports Réseau Externe

### Coordinateur SLZB-MR1-MEZZA

| Port | Service | Description | Accès |
|------|---------|-------------|-------|
| **80** | Interface Web | Configuration du coordinateur | http://192.168.0.166 |
| **6638** | TCP Server EZSP | Connexion Zigbee2MQTT | tcp://192.168.0.166:6638 |

**Notes**:
- Adresse IP: 192.168.0.166 (configurée en DHCP statique recommandé)
- Le coordinateur doit être accessible depuis le réseau local
- Port 6638: Port standard pour les coordinateurs Silicon Labs via réseau

---

## Vérification des Ports

### Commandes de diagnostic

#### Windows (PowerShell)
```powershell
# Vérifier les ports en écoute
Get-NetTCPConnection | Where-Object {$_.LocalPort -in @(8099, 8100, 8123, 1883, 6638)} | Select-Object LocalPort, State, OwningProcess

# Identifier le processus utilisant un port
Get-Process -Id (Get-NetTCPConnection -LocalPort 8100).OwningProcess
```

#### Linux/macOS (Bash)
```bash
# Vérifier les ports en écoute
netstat -tulpn | grep -E ':(8099|8100|8123|1883|6638)'

# Ou avec ss
ss -tulpn | grep -E ':(8099|8100|8123|1883|6638)'

# Ou avec lsof
lsof -i :8100
```

#### Test de connectivité réseau

```bash
# Test TCP avec netcat
nc -zv localhost 8100  # Zigbee2MQTT
nc -zv localhost 8099  # HA Vibecode Agent
nc -zv localhost 8123  # Home Assistant
nc -zv localhost 1883  # MQTT

# Test coordinateur
nc -zv 192.168.0.166 6638
nc -zv 192.168.0.166 80
```

---

## Plan d'Attribution des Ports

### Ports réservés

| Plage | Usage | Réservés pour |
|-------|-------|---------------|
| **8000-8099** | Services Core | Home Assistant, MCP, API |
| **8100-8199** | Add-ons UI | Zigbee2MQTT, Node-RED, etc. |
| **1883, 8883** | MQTT | Mosquitto Broker |
| **6638** | Coordinateurs | Zigbee via TCP |

### Ports disponibles pour futurs services

| Port | Statut | Suggestion d'usage |
|------|--------|-------------------|
| 8101 | Libre | Node-RED UI |
| 8102 | Libre | ESPHome Dashboard |
| 8103 | Libre | VSCode Server |
| 8200-8299 | Libre | Services personnalisés |

---

## Résolution de Conflits de Ports

### Symptômes d'un conflit

- Service ne démarre pas
- Erreur "Address already in use" dans les logs
- Timeout lors de la connexion
- Comportement erratique des services

### Procédure de diagnostic

1. **Identifier le port en conflit**:
   ```bash
   # Windows
   netstat -ano | findstr :8100

   # Linux/macOS
   lsof -i :8100
   ```

2. **Identifier le processus**:
   ```bash
   # Windows
   tasklist /FI "PID eq XXXX"

   # Linux/macOS
   ps aux | grep XXXX
   ```

3. **Décider de l'action**:
   - Arrêter le processus conflictuel
   - Changer le port du nouveau service
   - Documenter le changement

4. **Mettre à jour la documentation**:
   - Ce fichier (`PORTS_CONFIGURATION.md`)
   - Fichiers de configuration concernés
   - Documentations associées

---

## Checklist de Vérification

Avant d'ajouter un nouveau service:

- [ ] Vérifier que le port n'est pas déjà utilisé
- [ ] Consulter ce document pour les ports réservés
- [ ] Tester la connectivité après configuration
- [ ] Mettre à jour ce document
- [ ] Mettre à jour les scripts de diagnostic
- [ ] Documenter dans les guides utilisateurs

---

## Firewall et Sécurité

### Ports devant être accessibles en local uniquement

- **1883** (MQTT) - Communication interne uniquement
- **8099** (HA Vibecode Agent) - Localhost uniquement
- **8100** (Zigbee2MQTT) - Local ou VPN uniquement
- **8123** (Home Assistant) - À exposer avec précautions

### Ports pouvant être exposés (avec précautions)

- **8123** (Home Assistant) - Via reverse proxy avec HTTPS recommandé
- Utiliser Nginx Proxy Manager ou Caddy
- Activer l'authentification forte (2FA)
- Utiliser des certificats SSL/TLS valides

### Recommandations de sécurité

1. **Ne JAMAIS exposer directement**:
   - Port 1883 (MQTT non sécurisé)
   - Port 8099 (MCP Agent)
   - Port 6638 (Coordinateur Zigbee)

2. **Utiliser un VPN** pour l'accès distant:
   - WireGuard recommandé
   - OpenVPN comme alternative
   - Éviter l'exposition directe sur Internet

3. **Surveiller les logs** pour détecter:
   - Tentatives de connexion suspectes
   - Scans de ports
   - Authentifications échouées

---

## Références

### Documentation officielle

- **Home Assistant Ports**: https://www.home-assistant.io/docs/configuration/securing/
- **Zigbee2MQTT Configuration**: https://www.zigbee2mqtt.io/guide/configuration/
- **Mosquitto MQTT**: https://mosquitto.org/documentation/
- **SLZB-MR1-MEZZA**: https://smlight.tech/manual/slzb-06/

### Fichiers de configuration

- Home Assistant: `/config/configuration.yaml`
- Zigbee2MQTT: `/config/zigbee2mqtt/configuration.yaml` ou via add-on UI
- Mosquitto: Configuration via add-on Home Assistant

---

## Tableau Récapitulatif Complet

| Port | Service | Type | Accès | Sécurité | Statut |
|------|---------|------|-------|----------|--------|
| 80 | Coordinateur Web | HTTP | LAN | Interne | Actif |
| 1883 | Mosquitto MQTT | MQTT | Local | Interne | Actif |
| 6638 | Coordinateur TCP | TCP | LAN | Interne | Actif |
| 8099 | HA Vibecode Agent | HTTP | Localhost | MCP | Actif |
| 8100 | Zigbee2MQTT UI | HTTP | LAN | Authentification | Actif |
| 8123 | Home Assistant | HTTP | LAN/Internet | 2FA Recommandé | Actif |
| 8883 | MQTT TLS | MQTTS | - | - | Inactif |

---

## Contact et Maintenance

**Responsable**: À définir
**Fréquence de révision**: Chaque ajout/modification de service
**Prochaine révision**: Après ajout d'un nouveau service

---

**Version**: 1.0
**Créé le**: 2025-12-18
**Dernière modification**: 2025-12-18
