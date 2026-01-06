# Documentation Complète : Reconstruction du Réseau Zigbee2MQTT

**Date de création** : 2025-12-18
**Version** : 1.0
**Statut** : Prêt pour exécution

---

## Vue d'ensemble

Cette documentation fournit un guide complet pour reconstruire un réseau Zigbee2MQTT après une restauration de Home Assistant qui a fait tomber tous les appareils Zigbee.

### Contexte

- **Avant restauration** : Zigbee2MQTT configuré avec 2 routeurs mesh + 7 capteurs
- **Après restauration** : Tout le réseau Zigbee est tombé
- **Coordinateur** : SLZB-MR1-MEZZA (opérationnel sur 192.168.0.166:6638)
- **Broker MQTT** : Mosquitto installé et fonctionnel

### Appareils à réassocier

**Routeurs mesh (priorité absolue)** :
1. Prise_Mesh_Salon
2. Prise_Mesh_Cuisine

**Capteurs température/humidité** :
1. th_cuisine
2. th_salon
3. th_loann
4. th_meva
5. th_axel
6. th_parents
7. th_terrasse

---

## Structure de la documentation

### 1. ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md

**Fichier principal** contenant :
- Vérification de l'installation Zigbee2MQTT
- Guide d'installation si nécessaire
- Configuration complète pour SLZB-MR1-MEZZA
- Plan de réassociation détaillé avec timing
- Procédures de validation
- Résolution de problèmes courants
- Timeline estimée (1h15)

**Utilisation** :
- Commencer par ce guide
- Suivre les étapes dans l'ordre
- Référencer les autres documents au besoin

**Chemin** : `c:\DATAS\AI\Projets\Perso\Domotique\ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md`

---

### 2. CHECKLIST_REASSOCIATION.md

**Checklist imprimable** pour suivre la progression :
- Cases à cocher pour chaque étape
- Espaces pour horodatage
- Section notes et observations
- Validation finale avec durée totale

**Utilisation** :
- Imprimer ou afficher sur second écran
- Cocher au fur et à mesure
- Documenter les problèmes rencontrés
- Garder comme trace de la procédure

**Chemin** : `c:\DATAS\AI\Projets\Perso\Domotique\CHECKLIST_REASSOCIATION.md`

---

### 3. RESET_PROCEDURES.md

**Référence technique** pour reset/appairage :
- Procédures génériques par type d'appareil
- Procédures spécifiques par marque
- Diagnostic des problèmes d'appairage
- Commandes utiles Zigbee2MQTT
- Informations techniques (canaux, LQI, etc.)

**Utilisation** :
- Consulter lors du reset d'un appareil
- Identifier la procédure selon la marque
- Dépannage si l'appairage échoue

**Chemin** : `c:\DATAS\AI\Projets\Perso\Domotique\RESET_PROCEDURES.md`

---

### 4. zigbee2mqtt_configuration.yaml

**Configuration complète** prête à l'emploi :
- Optimisée pour SLZB-MR1-MEZZA (adaptateur EZSP)
- Connexion TCP au coordinateur
- Intégration MQTT Mosquitto
- Intégration Home Assistant
- Paramètres réseau recommandés
- Interface Web activée

**Utilisation** :
- Copier dans l'onglet Configuration de l'add-on Zigbee2MQTT
- Adapter les secrets (mqtt_password)
- Sauvegarder et démarrer l'add-on

**Chemin** : `c:\DATAS\AI\Projets\Perso\Domotique\zigbee2mqtt_configuration.yaml`

---

### 5. secrets_template.yaml

**Template pour les secrets** :
- Mot de passe MQTT
- Token d'authentification Zigbee2MQTT
- Exemples de génération de tokens sécurisés

**Utilisation** :
- Copier dans `/config/secrets.yaml` de Home Assistant
- Remplacer les valeurs par les vraies
- Ne jamais committer ce fichier

**Chemin** : `c:\DATAS\AI\Projets\Perso\Domotique\secrets_template.yaml`

---

### 6. diagnostic_zigbee2mqtt.sh

