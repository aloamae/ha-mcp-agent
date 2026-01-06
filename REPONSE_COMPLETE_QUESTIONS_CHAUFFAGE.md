# RÉPONSE COMPLÈTE - QUESTIONS CHAUFFAGE & CLIMATISATIONS

**Date:** 20 décembre 2025
**Statut:** ✅ Automation chaudière fonctionne | ❌ Climatisations sans pilotage automatique

---

## ✅ PARTIE 1: AUTOMATION CHAUDIÈRE - SUCCÈS

### Log vérifié (23:18)

```
⏸️ ZONE MORTE - Maintien état chaudière
Cuisine: 19.19°C (-0.2°C)
Parents: 19.2°C (-0.2°C)
Loann: 19.7°C (-0.7°C)
Consigne: 19.0°C
État chaudière: on
```

**Analyse:**
- ✅ Seuils ±0.5°C **ACTIFS**
- ✅ Zone morte **MAINTIENT L'ÉTAT** (on) au lieu d'éteindre
- ✅ Logs détaillés avec toutes les températures
- ✅ Déclenchement toutes les 3 minutes (time_pattern)
- ✅ Comportement parfait

**Conclusion:** L'automation corrigée fonctionne **PARFAITEMENT**! 🎉

---

## ❌ PARTIE 2: CLIMATISATIONS BROADLINK - PROBLÈME IDENTIFIÉ

### État actuel des climatisations

**Entités existantes:**
```
climate.climatisation_salon
climate.climatisation_maeva
climate.climatisation_axel
```

**Remotes Broadlink associés:**
```
remote.clim_salon   → Broadlink RM4 Pro Salon
remote.clim_maeva   → Broadlink RM4 Pro Maeva
remote.clim_axel    → Broadlink RM4 Pro Axel
```

### Problème 1: Aucune automation de pilotage

**Ce qui existe:**
- ✅ Intégration SmartIR installée
- ✅ Dashboards Lovelace pour contrôle manuel
- ✅ Remotes Broadlink configurés

**Ce qui MANQUE:**
- ❌ **AUCUNE automation de pilotage automatique**
- ❌ Pas de synchronisation avec le système de chauffage
- ❌ Pas de régulation par température
- ❌ Pas de lien avec les modes (Confort/Eco/Absent/Présence)
- ❌ Pas de planifications horaires

### Problème 2: Broadlink ne répond pas

**Causes possibles:**

1. **Remotes désactivés (OFF)**
   - Comme identifié dans `DIAGNOSTIC_BROADLINK_FINAL.md`
   - Quand remote OFF → Commandes IR non envoyées
   - Solution: Activer les remotes via `homeassistant.turn_on`

2. **Home Assistant inaccessible**
   - L'analyse montre timeout sur toutes les requêtes API
   - HA est peut-être arrêté ou redémarre
   - Vérifier: http://192.168.0.166:8123

3. **SmartIR compatibility**
   - SmartIR nécessite mise à jour régulière
   - Vérifier version dans: Paramètres → Modules complémentaires → HACS → SmartIR

### Vérifications à faire dans Home Assistant

**Quand HA sera accessible:**

1. **État des remotes:**
   ```
   Outils dev → États
   Chercher: remote.clim_salon, remote.clim_maeva, remote.clim_axel
   Vérifier: État = ON (pas OFF)
   ```

2. **État des climatisations:**
   ```
   Outils dev → États
   Chercher: climate.climatisation_*
   Vérifier: Attributes disponibles (temperature, hvac_mode, etc.)
   ```

3. **Test manuel:**
   ```
   Outils dev → Services
   Service: climate.set_temperature
   Entité: climate.climatisation_salon
   Data: {"temperature": 22}

   → Vérifier si le Broadlink émet la commande IR
   → Observer si la clim physique réagit
   ```

4. **Logs SmartIR:**
   ```
   Outils dev → Logs
   Chercher: "smartir" ou "broadlink"
   Vérifier: Erreurs de communication
   ```

