# QUICK START - Reconstruction Zigbee2MQTT

**Pour les utilisateurs pressés - Version condensée**

---

## Étape 1 : Diagnostic (5 minutes)

**Windows** :
```powershell
.\diagnostic_zigbee2mqtt.ps1
```

**Linux/macOS** :
```bash
./diagnostic_zigbee2mqtt.sh
```

**Vérifier** :
- Coordinateur accessible (192.168.0.166:6638)
- Home Assistant opérationnel
- Mosquitto démarré

---

## Étape 2 : Configuration Zigbee2MQTT (10 minutes)

### Si Zigbee2MQTT n'est PAS installé :

1. Home Assistant → Paramètres → Modules complémentaires → Boutique
2. Chercher "Zigbee2MQTT"
3. Installer
4. NE PAS démarrer

### Configuration :

1. Zigbee2MQTT → Onglet Configuration
2. Copier le contenu de `zigbee2mqtt_configuration.yaml`
3. Modifier dans `/config/secrets.yaml` :
   ```yaml
   mqtt_password: VOTRE_MOT_DE_PASSE_MOSQUITTO
   ```
4. Sauvegarder
5. Cocher "Démarrer au boot"
6. Démarrer l'add-on
7. Vérifier les logs : "Zigbee2MQTT started!"

**Interface Web Z2M** : http://homeassistant.local:8100 ou http://192.168.0.166:8100

---

## Étape 3 : Réassociation des appareils (45 minutes)

### PHASE 1 : Routeurs mesh (OBLIGATOIRE EN PREMIER)

#### 3.1 Activer le mode appairage

Interface Web Z2M → Cliquer sur "Permit Join (All)"

#### 3.2 Routeur 1 - Prise_Mesh_Salon

```
1. Brancher la prise
2. Maintenir le bouton 5-10s
3. LED clignote rapidement
4. Attendre détection dans Z2M (1-2 min)
5. Renommer : "Prise_Mesh_Salon"
6. ATTENDRE 2 MINUTES
```

#### 3.3 Routeur 2 - Prise_Mesh_Cuisine

```
1. Brancher la prise
2. Maintenir le bouton 5-10s
3. LED clignote rapidement
4. Attendre détection dans Z2M (1-2 min)
5. Renommer : "Prise_Mesh_Cuisine"
6. ATTENDRE 5-10 MINUTES (construction du mesh)
```

**Vérifier la carte réseau** : Z2M → Map → Les 2 routeurs sont connectés au coordinateur

---

### PHASE 2 : Capteurs (après stabilisation du mesh)

**Procédure générique** :
```
1. Retirer la pile
2. Maintenir le bouton reset
3. Remettre la pile (bouton maintenu)
4. Relâcher après 5-10s
5. Attendre détection (1-2 min)
6. Renommer l'appareil
7. Attendre 30s avant le suivant
```

**Ordre recommandé** :
1. th_cuisine
2. th_salon
3. th_parents
4. th_loann
5. th_meva
6. th_axel
7. th_terrasse

**Consulter RESET_PROCEDURES.md pour procédures spécifiques par marque**

---

## Étape 4 : Nettoyage (5 minutes)

### 4.1 Désactiver le mode appairage

Interface Web Z2M → Cliquer sur "Permit Join (All)" pour désactiver

### 4.2 Supprimer les entités orphelines

```
Home Assistant → Paramètres → Appareils et services → Entités
Filtrer : "mqtt" + "unavailable"

Pour chaque ancienne entité :
Menu (3 points) → Supprimer l'entité
```

---

## Étape 5 : Validation (10 minutes)

### 5.1 Vérifier le réseau mesh

```
Z2M → Map

Attendu :
Coordinator
  ├── Prise_Mesh_Salon [Router]
  │   └── Capteurs...
  └── Prise_Mesh_Cuisine [Router]
      └── Capteurs...
```

### 5.2 Tester les routeurs

```
Home Assistant → Switch Prise_Mesh_Salon → ON/OFF
Home Assistant → Switch Prise_Mesh_Cuisine → ON/OFF
Réactivité < 1 seconde
```

### 5.3 Vérifier les capteurs

```
Home Assistant → Capteurs température/humidité
Valeurs cohérentes (15-30°C, 30-70%)
LQI > 50
```

---

## Étape 6 : Sauvegarde (5 minutes)

```
Home Assistant → Paramètres → Système → Sauvegardes
Créer une sauvegarde complète
Télécharger sur stockage externe
```

---

## Résolution de problèmes rapide

| Problème | Solution |
|----------|----------|
| Coordinateur inaccessible | Vérifier IP et port 6638, redémarrer le coordinateur |
| Z2M ne démarre pas | Consulter les logs : `ha addons logs core_zigbee2mqtt` |
| Appareil ne s'appaire pas | Rapprocher du coordinateur (< 2m), réessayer le reset |
| Réseau mesh absent | Attendre 10-15 min, réappairer les capteurs |
| Déconnexions fréquentes | Vérifier LQI < 20, rapprocher routeurs, changer canal |

---

## Interfaces utiles

- **Coordinateur** : http://192.168.0.166
- **Home Assistant** : http://homeassistant.local:8123
- **Zigbee2MQTT** : http://homeassistant.local:8100 (Port 8100 - le 8099 est utilisé par HA Vibecode Agent)

---

## Besoin de détails ?

**Consulter la documentation complète** :
- `README_ZIGBEE_RECONSTRUCTION.md` (index général)
- `ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md` (guide détaillé)
- `RESET_PROCEDURES.md` (procédures par marque)
- `CHECKLIST_REASSOCIATION.md` (checklist imprimable)

---

**Durée totale estimée : 1h15**

**Prêt ? Commencez par l'Étape 1 !**