**Script de diagnostic** pour Linux/macOS :
- Vérification de la connectivité du coordinateur
- État de Home Assistant
- État de Mosquitto MQTT
- État de Zigbee2MQTT
- Validation de la configuration
- Affichage des logs récents
- Résumé avec recommandations

**Utilisation** :
```bash
chmod +x diagnostic_zigbee2mqtt.sh
./diagnostic_zigbee2mqtt.sh
```

**Chemin** : `c:\DATAS\AI\Projets\Perso\Domotique\diagnostic_zigbee2mqtt.sh`

---

### 7. diagnostic_zigbee2mqtt.ps1

**Script de diagnostic** pour Windows :
- Même fonctionnalités que la version Bash
- Adapté pour PowerShell
- Affichage coloré des résultats
- Tests de connectivité réseau

**Utilisation** :
```powershell
.\diagnostic_zigbee2mqtt.ps1
```

**Chemin** : `c:\DATAS\AI\Projets\Perso\Domotique\diagnostic_zigbee2mqtt.ps1`

---

### 8. MCP_COMMANDS_REFERENCE.md

**Référence des commandes MCP** Home Assistant :
- Configuration du serveur MCP
- Commandes de gestion des add-ons
- Commandes de gestion des entités
- Opérations MQTT via MCP
- Workflows complets pour la reconstruction
- Topics MQTT Zigbee2MQTT
- Scripts automatisés

**Utilisation** :
- Si le serveur MCP Home Assistant est configuré
- Automatisation des tâches répétitives
- Diagnostic via CLI
- Nettoyage d'entités en masse

**Chemin** : `c:\DATAS\AI\Projets\Perso\Domotique\MCP_COMMANDS_REFERENCE.md`

---

## Flux de travail recommandé

### Étape 1 : Diagnostic initial

```
1. Exécuter le script de diagnostic (Bash ou PowerShell)
2. Identifier les problèmes éventuels
3. Corriger avant de continuer
```

**Scripts** :
- `diagnostic_zigbee2mqtt.sh` (Linux/macOS)
- `diagnostic_zigbee2mqtt.ps1` (Windows)

---

### Étape 2 : Installation/Configuration Zigbee2MQTT

```
1. Ouvrir ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md
2. Suivre les ÉTAPES 1-3
3. Appliquer zigbee2mqtt_configuration.yaml
4. Configurer secrets_template.yaml
5. Démarrer Zigbee2MQTT
```

**Documents** :
- `ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md` (Étapes 1-3)
- `zigbee2mqtt_configuration.yaml`
- `secrets_template.yaml`

---

### Étape 3 : Réassociation des appareils

```
1. Ouvrir CHECKLIST_REASSOCIATION.md (second écran ou imprimée)
2. Avoir RESET_PROCEDURES.md accessible
3. PHASE 1 : Réassocier les 2 routeurs mesh
   - Attendre stabilisation (5-10 min)
4. PHASE 2 : Réassocier les 7 capteurs
   - 30s entre chaque
```

**Documents** :
- `CHECKLIST_REASSOCIATION.md` (suivi)
- `RESET_PROCEDURES.md` (référence technique)
- `ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md` (Étapes 5-6)

---

### Étape 4 : Nettoyage et validation

```
1. Désactiver le mode appairage (permit_join: false)
2. Nettoyer les entités orphelines MQTT
3. Valider le réseau mesh (Map dans Z2M)
4. Tester tous les appareils
5. Créer une sauvegarde complète
```

**Documents** :
- `ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md` (Étapes 6-7)
- `CHECKLIST_REASSOCIATION.md` (phases 3-5)
- `MCP_COMMANDS_REFERENCE.md` (si MCP configuré)

---

## Commandes rapides

### Accéder aux interfaces Web

```bash
# Coordinateur SLZB-MR1-MEZZA
http://192.168.0.166

# Home Assistant
http://homeassistant.local:8123

# Zigbee2MQTT Frontend (Port 8100 - le 8099 est utilisé par HA Vibecode Agent)
http://homeassistant.local:8100
```

