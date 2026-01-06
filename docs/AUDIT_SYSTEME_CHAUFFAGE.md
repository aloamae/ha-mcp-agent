# AUDIT SYSTEME CHAUFFAGE - Home Assistant

**Date:** 23 decembre 2025
**Statut:** Operationnel (avec point d'attention sur trigger 05:45)

---

## 1. INVENTAIRE DES ENTITES

### 1.1 Helpers (input_*)

| Entity ID | Type | Description | Valeurs |
|-----------|------|-------------|---------|
| `input_boolean.mode_vacance` | Boolean | Mode vacances global | on/off |
| `input_number.mode_chauffage_global` | Number | Temperature mode global | 16-22C, step 0.5 |
| `input_number.seuil_humidite_chauffage` | Number | Seuil humidite global | 61% par defaut |
| `input_select.mode_chauffage_cuisine` | Select | Mode piece Cuisine | MODEJOUR, STOP, Confort(19), etc. |
| `input_select.mode_chauffage_parents` | Select | Mode piece Parents | MODEJOUR, STOP, Confort(19), etc. |
| `input_select.mode_chauffage_loann` | Select | Mode piece Loann | MODEJOUR, STOP, Confort(19), etc. |
| `input_select.mode_chauffage_salon` | Select | Mode piece Salon | MODEJOUR, STOP, Confort(19), etc. |
| `input_select.mode_chauffage_axel` | Select | Mode piece Axel | MODEJOUR, STOP, Confort(19), etc. |
| `input_select.mode_chauffage_maeva` | Select | Mode piece Maeva | MODEJOUR, STOP, Confort(19), etc. |
| `input_boolean.mode_humidite_cuisine` | Boolean | Boost humidite Cuisine | on/off |
| `input_boolean.mode_humidite_parents` | Boolean | Boost humidite Parents | on/off |
| `input_boolean.mode_humidite_loann` | Boolean | Boost humidite Loann | on/off |
| `input_boolean.mode_humidite_salon` | Boolean | Boost humidite Salon | on/off |
| `input_boolean.mode_humidite_axel` | Boolean | Boost humidite Axel | on/off |
| `input_boolean.mode_humidite_maeva` | Boolean | Boost humidite Maeva | on/off |

### 1.2 Capteurs Temperature (sensor.th_*)

| Entity ID | Piece | Type |
|-----------|-------|------|
| `sensor.th_cuisine_temperature` | Cuisine | Zigbee TH |
| `sensor.th_parents_temperature` | Parents | Zigbee TH |
| `sensor.th_loann_temperature` | Loann | Zigbee TH |
| `sensor.th_salon_humidity` | Salon | Zigbee TH |
| `sensor.th_axel_humidity` | Axel | Zigbee TH |
| `sensor.th_maeva_humidity` | Maeva | Zigbee TH |

### 1.3 Capteurs Humidite (sensor.th_*_humidity)

| Entity ID | Piece |
|-----------|-------|
| `sensor.th_cuisine_humidity` | Cuisine |
| `sensor.th_parents_humidity` | Parents |
| `sensor.th_loann_humidity` | Loann |
| `sensor.th_salon_humidity` | Salon |
| `sensor.th_axel_humidity` | Axel |
| `sensor.th_maeva_humidity` | Maeva |

### 1.4 Actuateurs

| Entity ID | Type | Description |
|-----------|------|-------------|
| `switch.thermostat` | Switch | Chaudiere GAZ |
| `climate.climatisation_salon` | Climate | Clim Salon (Broadlink) |
| `climate.climatisation_axel` | Climate | Clim Axel (Broadlink) |
| `climate.climatisation_maeva` | Climate | Clim Maeva (Broadlink) |
| `remote.clim_salon` | Remote | Broadlink Salon |
| `remote.clim_axel` | Remote | Broadlink Axel |
| `remote.clim_maeva` | Remote | Broadlink Maeva |

### 1.5 Template Sensors

| Entity ID | Description |
|-----------|-------------|
| `sensor.mode_chauffage_global_temperature` | Lit input_number.mode_chauffage_global |

---

## 2. INVENTAIRE DES AUTOMATIONS

### 2.1 Automations Planning (2)

| Automation | Triggers | Action |
|------------|----------|--------|
| `chauffage_planning_automatique_horaire` | 05:45, 08:00, 17:00, 22:30 | Met toutes pieces en MODEJOUR |
| `chauffage_mise_a_jour_mode_global` | 05:45, 08:00, 17:00, 22:30 | Change temperature globale |

### 2.2 Automations Pilotage (4)

| Automation | Cycle | Description |
|------------|-------|-------------|
| `chauffage_pilotage_chaudiere_gaz` | 3 min | Pilote switch.thermostat |
| `climatisation_pilotage_salon` | 3 min | Pilote climate.climatisation_salon |
| `climatisation_pilotage_axel` | 3 min | Pilote climate.climatisation_axel |
| `climatisation_pilotage_maeva` | 3 min | Pilote climate.climatisation_maeva |

### 2.3 Automations Humidite (12)

| Automation | Trigger | Action |
|------------|---------|--------|
| `humidite_seuil_cuisine_on` | Humidite > seuil (2 min) | mode_humidite_cuisine = ON |
| `humidite_seuil_cuisine_off` | Humidite < seuil (5 min) | mode_humidite_cuisine = OFF |
| `humidite_seuil_parents_on` | Humidite > seuil (2 min) | mode_humidite_parents = ON |
| `humidite_seuil_parents_off` | Humidite < seuil (5 min) | mode_humidite_parents = OFF |
| `humidite_seuil_loann_on` | Humidite > seuil (2 min) | mode_humidite_loann = ON |
| `humidite_seuil_loann_off` | Humidite < seuil (5 min) | mode_humidite_loann = OFF |
| `humidite_seuil_salon_on` | Humidite > seuil (2 min) | mode_humidite_salon = ON |
| `humidite_seuil_salon_off` | Humidite < seuil (5 min) | mode_humidite_salon = OFF |
| `humidite_seuil_axel_on` | Humidite > seuil (2 min) | mode_humidite_axel = ON |
| `humidite_seuil_axel_off` | Humidite < seuil (5 min) | mode_humidite_axel = OFF |
| `humidite_seuil_maeva_on` | Humidite > seuil (2 min) | mode_humidite_maeva = ON |
| `humidite_seuil_maeva_off` | Humidite < seuil (5 min) | mode_humidite_maeva = OFF |

### 2.4 Automations Vacances

| Automation | Description |
|------------|-------------|
| `alerte_vacances_22h` | Notification si mode vacance actif a 22h |

---

## 3. SYSTEME DE PRIORITES (6 NIVEAUX)

```
1. MODE VACANCES (Priorite MAX)
   -> Force 16C GAZ + OFF Clims
   -> Bloque tout le reste

2. MODE HUMIDITE PAR PIECE
   -> Boost +2C si humidite > seuil
   -> Automatique selon capteurs

3. MODES MANUELS PAR PIECE
   -> Controle individuel utilisateur
   -> GAZ: MAX(Cuisine, Parents, Loann)
   -> Clims: Individuelles

4. MODE PLANNING HORAIRE
   -> 4 creneaux automatiques (MODEJOUR)
   -> 05:45, 08:00, 17:00, 22:30

5. MODE CHAUFFAGE GLOBAL
   -> Temperature de reference
   -> Utilise si piece = MODEJOUR

6. PILOTAGE (Execution)
   -> Cycle toutes les 3 minutes
   -> Zone morte +/-0.5C
```

---

## 4. CRENEAUX HORAIRES

| Heure | Mode | Temperature |
|-------|------|-------------|
| 05:45 | Confort Matin | 19C |
| 08:00 | Eco Journee | 17C |
| 17:00 | Confort Soir | 19C |
| 22:30 | Hors-Gel Nuit | 17C |

---

## 5. POINTS D'ATTENTION

### 5.1 Trigger 05:45 non fonctionnel

**Probleme:** Le trigger de 05:45 dans l'automation "Mise a jour Mode Global" ne se declenche pas.

**Status:** Correction fournie, a verifier demain matin.

**Solution:** Automation corrigee avec syntaxe `trigger: time` explicite et IDs de trigger.

### 5.2 Broadlink Timeouts

**Probleme:** Les remotes Broadlink peuvent se deconnecter.

**Solution:** Les remotes se reconnectent automatiquement. En cas de probleme:
- Outils dev -> Services -> `homeassistant.turn_on`
- Entite: `remote.clim_*`

### 5.3 Doublons d'automations

**Probleme resolu:** Des doublons existaient pour `mode_presence_retour` et `climatisation_salon_control`.

**Solution appliquee:** Suppression manuelle des doublons via l'interface HA.

---

## 6. FICHIERS DE CONFIGURATION

### 6.1 Automations principales (dans le projet)

- `automation_chauffage_GAZ_v4_humidite.yaml` - Pilotage GAZ
- `automation_climatisation_SALON_v4_humidite.yaml` - Pilotage Salon
- `automation_climatisation_AXEL_v3.yaml` - Pilotage Axel
- `automation_climatisation_MAEVA_v3.yaml` - Pilotage Maeva
- `automation_planning_horaire_v3_modejour.yaml` - Planning automatique
- `automation_planning_mise_a_jour_mode_global.yaml` - Mise a jour mode global
- `automation_humidite_*.yaml` - Automations humidite (6 fichiers)

### 6.2 Dashboards

- `dashboard_chauffage_complet.yaml` - Dashboard principal
- `dashboard_debugging_modes_v2.yaml` - Dashboard debugging

---

## 7. RECOMMANDATIONS

### 7.1 A court terme

1. **Verifier le trigger 05:45** demain matin
2. **Monitorer les logs** pour confirmer le bon fonctionnement

### 7.2 A moyen terme

1. **Consolider les fichiers YAML** dans un seul repertoire organise
2. **Nettoyer les fichiers obsoletes** du projet
3. **Documenter les procedures de rollback**

### 7.3 A long terme

1. **Implementer un monitoring** avec alertes
2. **Ajouter des graphiques** de consommation energie
3. **Evaluer l'integration** avec d'autres systemes (presence, soleil, etc.)

---

**Fin de l'audit**
