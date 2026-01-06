# Guide Complet : Reconstruction du Réseau Zigbee2MQTT

**Date**: 2025-12-18
**Coordinateur**: SLZB-MR1-MEZZA (192.168.0.166:6638)
**Broker MQTT**: Mosquitto (localhost:1883)

---

## ÉTAPE 1 : VÉRIFICATION DE L'INSTALLATION ZIGBEE2MQTT

### Via l'interface Home Assistant :

1. **Accéder aux add-ons** :
   - Ouvrir Home Assistant (http://homeassistant.local:8123)
   - Paramètres → Modules complémentaires → Boutique des modules complémentaires

2. **Vérifier si Zigbee2MQTT est installé** :
   - Chercher "Zigbee2MQTT" dans la liste des add-ons installés
   - Vérifier son état : Running / Stopped / Not installed

3. **Si installé, consulter les logs** :
   - Cliquer sur Zigbee2MQTT
   - Onglet "Journal" pour voir les logs en temps réel
   - Chercher les erreurs de connexion au coordinateur ou au broker MQTT

### Commandes pour vérifier l'état (via Terminal & SSH ou CLI Home Assistant) :

```bash
# Lister tous les add-ons installés
ha addons list

# Vérifier l'état de Zigbee2MQTT
ha addons info core_zigbee2mqtt

# Voir les logs
ha addons logs core_zigbee2mqtt
```

---

## ÉTAPE 2 : INSTALLATION DE ZIGBEE2MQTT (si non installé)

### Via l'interface Home Assistant :

1. **Ajouter le repository officiel** :
   - Paramètres → Modules complémentaires → Boutique des modules complémentaires
   - Menu (3 points) → Dépôts
   - Ajouter : `https://github.com/zigbee2mqtt/hassio-zigbee2mqtt`

2. **Installer Zigbee2MQTT** :
   - Rafraîchir la boutique
   - Chercher "Zigbee2MQTT"
   - Cliquer sur "INSTALLER"
   - Attendre la fin de l'installation (peut prendre 5-10 minutes)

3. **NE PAS DÉMARRER AVANT LA CONFIGURATION**

---

## ÉTAPE 3 : CONFIGURATION COMPLÈTE ZIGBEE2MQTT

### Configuration pour SLZB-MR1-MEZZA (Coordinateur réseau)

Accéder à l'onglet "Configuration" de l'add-on Zigbee2MQTT et utiliser cette configuration :

```yaml
# Configuration Zigbee2MQTT pour SLZB-MR1-MEZZA
data_path: /config/zigbee2mqtt

# Intégration Home Assistant
homeassistant: true

# État initial du mode appairage
permit_join: false

# Configuration MQTT (Mosquitto local)
mqtt:
  base_topic: zigbee2mqtt
  server: mqtt://localhost:1883
  user: homeassistant
  password: !secret mqtt_password  # À définir dans secrets.yaml

# Configuration du coordinateur SLZB-MR1-MEZZA
serial:
  port: tcp://192.168.0.166:6638
  adapter: ezsp  # Adaptateur pour Silicon Labs EFR32

# Paramètres avancés
advanced:
  log_level: info
  log_output:
    - console
  pan_id: GENERATE  # Généré automatiquement au premier démarrage
  network_key: GENERATE  # Clé réseau générée automatiquement
  channel: 11  # Canal Zigbee (11, 15, 20, 25 recommandés)

  # Configuration réseau Zigbee
  homeassistant_discovery_topic: homeassistant
  homeassistant_status_topic: homeassistant/status
  last_seen: ISO_8601
  elapsed: false

  # Options de cache et de disponibilité
  cache_state: true
  cache_state_persistent: true
  cache_state_send_on_startup: true

  # Configuration du réseau mesh
  network_mode:
    pan_id: GENERATE
    ext_pan_id: GENERATE
    channel: 11

  # Options de transmission
  transmit_power: 20  # Puissance max pour SLZB-MR1-MEZZA

# Options par défaut pour les périphériques
device_options:
  legacy: false  # Désactiver le mode legacy pour de meilleures performances
  retain: true  # Conserver les messages MQTT

# Frontend (interface Web)
# Note: Port 8100 (le port 8099 est utilisé par HA Vibecode Agent - l'agent MCP)
frontend:
  port: 8100
  host: 0.0.0.0
  auth_token: !secret zigbee2mqtt_auth_token  # Optionnel

# Activation des fonctionnalités expérimentales
experimental:
  new_api: true

# Options d'availability
availability:
  active:
    timeout: 10
  passive:
    timeout: 1500

# Groupes (à configurer après appairage des appareils)
groups: {}
```

### Configuration des secrets (secrets.yaml)

Ajouter dans `/config/secrets.yaml` :

```yaml
# MQTT
mqtt_password: VOTRE_MOT_DE_PASSE_MOSQUITTO

# Zigbee2MQTT Frontend (optionnel)
zigbee2mqtt_auth_token: !GÉNÉRER_UN_TOKEN_ALÉATOIRE
```

### Points critiques de la configuration :

1. **Adapter** : `ezsp` pour Silicon Labs EFR32 (utilisé par SLZB-MR1-MEZZA)
2. **Port** : `tcp://192.168.0.166:6638` (connexion réseau au coordinateur)
3. **Canal** : `11` (éviter les interférences WiFi - canaux 1, 6, 11 WiFi)
4. **MQTT** : `localhost:1883` (Mosquitto local)
5. **HomeAssistant** : `true` (découverte automatique des entités)

---

## ÉTAPE 4 : DÉMARRAGE ET VALIDATION

### Démarrage de Zigbee2MQTT :

1. **Sauvegarder la configuration**
2. **Cocher "Démarrer au boot"**
3. **Démarrer l'add-on**
4. **Surveiller les logs** :

```
[INFO] Starting Zigbee2MQTT...
[INFO] MQTT connected
[INFO] Coordinator firmware version: 6.10.3.0
[INFO] Zigbee2MQTT started!
```

### Erreurs courantes et solutions :

| Erreur | Solution |
|--------|----------|
| `Error: Cannot connect to adapter` | Vérifier IP/port du coordinateur (192.168.0.166:6638) |
| `MQTT connection refused` | Vérifier Mosquitto (user/password) |
| `Coordinator not found` | Vérifier que SLZB-MR1-MEZZA est allumé et accessible |
| `Channel not set` | Le coordinateur doit être réinitialisé (backup réseau perdu) |

### Vérification de la connectivité du coordinateur :

```bash
# Tester la connexion TCP au coordinateur
nc -zv 192.168.0.166 6638

# Ou avec telnet
telnet 192.168.0.166 6638
```

---

## ÉTAPE 5 : PLAN DE RÉASSOCIATION DES APPAREILS

### CRITÈRE D'ORDRE : ROUTEURS D'ABORD, CAPTEURS ENSUITE

**Pourquoi ?**
- Les routeurs (prises connectées) créent le réseau mesh
- Les capteurs (appareils sur batterie) ont besoin du mesh pour communiquer
- Sans routeurs, les capteurs auront une portée limitée et des connexions instables

---

### PHASE 1 : RÉASSOCIATION DES ROUTEURS MESH (PRIORITÉ ABSOLUE)

**Appareils concernés** :
1. `Prise_Mesh_Salon` (switch.prise_mesh_salon)
2. `Prise_Mesh_Cuisine` (switch.prise_mesh_cuisine)

#### Procédure pour chaque routeur :

1. **Activer le mode appairage dans Zigbee2MQTT** :
   - Interface Web Z2M (http://homeassistant.local:8100 ou http://192.168.0.166:8100)
   - Cliquer sur "Permit Join (All)" (en haut)
   - OU modifier la config : `permit_join: true` puis redémarrer

2. **Réinitialiser la prise** :
   - Méthode générique : maintenir le bouton pendant 5-10 secondes
   - Chercher la LED : elle doit clignoter rapidement (mode appairage)
   - Consulter le manuel de la prise pour la procédure exacte

3. **Attendre l'appairage** :
   - Observer les logs Z2M :
     ```
     [INFO] Device 'Prise_Mesh_Salon' joined
     [INFO] Successfully interviewed '0x00124b001a2b3c4d'
     [INFO] Device announcement from 'Prise_Mesh_Salon'
     ```
   - Durée : 30 secondes à 2 minutes

4. **Renommer l'appareil** :
   - Interface Z2M → Appareils → Cliquer sur l'appareil
   - Changer le "Friendly Name" :
     - Premier routeur : `Prise_Mesh_Salon`
     - Deuxième routeur : `Prise_Mesh_Cuisine`

5. **ATTENDRE LA STABILISATION** :
   - Après le **premier routeur** : attendre **2 minutes**
   - Après le **deuxième routeur** : attendre **5-10 minutes**
   - Le réseau mesh doit se construire avant d'ajouter les capteurs

#### Vérification du réseau mesh :

```
Interface Z2M → Map (carte du réseau)
```

Vous devriez voir :
```
Coordinator
  ├── Prise_Mesh_Salon (routeur)
  └── Prise_Mesh_Cuisine (routeur)
```

---

### PHASE 2 : RÉASSOCIATION DES CAPTEURS TEMPÉRATURE/HUMIDITÉ

**Appareils concernés** (7 capteurs) :
1. `th_cuisine` - Cuisine
2. `th_salon` - Salon
3. `th_loann` - Chambre Loann
4. `th_meva` - Chambre Meva
5. `th_axel` - Chambre Axel
6. `th_parents` - Chambre Parents
7. `th_terrasse` - Terrasse

#### Procédure pour chaque capteur :

1. **S'assurer que le mode appairage est actif** (permit_join: true)

2. **Réinitialiser le capteur** :
   - Retirer la pile
   - Maintenir le bouton reset/pair
   - Remettre la pile tout en maintenant le bouton
   - Relâcher après 5-10 secondes
   - Consulter le manuel pour la procédure exacte

3. **Attendre l'appairage** (30 secondes à 2 minutes)

4. **Renommer l'appareil** avec le nom approprié (ex: `th_cuisine`)

5. **Attendre 30 secondes avant le prochain capteur**

#### Ordre recommandé (du plus proche au plus éloigné du coordinateur) :

1. `th_cuisine` (proche du coordinateur ou de Prise_Mesh_Cuisine)
2. `th_salon` (proche de Prise_Mesh_Salon)
3. `th_parents` (pièce adjacente)
4. `th_loann`, `th_meva`, `th_axel` (chambres)
5. `th_terrasse` (extérieur, le plus éloigné)

---

## ÉTAPE 6 : NETTOYAGE DES ENTITÉS MQTT ORPHELINES

### Identification des entités à supprimer :

Les anciennes entités `switch.prise_mesh_*` affichent :
```
"Cette entité n'est plus fournie par l'intégration mqtt"
```

### Procédure de nettoyage :

1. **Via l'interface Home Assistant** :
   - Paramètres → Appareils et services
   - Onglet "Entités"
   - Filtrer par : "mqtt" et statut "unavailable"

2. **Identifier les entités obsolètes** :
   - `switch.prise_mesh_salon` (ancienne)
   - `switch.prise_mesh_cuisine` (ancienne)
   - Toutes entités Zigbee avec statut "unavailable" depuis la restauration

3. **Supprimer les entités** :
   - Cliquer sur l'entité
   - Menu (3 points) → "Supprimer l'entité"
   - Confirmer la suppression

### Via la CLI (méthode avancée) :

```bash
# Lister toutes les entités MQTT unavailable
ha state list | grep mqtt | grep unavailable

# Supprimer une entité (via Developer Tools → Services)
Service: homeassistant.entity_registry_remove
Entity ID: switch.prise_mesh_salon
```

---

## ÉTAPE 7 : VALIDATION DU RÉSEAU RECONSTRUIT

### Checklist de validation :

- [ ] Zigbee2MQTT affiche "Started" sans erreurs
- [ ] Les 2 routeurs mesh sont "Online" dans Z2M
- [ ] La carte réseau (Map) montre les routeurs connectés au coordinateur
- [ ] Les 7 capteurs sont "Online" et remontent des données
- [ ] Les capteurs communiquent via les routeurs (vérifier dans Map)
- [ ] Home Assistant découvre automatiquement les nouvelles entités
- [ ] Les anciennes entités orphelines sont supprimées
- [ ] `permit_join` est désactivé (sécurité)

### Tests de connectivité :

1. **Tester les routeurs** :
   - Allumer/éteindre chaque prise depuis Home Assistant
   - Vérifier la réactivité (< 1 seconde)

2. **Tester les capteurs** :
   - Vérifier la mise à jour des températures (fréquence : toutes les 5-10 min)
   - Forcer une lecture : appuyer brièvement sur le bouton du capteur

3. **Tester la stabilité du mesh** :
   - Observer les logs Z2M pendant 1 heure
   - Chercher des déconnexions/reconnexions fréquentes
   - Vérifier le LQI (Link Quality Indicator) dans Z2M : doit être > 100

### Carte réseau finale attendue :

```
Coordinator (SLZB-MR1-MEZZA)
  ├── Prise_Mesh_Salon [Router]
  │   ├── th_salon
  │   ├── th_loann
  │   └── th_meva
  └── Prise_Mesh_Cuisine [Router]
      ├── th_cuisine
      ├── th_axel
      ├── th_parents
      └── th_terrasse
```

---

## COMMANDES MCP HOME ASSISTANT (si serveur MCP configuré)

### Vérification de l'installation :

```bash
# Lister les add-ons
mcp call homeassistant list_addons

# État de Zigbee2MQTT
mcp call homeassistant get_addon_info --addon core_zigbee2mqtt

# Logs Zigbee2MQTT
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt
```

### Gestion de Zigbee2MQTT :

```bash
# Démarrer Z2M
mcp call homeassistant start_addon --addon core_zigbee2mqtt

# Arrêter Z2M
mcp call homeassistant stop_addon --addon core_zigbee2mqtt

# Redémarrer Z2M
mcp call homeassistant restart_addon --addon core_zigbee2mqtt
```

### Gestion des entités :

```bash
# Lister toutes les entités
mcp call homeassistant get_entities

# Lister les entités MQTT unavailable
mcp call homeassistant get_entities --domain mqtt --state unavailable

# Supprimer une entité
mcp call homeassistant remove_entity --entity_id switch.prise_mesh_salon
```

---

## ANNEXE : CONFIGURATION AVANCÉE

### Options de log avancées :

```yaml
advanced:
  log_level: debug  # Pour troubleshooting (warn en production)
  log_output:
    - console
    - file
  log_file: zigbee2mqtt_%TIMESTAMP%.log
  log_rotation: true
  log_directory: /config/zigbee2mqtt/logs
```

### Configuration des groupes (après appairage) :

```yaml
groups:
  # Groupe de toutes les prises mesh
  routeurs_mesh:
    friendly_name: Routeurs Mesh
    devices:
      - Prise_Mesh_Salon
      - Prise_Mesh_Cuisine

  # Groupe des capteurs par étage
  capteurs_etage:
    friendly_name: Capteurs Étage
    devices:
      - th_loann
      - th_meva
      - th_axel
      - th_parents
```

### Configuration de disponibilité personnalisée :

```yaml
availability:
  active:
    timeout: 10  # Timeout en minutes pour appareils actifs (routeurs)
  passive:
    timeout: 1500  # Timeout en minutes pour appareils passifs (capteurs sur batterie)
```

---

## RÉSOLUTION DE PROBLÈMES COURANTS

### Problème 1 : Le coordinateur ne se connecte pas

**Symptôme** : `Error: Cannot connect to adapter`

**Solutions** :
1. Vérifier que SLZB-MR1-MEZZA est accessible :
   ```bash
   ping 192.168.0.166
   nc -zv 192.168.0.166 6638
   ```

2. Vérifier la configuration réseau du coordinateur via son interface Web :
   - http://192.168.0.166
   - TCP Server doit être activé sur le port 6638

3. Tester avec `socat` (diagnostic avancé) :
   ```bash
   socat TCP:192.168.0.166:6638 -
   ```

### Problème 2 : MQTT connection refused

**Symptôme** : `Error: Connection refused: Not authorized`

**Solutions** :
1. Vérifier les credentials Mosquitto :
   ```bash
   ha addons info core_mosquitto
   ```

2. Tester la connexion MQTT :
   ```bash
   mosquitto_sub -h localhost -t 'zigbee2mqtt/#' -u homeassistant -P VOTRE_MOT_DE_PASSE -v
   ```

3. Recréer l'utilisateur MQTT si nécessaire :
   - Configuration Mosquitto → Logins → Ajouter homeassistant

### Problème 3 : Les appareils ne s'appairent pas

**Symptôme** : Aucune détection lors du mode appairage

**Solutions** :
1. Vérifier que `permit_join: true` dans Z2M
2. Réinitialiser complètement l'appareil (factory reset)
3. Approcher l'appareil du coordinateur (< 2 mètres)
4. Désactiver temporairement les routeurs mesh déjà appairés
5. Augmenter le log level à `debug` pour voir les tentatives

### Problème 4 : Le réseau mesh ne se forme pas

**Symptôme** : Les capteurs se connectent directement au coordinateur

**Solutions** :
1. Attendre 10-15 minutes après l'appairage des routeurs
2. Réappairer les capteurs (ils choisiront le meilleur chemin)
3. Vérifier la puissance de transmission des routeurs
4. Placer les routeurs stratégiquement (couverture max)

### Problème 5 : Déconnexions fréquentes

**Symptôme** : Appareils passent de "Online" à "Offline" régulièrement

**Solutions** :
1. Vérifier les interférences WiFi (changer de canal Zigbee)
2. Améliorer le placement des routeurs mesh
3. Vérifier l'alimentation des routeurs (prises défectueuses)
4. Mettre à jour le firmware du coordinateur
5. Augmenter `transmit_power` dans la configuration

---

## TIMELINE ESTIMÉE DE LA RECONSTRUCTION

| Étape | Durée | Cumul |
|-------|-------|-------|
| Installation Z2M (si nécessaire) | 10 min | 10 min |
| Configuration Z2M | 5 min | 15 min |
| Démarrage et validation | 5 min | 20 min |
| Appairage routeur 1 + attente | 5 min | 25 min |
| Appairage routeur 2 + stabilisation mesh | 12 min | 37 min |
| Appairage 7 capteurs (avec délais) | 20 min | 57 min |
| Tests et validation finale | 10 min | 67 min |
| Nettoyage entités orphelines | 5 min | 72 min |

**Total estimé : 1h15 (avec Zigbee2MQTT déjà installé : ~1h)**

---

## BACKUP ET PRÉVENTION

### Sauvegardes critiques à effectuer APRÈS reconstruction :

1. **Configuration Zigbee2MQTT** :
   ```bash
   # Sauvegarder configuration.yaml
   cp /config/zigbee2mqtt/configuration.yaml /config/backups/z2m_config_$(date +%Y%m%d).yaml
   ```

2. **Base de données Zigbee2MQTT** :
   ```bash
   # Sauvegarder database.db
   cp /config/zigbee2mqtt/database.db /config/backups/z2m_db_$(date +%Y%m%d).db
   ```

3. **Snapshot Home Assistant complet** :
   - Paramètres → Système → Sauvegardes
   - Créer une sauvegarde complète
   - Télécharger sur un stockage externe

### Prévention pour éviter de perdre le réseau :

1. **Sauvegardes automatiques hebdomadaires**
2. **Documenter les noms et positions des appareils**
3. **Conserver un export de la configuration Z2M**
4. **Tester la restauration sur un environnement de test**

---

## RÉFÉRENCES

- Documentation officielle Zigbee2MQTT : https://www.zigbee2mqtt.io/
- SLZB-MR1-MEZZA : https://smlight.tech/manual/slzb-06/
- Intégration Home Assistant : https://www.zigbee2mqtt.io/guide/usage/integrations/home_assistant.html
- Forum communautaire : https://github.com/Koenkk/zigbee2mqtt/discussions

---

**Document créé le : 2025-12-18**
**Dernière mise à jour : 2025-12-18**
**Statut : Prêt pour exécution**