### Vérifier l'état des services (CLI Home Assistant)

```bash
# État de Zigbee2MQTT
ha addons info core_zigbee2mqtt

# Logs de Zigbee2MQTT
ha addons logs core_zigbee2mqtt

# Redémarrer Zigbee2MQTT
ha addons restart core_zigbee2mqtt
```

### Activer le mode appairage

**Via l'interface Web Z2M** :
```
http://homeassistant.local:8100
Cliquer sur "Permit Join (All)"
```

**Via MQTT** (si mosquitto_pub installé) :
```bash
mosquitto_pub -h localhost -t 'zigbee2mqtt/bridge/request/permit_join' \
  -m '{"value": true}' -u homeassistant -P VOTRE_MOT_DE_PASSE
```

**Via MCP** (si serveur configuré) :
```bash
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/bridge/request/permit_join" \
  --payload '{"value": true, "time": 254}'
```

---

## Timeline estimée

| Étape | Durée | Cumul |
|-------|-------|-------|
| **Diagnostic initial** | 5 min | 5 min |
| **Installation Z2M** (si nécessaire) | 10 min | 15 min |
| **Configuration Z2M** | 5 min | 20 min |
| **Démarrage et validation** | 5 min | 25 min |
| **Routeur 1 + attente** | 5 min | 30 min |
| **Routeur 2 + stabilisation mesh** | 12 min | 42 min |
| **7 capteurs (avec délais)** | 20 min | 62 min |
| **Tests et validation** | 10 min | 72 min |
| **Nettoyage entités** | 5 min | 77 min |
| **TOTAL** | | **1h17** |

**Note** : Si Zigbee2MQTT est déjà installé et configuré : **~1h**

---

## Informations de référence

### Coordinateur

| Paramètre | Valeur |
|-----------|--------|
| Modèle | SLZB-MR1-MEZZA |
| IP | 192.168.0.166 |
| Port TCP | 6638 |
| Interface Web | http://192.168.0.166 |
| Adaptateur | EZSP (Silicon Labs EFR32) |

### Configuration réseau Zigbee

| Paramètre | Valeur |
|-----------|--------|
| Canal | 11 (recommandé) |
| PAN ID | GENERATE (auto) |
| Network Key | GENERATE (auto) |
| Transmit Power | 20 dBm (maximum) |

### Services Home Assistant

| Service | URL/Port |
|---------|----------|
| Home Assistant Web | http://homeassistant.local:8123 |
| Zigbee2MQTT Frontend | http://homeassistant.local:8100 |
| Mosquitto MQTT | mqtt://localhost:1883 |

---

## Dépannage rapide

### Coordinateur inaccessible

```bash
# Tester le ping
ping 192.168.0.166

# Tester le port TCP
nc -zv 192.168.0.166 6638

# Accéder à l'interface Web
http://192.168.0.166
```

**Solution** :
- Vérifier que le coordinateur est allumé
- Vérifier le câble réseau
- Vérifier l'IP (peut avoir changé avec DHCP)

### Zigbee2MQTT ne démarre pas

```bash
# Consulter les logs
ha addons logs core_zigbee2mqtt
```

**Erreurs courantes** :
- `Cannot connect to adapter` → Vérifier IP/port coordinateur
- `MQTT connection refused` → Vérifier Mosquitto (user/password)
- `Invalid configuration` → Vérifier zigbee2mqtt_configuration.yaml

### Appareils ne s'appairent pas

**Solutions** :
1. Vérifier que `permit_join: true`
2. Rapprocher l'appareil du coordinateur (< 2 mètres)
3. Réinitialiser complètement l'appareil (factory reset)
4. Consulter RESET_PROCEDURES.md pour la procédure exacte

### Réseau mesh ne se forme pas

**Solutions** :
1. Attendre 10-15 minutes après l'appairage des routeurs
2. Vérifier que les routeurs sont Online (interface Z2M)
3. Réappairer les capteurs (ils choisiront le meilleur chemin)
4. Consulter la carte réseau (Map) dans Zigbee2MQTT

---