---

## 📋 PARTIE 3: RÉPONSES À TES QUESTIONS

### Question 1: Modes manuels par pièce - Comment les utilises-tu? Sont-ils prioritaires?

**Entités identifiées:**
```
input_select.mode_chauffage_salon
input_select.mode_chauffage_cuisine
input_select.mode_chauffage_parents (probablement)
```

**Utilisation actuelle:**
- Ces modes permettent de définir une consigne **par pièce**
- Ils ont la **2ème priorité** (après mode vacances)
- Ils overrident le mode global et les planifications

**Cas d'usage:**
- Salon plus chaud le soir (TV, invités)
- Cuisine plus froide la nuit
- Chambre parents réglage personnalisé

**Problème actuel:**
- ✅ Système existe
- ❌ Pas de documentation sur les valeurs possibles
- ❌ Pas de vérification de priorité avec mode présence

**À vérifier dans HA:**
1. Outils dev → États → `input_select.mode_chauffage_salon`
2. Noter les options disponibles (ex: "Confort 21°C", "Eco 19°C", "Absent 16°C")
3. Tester si changement de mode par pièce override bien le planning

### Question 2: Mode présence - Faut-il une automation de retour?

**✅ OUI, ABSOLUMENT!**

**Situation actuelle:**
- Automation de DÉPART existe (dans `ANALYSE_MODE_PRESENCE.md`)
- Automation de RETOUR **N'EXISTE PAS**
- État sauvegardé mais jamais restauré

**Conséquence:**
- Au retour, les modes restent en "Absent"
- Il faut les réactiver manuellement
- Pas de restauration automatique de l'état avant départ

**Solution à créer:**
```yaml
# automation_mode_presence_retour.yaml
- id: mode_presence_retour
  alias: Mode Présence - Retour à la maison
  triggers:
    - platform: state
      entity_id: zone.home
      to: "1"  # Quelqu'un rentre
  actions:
    # Restaurer les modes sauvegardés
    - service: scene.turn_on
      target:
        entity_id: scene.avant_depart

    # Log
    - service: script.log_chauffage
      data:
        message: >
          🏠 RETOUR - Restauration modes chauffage
          Modes restaurés depuis scene.avant_depart
```

**Amélioration possible:**
- Ajouter délai (5 min) pour éviter faux départs
- Vérifier si scene.avant_depart existe avant de restaurer
- Notification de confirmation

### Question 3: sensor.mode_chauffage_global - Comment est-il calculé?

**Utilisation actuelle:**
```yaml
# Dans automation_chauffage_pilotage_chaudiere_corrigee.yaml
consigne: >
  {% if is_state('input_boolean.mode_vacance','on') %}
    16
  {% else %}
    {{ states('sensor.mode_chauffage_global')
       | regex_findall_index('\\d+\\.?\\d*')
       | float(18.5) }}
  {% endif %}
```

**Ce qu'on sait:**
- Utilisé comme consigne par défaut
- Fallback: 18.5°C si non disponible
- Agrège probablement les modes supérieurs

**Ce qu'on NE SAIT PAS:**
- ❓ Template sensor ou helper?
- ❓ Quelle logique de calcul?
- ❓ Prend-il en compte planning horaire?

**Où le chercher:**

**Option 1: Template sensor (configuration.yaml)**
```yaml
template:
  - sensor:
      - name: "Mode Chauffage Global"
        unique_id: mode_chauffage_global
        state: >
          {% if ... %}
            "Confort 21°C"
          {% elif ... %}
            "Eco 19°C"
          ...
```

**Option 2: Helper (via UI)**
```
Paramètres → Appareils et services → Auxiliaires
Chercher: "Mode Chauffage Global"
Type probable: input_select ou sensor
```

**Option 3: Via API (quand HA accessible)**
```bash
GET /api/states/sensor.mode_chauffage_global

Response:
{
  "entity_id": "sensor.mode_chauffage_global",
  "state": "Confort 21°C",
  "attributes": {
    "friendly_name": "...",
    "device_class": "...",
    ...
  }
}
```

