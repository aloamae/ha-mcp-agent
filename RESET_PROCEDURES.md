# Procédures de Reset et d'Appairage des Appareils Zigbee

**Date**: 2025-12-18
**Coordinateur**: SLZB-MR1-MEZZA (192.168.0.166:6638)

---

## AVANT DE COMMENCER

### Prérequis

1. Mode appairage activé dans Zigbee2MQTT :
   - Interface Web Z2M : http://homeassistant.local:8100 ou http://192.168.0.166:8100
   - Cliquer sur "Permit Join (All)" en haut de la page
   - OU modifier la configuration : `permit_join: true`

2. Observer les logs en temps réel :
   - Home Assistant → Paramètres → Modules complémentaires
   - Zigbee2MQTT → Onglet "Journal"

3. Avoir l'interface Web Z2M ouverte (onglet "Appareils")

---

## ROUTEURS MESH : PRISES CONNECTÉES

### Type d'appareil : Prises intelligentes Zigbee (génériques)

**Rôle** : Routeur mesh (relaie les messages des autres appareils)

#### Procédure générique de reset :

1. **Brancher la prise** sur une prise murale
2. **Maintenir le bouton** principal pendant 5-10 secondes
3. **Observer la LED** :
   - Elle doit clignoter rapidement (mode appairage)
   - Fréquence rapide = prêt à être appairé
4. **Attendre la détection** dans les logs Z2M (30s à 2 min)

#### Procédures spécifiques selon la marque :

##### Prises Tuya/Smart Life

1. Brancher la prise
2. Maintenir le bouton pendant **5 secondes**
3. Relâcher quand la LED clignote rapidement (2-3 fois/seconde)
4. Timeout : 3 minutes si pas d'appairage

##### Prises IKEA Trådfri

1. Brancher la prise
2. Appuyer **6 fois rapidement** sur le bouton de reset (pin hole)
3. LED rouge continue = mode appairage
4. Timeout : 1 minute si pas d'appairage

##### Prises Sonoff S26/S31

1. Brancher la prise
2. Maintenir le bouton pendant **5 secondes**
3. LED clignote vert/rouge = mode appairage
4. Timeout : 3 minutes si pas d'appairage

##### Prises Xiaomi/Aqara

1. Brancher la prise
2. Maintenir le bouton pendant **5 secondes**
3. LED bleue clignote rapidement = mode appairage
4. Timeout : 2 minutes si pas d'appairage

#### Vérification post-appairage :

```
✓ Appareil visible dans Z2M interface
✓ Type confirmé : "Router" (pas "EndDevice")
✓ État : Online
✓ Test ON/OFF depuis Home Assistant fonctionne
✓ Friendly Name défini : Prise_Mesh_Salon ou Prise_Mesh_Cuisine
```

#### En cas d'échec :