## Sauvegardes recommandées

### Avant la reconstruction

```bash
# Snapshot Home Assistant
Paramètres → Système → Sauvegardes → Créer une sauvegarde

# Télécharger sur stockage externe
```

### Après la reconstruction

```bash
# Configuration Zigbee2MQTT
/config/zigbee2mqtt/configuration.yaml

# Base de données Zigbee2MQTT
/config/zigbee2mqtt/database.db

# Snapshot complet Home Assistant
Paramètres → Système → Sauvegardes → Créer une sauvegarde complète
```

---

## Support et ressources

### Documentation officielle

- **Zigbee2MQTT** : https://www.zigbee2mqtt.io/
- **Home Assistant** : https://www.home-assistant.io/docs/
- **SLZB-MR1** : https://smlight.tech/manual/slzb-06/

### Forums et communautés

- **Zigbee2MQTT GitHub** : https://github.com/Koenkk/zigbee2mqtt/discussions
- **Home Assistant Forum** : https://community.home-assistant.io/
- **Discord Home Assistant** : https://discord.gg/home-assistant

### Fichiers de ce projet

Tous les fichiers sont dans : `c:\DATAS\AI\Projets\Perso\Domotique\`

```
├── README_ZIGBEE_RECONSTRUCTION.md (ce fichier)
├── ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md (guide principal)
├── CHECKLIST_REASSOCIATION.md (checklist imprimable)
├── RESET_PROCEDURES.md (référence technique)
├── zigbee2mqtt_configuration.yaml (config prête à l'emploi)
├── secrets_template.yaml (template secrets)
├── diagnostic_zigbee2mqtt.sh (diagnostic Bash)
├── diagnostic_zigbee2mqtt.ps1 (diagnostic PowerShell)
└── MCP_COMMANDS_REFERENCE.md (commandes MCP)
```

---

## Checklist pré-reconstruction

Avant de commencer, s'assurer que :

- [ ] Home Assistant est opérationnel (http://homeassistant.local:8123)
- [ ] Mosquitto MQTT broker est installé et démarré
- [ ] Coordinateur SLZB-MR1-MEZZA est accessible (ping 192.168.0.166)
- [ ] Port 6638 est ouvert (nc -zv 192.168.0.166 6638)
- [ ] Une sauvegarde Home Assistant récente existe
- [ ] Les appareils Zigbee sont accessibles physiquement
- [ ] Documentation RESET_PROCEDURES.md est consultable
- [ ] Temps disponible : minimum 1h30

---

## Notes importantes

### Ordre d'appairage CRITIQUE

1. **TOUJOURS** appairer les routeurs mesh EN PREMIER
2. **ATTENDRE** 5-10 minutes après les routeurs pour stabilisation
3. **ENSUITE SEULEMENT** appairer les capteurs sur batterie

**Pourquoi ?**
- Les routeurs créent le réseau mesh
- Les capteurs ont besoin du mesh pour communiquer efficacement
- Sans routeurs, les capteurs auront une portée limitée et des connexions instables

### Sécurité

- **Désactiver `permit_join`** après la reconstruction (éviter appairages non autorisés)
- **Utiliser des tokens forts** pour Zigbee2MQTT frontend
- **Sauvegarder régulièrement** la base de données Zigbee2MQTT
- **Ne jamais partager** le fichier secrets.yaml

### Performance

- **Canal Zigbee 11** est recommandé (moins d'interférences WiFi)
- **Transmit Power 20 dBm** pour portée maximale
- **LQI > 100** pour routeurs, **LQI > 50** pour capteurs
- **Placer les routeurs stratégiquement** pour couverture optimale

---

## Auteur et version

- **Créé par** : Claude Code (Anthropic)
- **Date de création** : 2025-12-18
- **Version de la documentation** : 1.0
- **Dernière mise à jour** : 2025-12-18

---

## Licence

Cette documentation est fournie "en l'état", sans garantie d'aucune sorte. Utilisez-la à vos propres risques.

---

**Prêt à commencer ? Ouvrez ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md et suivez les étapes !**