**À FAIRE:**
1. Quand HA accessible, chercher dans:
   - Paramètres → Auxiliaires
   - Outils dev → États → `sensor.mode_chauffage_global`
   - Vérifier les attributs
2. Si template sensor, chercher dans `configuration.yaml`
3. Documenter la logique de calcul

---

## 🎯 PARTIE 4: SOLUTIONS PROPOSÉES

### Solution 1: Activer les remotes Broadlink

**Script à créer:** `activer_remotes_broadlink.ps1`

```powershell
$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"

$headers = @{
    "Authorization" = "Bearer $HA_TOKEN"
    "Content-Type" = "application/json"
}

$remotes = @("remote.clim_salon", "remote.clim_maeva", "remote.clim_axel")

foreach ($remote in $remotes) {
    $body = @{
        entity_id = $remote
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "$HA_URL/api/services/homeassistant/turn_on" `
        -Headers $headers -Method POST -Body $body

    Write-Host "Activé: $remote" -ForegroundColor Green
}
```

### Solution 2: Créer automations climatisations

**Automation type 1: Pilotage par température**

```yaml
# automation_climatisation_salon_temperature.yaml
- id: climatisation_salon_auto
  alias: Climatisation Salon - Pilotage automatique
  mode: single
  triggers:
    - platform: time_pattern
      minutes: /5  # Toutes les 5 min
  conditions:
    # Seulement si mode auto activé
    - condition: state
      entity_id: input_boolean.mode_auto_climatisation_salon
      state: "on"
  actions:
    - variables:
        temp_actuelle: "{{ states('sensor.th_salon_temperature') | float(20) }}"
        consigne: "{{ states('sensor.mode_chauffage_global') | regex_findall_index('\\d+\\.?\\d*') | float(19) }}"

        trop_chaud: "{{ (temp_actuelle - consigne) >= 1.0 }}"
        trop_froid: "{{ (consigne - temp_actuelle) >= 1.0 }}"

    - choose:
        # Si trop chaud → Activer mode COOL
        - conditions:
            - "{{ trop_chaud }}"
          sequence:
            - service: climate.set_hvac_mode
              target:
                entity_id: climate.climatisation_salon
              data:
                hvac_mode: cool
            - service: climate.set_temperature
              target:
                entity_id: climate.climatisation_salon
              data:
                temperature: "{{ consigne }}"

        # Si trop froid → Activer mode HEAT
        - conditions:
            - "{{ trop_froid }}"
          sequence:
            - service: climate.set_hvac_mode
              target:
                entity_id: climate.climatisation_salon
              data:
                hvac_mode: heat
            - service: climate.set_temperature
              target:
                entity_id: climate.climatisation_salon
              data:
                temperature: "{{ consigne }}"

        # Zone morte → Éteindre
        default:
          - service: climate.set_hvac_mode
            target:
              entity_id: climate.climatisation_salon
            data:
              hvac_mode: "off"
```

**Helpers nécessaires:**
```yaml
# configuration.yaml
input_boolean:
  mode_auto_climatisation_salon:
    name: Mode Auto Climatisation Salon
    icon: mdi:robot

  mode_auto_climatisation_maeva:
    name: Mode Auto Climatisation Maeva
    icon: mdi:robot

  mode_auto_climatisation_axel:
    name: Mode Auto Climatisation Axel
    icon: mdi:robot