1. **Éloigner l'appareil** des autres appareils Zigbee (interférences)
2. **Rapprocher du coordinateur** (< 2 mètres lors de l'appairage)
3. **Couper l'alimentation** pendant 10 secondes, rebrancher et réessayer
4. **Essayer plusieurs fois** le reset (parfois nécessaire 2-3 tentatives)

---

## CAPTEURS TEMPÉRATURE/HUMIDITÉ

### Type d'appareil : Capteurs Zigbee sur batterie (génériques)

**Rôle** : EndDevice (appareil terminal, communique via les routeurs)

#### Procédure générique de reset :

1. **Retirer la pile** (ouvrir le boîtier)
2. **Localiser le bouton** de reset/appairage (souvent près du compartiment pile)
3. **Maintenir le bouton** enfoncé
4. **Remettre la pile** tout en maintenant le bouton
5. **Maintenir encore 5-10 secondes** après insertion de la pile
6. **Relâcher le bouton**
7. **Observer la LED** :
   - Clignotement = mode appairage
   - Pas de LED sur certains modèles (attendre 1 minute)
8. **Attendre la détection** dans les logs Z2M (30s à 2 min)

#### Procédures spécifiques selon la marque :

##### Xiaomi/Aqara Temperature & Humidity Sensor (WSDCGQ11LM)

1. Retirer la pile CR2032
2. Maintenir le bouton reset (petit trou)
3. Remettre la pile (bouton toujours maintenu)
4. Relâcher après 5 secondes
5. LED bleue clignote = mode appairage
6. Appuyer brièvement sur le bouton pour forcer l'envoi des données

##### Tuya/Smart Life Temperature Sensor

1. Retirer les piles AAA
2. Maintenir le bouton reset (ou bouton principal)
3. Remettre les piles (bouton maintenu)
4. Relâcher après 10 secondes
5. LED clignote rapidement = mode appairage

##### Sonoff SNZB-02 (Temperature & Humidity Sensor)

1. Retirer la pile CR2450
2. Maintenir le bouton sur le circuit imprimé
3. Remettre la pile (bouton maintenu)
4. Relâcher après 5 secondes
5. LED rouge clignote 3 fois = mode appairage

##### IKEA Vindstyrka (Air Quality Sensor avec T&H)

1. Débrancher l'alimentation USB
2. Maintenir le bouton de reset (pin hole sur le dessous)
3. Rebrancher l'alimentation (bouton maintenu)
4. Relâcher après 10 secondes
5. LED clignote = réinitialisation en cours

#### Vérification post-appairage :

```
✓ Appareil visible dans Z2M interface
✓ Type confirmé : "EndDevice" (pas "Router")
✓ État : Online
✓ Données de température reçues (15-30°C selon pièce)
✓ Données d'humidité reçues (30-70% selon pièce)
✓ Niveau de batterie affiché (si applicable)
✓ Link Quality (LQI) > 50
✓ Friendly Name défini : th_cuisine, th_salon, etc.
```

#### En cas d'échec :

1. **Rapprocher du coordinateur ou d'un routeur mesh** (< 3 mètres)
2. **Vérifier que les routeurs sont Online** avant d'appairer les capteurs
3. **Remplacer la pile** par une neuve (pile faible = appairage impossible)
4. **Attendre plus longtemps** (certains capteurs prennent jusqu'à 5 minutes)
5. **Réessayer le reset** avec une attente plus longue (15 secondes)

---

## ORDRE D'APPAIRAGE CRITIQUE

### Phase 1 : Routeurs (construire le réseau)

1. **Prise_Mesh_Salon** (premier routeur)
   - Attendre 2 minutes après l'appairage
   - Vérifier : Online et type Router

2. **Prise_Mesh_Cuisine** (deuxième routeur)
   - Attendre 5-10 minutes après l'appairage
   - Vérifier : Online, type Router, et réseau mesh formé

### Phase 2 : Capteurs (utiliser le réseau)

**Ordre recommandé (du plus proche au plus éloigné) :**

1. **th_cuisine** - Proche de Prise_Mesh_Cuisine
2. **th_salon** - Proche de Prise_Mesh_Salon
3. **th_parents** - Chambre parents
4. **th_loann** - Chambre Loann
5. **th_meva** - Chambre Meva
6. **th_axel** - Chambre Axel
7. **th_terrasse** - Extérieur (le plus éloigné)

**Délai entre chaque capteur : 30 secondes minimum**

---

## DIAGNOSTIC DES PROBLÈMES COURANTS

### Problème : Appareil détecté mais interview échoue

**Symptôme** :
```
[INFO] Device '0xaabbccddeeff0011' joined
[ERROR] Failed to interview '0xaabbccddeeff0011', device has not successfully been paired
```

**Solutions** :

1. Réinitialiser l'appareil et réessayer immédiatement
2. Approcher l'appareil du coordinateur (< 1 mètre)
3. Vérifier qu'aucun autre appareil n'est en cours d'interview
4. Augmenter le log level à `debug` pour voir les détails
5. Attendre 5 minutes et laisser Z2M réessayer automatiquement

### Problème : Appareil non détecté du tout

**Symptôme** :
- Aucun message dans les logs Z2M
- LED de l'appareil clignote mais rien ne se passe

**Solutions** :

1. Vérifier que `permit_join: true` dans Z2M
2. Vérifier que le coordinateur fonctionne (logs Z2M sans erreurs)
3. Rapprocher l'appareil du coordinateur (< 50 cm)
4. Désactiver temporairement les autres routeurs (pour éviter conflits)
5. Réinitialiser le coordinateur en dernier recours (ATTENTION : perd le réseau)

### Problème : Appareil se déconnecte après appairage

**Symptôme** :
```
[INFO] Device 'th_salon' is now 'offline'
```

**Solutions** :

1. Vérifier la batterie (remplacer si < 20%)
2. Vérifier le LQI (< 20 = signal trop faible)
3. Rapprocher un routeur mesh de l'appareil
4. Augmenter `transmit_power` dans la config Z2M
5. Changer le canal Zigbee (interférences WiFi)

### Problème : Routeur ne crée pas de routes mesh

**Symptôme** :
- Routeur Online mais les capteurs se connectent au coordinateur
- Carte réseau Z2M ne montre pas de connexions via le routeur

**Solutions** :

1. Attendre 10-15 minutes (construction mesh automatique)
2. Réappairer les capteurs (ils choisiront le meilleur chemin)
3. Vérifier l'alimentation du routeur (prise défectueuse)
4. Redémarrer Zigbee2MQTT
5. Vérifier que le routeur n'est pas trop éloigné du coordinateur

---

## COMMANDES UTILES ZIGBEE2MQTT

### Via l'interface Web Z2M

#### Activer le mode appairage :
```
Cliquer sur "Permit Join (All)" (bouton en haut)
Durée : 254 secondes par défaut (4 min)
```

#### Forcer une mise à jour d'un capteur :
```
Appareils → Sélectionner l'appareil → Onglet "Expose"
Cliquer sur l'icône de rafraîchissement à côté de "temperature"
```

#### Renommer un appareil :
```
Appareils → Sélectionner l'appareil → Onglet "About"
Modifier "Friendly name" → Sauvegarder
```

#### Retirer un appareil :
```
Appareils → Sélectionner l'appareil → Onglet "Settings"
Cliquer sur "Remove" → Confirmer
Option "Force remove" si l'appareil est offline
```

#### Visualiser le réseau mesh :
```
Cliquer sur "Map" dans le menu principal
Carte interactive montrant :
- Coordinateur (centre)
- Routeurs (icônes spéciales)
- EndDevices (capteurs)
- Connexions (lignes) avec LQI
```

### Via MQTT (avec mosquitto_pub/mosquitto_sub)

#### Écouter tous les messages Z2M :
```bash
mosquitto_sub -h localhost -t 'zigbee2mqtt/#' -u homeassistant -P VOTRE_MOT_DE_PASSE -v
```

#### Activer le mode appairage via MQTT :
```bash
mosquitto_pub -h localhost -t 'zigbee2mqtt/bridge/request/permit_join' \
  -m '{"value": true}' \
  -u homeassistant -P VOTRE_MOT_DE_PASSE
```

#### Renommer un appareil via MQTT :
```bash
mosquitto_pub -h localhost -t 'zigbee2mqtt/bridge/request/device/rename' \
  -m '{"from": "0xaabbccddeeff0011", "to": "th_cuisine"}' \
  -u homeassistant -P VOTRE_MOT_DE_PASSE
```

#### Retirer un appareil via MQTT :
```bash
mosquitto_pub -h localhost -t 'zigbee2mqtt/bridge/request/device/remove' \
  -m '{"id": "th_cuisine"}' \
  -u homeassistant -P VOTRE_MOT_DE_PASSE
```

---

## INFORMATIONS TECHNIQUES

### Canaux Zigbee recommandés

| Canal Zigbee | Fréquence (MHz) | Interférence WiFi |
|--------------|-----------------|-------------------|
| 11 (défaut)  | 2405            | Canal 1 WiFi (faible) |
| 15           | 2425            | Entre 1 et 6 WiFi |
| 20           | 2450            | Canal 6 WiFi (forte) |
| 25           | 2475            | Canal 11 WiFi (forte) |

**Recommandation** : Utiliser le canal 11 Zigbee si votre WiFi utilise les canaux 6 ou 11.

### Puissance de transmission (Transmit Power)

| Valeur | Puissance | Usage |
|--------|-----------|-------|
| 0 dBm  | 1 mW      | Très courte portée (test) |
| 5 dBm  | 3.2 mW    | Courte portée |
| 10 dBm | 10 mW     | Portée moyenne |
| 20 dBm | 100 mW    | Portée maximale (défaut SLZB-MR1) |

**Note** : Plus de puissance = plus de portée mais plus de consommation.

### Link Quality Indicator (LQI)

| LQI    | Qualité | Action |
|--------|---------|--------|
| > 200  | Excellente | Aucune |
| 100-200| Bonne   | Aucune |
| 50-100 | Moyenne | Surveiller |
| 20-50  | Faible  | Rapprocher routeur |
| < 20   | Critique| Appareil va se déconnecter |

---

## RÉFÉRENCES RAPIDES

### Appareils du réseau

| Nom | Type | Rôle | Emplacement |
|-----|------|------|-------------|
| Prise_Mesh_Salon | Switch | Router | Salon |
| Prise_Mesh_Cuisine | Switch | Router | Cuisine |
| th_cuisine | Sensor | EndDevice | Cuisine |
| th_salon | Sensor | EndDevice | Salon |
| th_loann | Sensor | EndDevice | Chambre Loann |
| th_meva | Sensor | EndDevice | Chambre Meva |
| th_axel | Sensor | EndDevice | Chambre Axel |
| th_parents | Sensor | EndDevice | Chambre Parents |
| th_terrasse | Sensor | EndDevice | Terrasse |

### Coordinateur

- **Modèle** : SLZB-MR1-MEZZA
- **IP** : 192.168.0.166
- **Port TCP** : 6638
- **Interface Web** : http://192.168.0.166
- **Adaptateur** : EZSP (Silicon Labs EFR32)

### Services

- **Home Assistant** : http://homeassistant.local:8123
- **Zigbee2MQTT** : http://homeassistant.local:8100 (Port 8100 - le 8099 est utilisé par HA Vibecode Agent)
- **MQTT Broker** : mqtt://localhost:1883

---

## CHANGELOG

| Date | Changement | Auteur |
|------|------------|--------|
| 2025-12-18 | Création du document | Claude Code |
| | | |
| | | |

---

**Document créé le : 2025-12-18**
**Dernière mise à jour : 2025-12-18**