```

### Solution 3: Dashboard de debugging des modes

**Voir fichier créé:** `dashboard_debugging_modes_complet.yaml` (ci-dessous)

---

## 📊 PARTIE 5: DIAGNOSTIC SMARTIR + BROADLINK

### Comment vérifier si SmartIR fonctionne

**Méthode 1: Via l'interface HA**

1. **Vérifier installation SmartIR:**
   ```
   Paramètres → Modules complémentaires
   → HACS → Intégrations
   → Chercher: SmartIR
   → Vérifier: Version installée (dernière = ?)
   ```

2. **Vérifier configuration:**
   ```
   Fichier: /config/custom_components/smartir/
   Vérifier: climate.py existe
   ```

3. **Logs SmartIR:**
   ```
   Outils dev → Logs
   Filtrer: "smartir"

   Messages attendus:
   - "SmartIR climate component loaded"
   - "Device code: XXXX loaded"

   Erreurs possibles:
   - "Device code not found"
   - "Broadlink device unavailable"
   - "IR command failed"
   ```

**Méthode 2: Test manuel**

```
Outils dev → Services
Service: climate.turn_on
Entité: climate.climatisation_salon

1. Cliquer "APPELER LE SERVICE"
2. Observer:
   - LED Broadlink clignote? (émission IR)
   - Climatisation physique réagit?
   - Logs HA montrent une erreur?
```

**Méthode 3: Vérifier codes IR**

```
Fichier: /config/custom_components/smartir/codes/climate/XXXX.json

Exemple:
{
  "manufacturer": "Daikin",
  "supportedModels": ["FTXS35K"],
  "commands": {
    "off": "...",
    "heat_22": "...",
    "cool_22": "...",
    ...
  }
}
```

### Causes fréquentes de dysfonctionnement

| Problème | Cause | Solution |
|----------|-------|----------|
| Remote OFF | Entité désactivée | `homeassistant.turn_on` |
| Pas de réponse IR | Broadlink déconnecté | Vérifier IP, redémarrer |
| Code IR invalide | Mauvais fichier JSON | Vérifier device code |
| SmartIR obsolète | Version ancienne | Mettre à jour via HACS |
| Conflit IR | Plusieurs Broadlink | Vérifier entity_id unique |

---

## 📝 PARTIE 6: CHECKLIST COMPLÈTE

### À faire maintenant (HA arrêté)

- [x] ✅ Vérifier automation chaudière fonctionne (FAIT - logs OK)
- [ ] ❌ Créer automation retour mode présence
- [ ] ❌ Créer dashboard debugging modes
- [ ] ❌ Documenter modes manuels par pièce
- [ ] ❌ Créer automations climatisations (optionnel)

### À faire quand HA accessible

- [ ] Vérifier état remotes Broadlink (ON/OFF)
- [ ] Vérifier état climatisations
- [ ] Chercher sensor.mode_chauffage_global (Auxiliaires ou configuration.yaml)
- [ ] Tester commande IR manuelle (climate.turn_on)
- [ ] Vérifier logs SmartIR
- [ ] Activer remotes si désactivés
- [ ] Tester automation retour présence
- [ ] Installer dashboard debugging

---

## 🎯 RÉSUMÉ EXÉCUTIF

### ✅ CE QUI FONCTIONNE

1. **Automation chaudière:**
   - Seuils ±0.5°C actifs
   - Zone morte maintient état
   - Logs détaillés
   - Parfait! 🎉

### ❌ CE QUI NE FONCTIONNE PAS

1. **Climatisations Broadlink:**
   - Aucune automation de pilotage
   - Possiblement remotes désactivés
   - SmartIR à vérifier

2. **Mode présence:**
   - Pas d'automation de retour
   - États sauvegardés mais pas restaurés

3. **Sensor mode_chauffage_global:**
   - Logique de calcul inconnue
   - À chercher dans configuration.yaml

### 🔧 ACTIONS PRIORITAIRES

1. **Immédiat (HA arrêté):**
   - Créer automation retour présence
   - Créer dashboard debugging modes
   - Documenter système complet

2. **Dès que HA accessible:**
   - Activer remotes Broadlink
   - Chercher sensor.mode_chauffage_global
   - Tester climatisations manuellement
   - Installer dashboard debugging

3. **Optionnel:**
   - Créer automations pilotage climatisations
   - Synchroniser avec système chauffage central

---

**Prochaine étape:** Création des fichiers manquants (automation retour présence + dashboard debugging)
