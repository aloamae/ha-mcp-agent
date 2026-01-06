# SYSTEME DE CHAUFFAGE INTELLIGENT - Documentation Complete

**Derniere mise a jour:** 6 janvier 2026
**Version:** 2.0
**Statut:** OPERATIONNEL

---

## 1. ARCHITECTURE GLOBALE

### 1.1 Pieces et equipements

| Piece | Type | Equipement | Capteur |
|-------|------|------------|---------|
| Cuisine | GAZ | switch.thermostat | sensor.th_cuisine_temperature |
| Parents | GAZ | switch.thermostat | sensor.th_parents_temperature |
| Loann | GAZ | switch.thermostat | sensor.th_loann_temperature |
| Salon | CLIM | climate.climatisation_salon | sensor.th_salon_temperature |
| Axel | CLIM | climate.climatisation_axel | sensor.th_axel_temperature |
| Maeva | CLIM | climate.climatisation_maeva | sensor.th_maeva_temperature |

### 1.2 Logique de pilotage

- **GAZ (Cuisine, Parents, Loann):** Chaudiere unique, prend le MAX des 3 consignes
- **CLIM (Salon, Axel, Maeva):** Climatisations independantes via Broadlink IR

---

## 2. MODES DE CHAUFFAGE

### 2.1 Modes par piece (input_select.mode_chauffage_*)

| Mode | Temperature | Description |
|------|-------------|-------------|
| `MODEJOUR` | Variable | Suit le mode global (planning) |
| `STOP` | OFF | Chauffage coupe |
| `Confort3(21)` | 21C | Tres confortable |
| `Confort2(20)` | 20C | Confort+ |
| `Confort(19)` | 19C | Confort standard |
| `Eco2(18.5)` | 18.5C | Economique+ |
| `Eco(18)` | 18C | Economique |
| `Hors-Gel2(17)` | 17C | Protection+ |
| `Hors-Gel(16)` | 16C | Protection minimum |

### 2.2 Modes globaux

| Helper | Description |
|--------|-------------|
| `input_boolean.mode_vacance` | Mode vacances (force 16C partout) |
| `input_number.mode_chauffage_global` | Temperature globale (16-22C) |
| `sensor.mode_chauffage_global_temperature` | Template sensor lecture |

---

## 3. SYSTEME DE PRIORITES (6 NIVEAUX)

```
PRIORITE 1: MODE VACANCES
├── input_boolean.mode_vacance = on
├── Force GAZ a 16C
├── Force CLIM OFF
└── Bloque tout le reste

PRIORITE 2: MODE HUMIDITE
├── input_boolean.mode_humidite_* = on
├── Ajoute +2C a la consigne
└── Active si humidite > seuil pendant 2 min

PRIORITE 3: MODE MANUEL
├── input_select.mode_chauffage_* != MODEJOUR
├── Utilise temperature du mode choisi
└── Prioritaire sur planning

PRIORITE 4: MODE PLANNING
├── Creneaux horaires automatiques
├── Met les pieces en MODEJOUR
└── Change la temperature globale

PRIORITE 5: MODE GLOBAL
├── input_number.mode_chauffage_global
├── Utilise si piece = MODEJOUR
└── Fallback: 18.5C

PRIORITE 6: PILOTAGE
├── Execution toutes les 3 minutes
├── Zone morte: +/- 0.5C
└── Commande physique des equipements
```

---

## 4. PLANNING HORAIRE

### 4.1 Creneaux automatiques

| Heure | ID Trigger | Temperature | Description |
|-------|------------|-------------|-------------|
| 05:45 | confort_matin | 19C | Reveil |
| 08:00 | eco_journee | 17C | Depart |
| 08:05 | special_0805 | 19C | Optionnel (toggle) |
| 17:00 | confort_soir | 19C | Retour |
| 22:30 | horsgel_nuit | 17C | Nuit |

### 4.2 Automations planning

**1. Chauffage - Planning Automatique Horaire**
- Triggers: 05:45, 08:00, 17:00, 22:30
- Action: Met toutes les 6 pieces en MODEJOUR
- Condition: mode_vacance = OFF

**2. Chauffage - Mise a jour Mode Global**
- Triggers: 05:45, 08:00, 17:00, 22:30
- Action: Change input_number.mode_chauffage_global
- Condition: mode_vacance = OFF

**3. Chauffage - Planning 08:05 Mode Global 19C** (Optionnel)
- Trigger: 08:05
- Action: Remet mode global a 19C
- Condition: input_boolean.planning_0805_actif = ON

---

## 5. AUTOMATIONS DE PILOTAGE

### 5.1 Pilotage GAZ

**Fichier:** `automation_chauffage_GAZ_v4_humidite.yaml`

**Logique:**
1. Si mode_vacance = ON → consigne = 16C
2. Sinon, pour chaque piece (Cuisine, Parents, Loann):
   - Si mode = STOP → ignore
   - Si mode = MODEJOUR → utilise temperature globale
   - Sinon → extrait temperature du mode avec regex `\((\d+\.?\d*)\)`
3. Consigne finale = MAX des 3 pieces
4. Si boost humidite actif → +2C
5. Si T < consigne - 0.5 → switch.thermostat ON
6. Si T > consigne + 0.5 → switch.thermostat OFF

### 5.2 Pilotage Climatisations

**Fichiers:**
- `automation_climatisation_SALON_v5_corrige.yaml`
- `automation_climatisation_AXEL_v4_corrige.yaml`
- `automation_climatisation_MAEVA_v4_corrige.yaml`

**Logique (identique pour les 3):**
1. Si mode_vacance = ON → consigne = OFF
2. Si mode = STOP → consigne = OFF
3. Si mode = MODEJOUR → consigne = temperature globale
4. Sinon → extrait temperature avec regex `\((\d+\.?\d*)\)`
5. Si boost humidite → +2C
6. Actions:
   - Si consigne = OFF ET clim != OFF → turn_off
   - Si ecart >= 0.5 ET clim != heat → set_temperature + heat
   - Si ecart <= -0.5 ET clim != OFF → turn_off

**Conditions anti-bip:**
- `etat_actuel != 'heat'` pour eviter d'envoyer HEAT si deja en heat
- `etat_actuel != 'off'` pour eviter d'envoyer OFF si deja off

---

## 6. SYSTEME HUMIDITE

### 6.1 Helpers

| Helper | Piece |
|--------|-------|
| `input_boolean.mode_humidite_cuisine` | Cuisine |
| `input_boolean.mode_humidite_parents` | Parents |
| `input_boolean.mode_humidite_loann` | Loann |
| `input_boolean.mode_humidite_salon` | Salon |
| `input_boolean.mode_humidite_axel` | Axel |
| `input_boolean.mode_humidite_maeva` | Maeva |
| `input_number.seuil_humidite_chauffage` | Seuil global (61%) |

### 6.2 Automations (12 total)

Pour chaque piece, 2 automations:
- `humidite_seuil_*_on`: Active si humidite > seuil pendant 2 min
- `humidite_seuil_*_off`: Desactive si humidite < seuil pendant 5 min

### 6.3 Effet

Quand `mode_humidite_*` = ON:
- La consigne de la piece augmente de +2C
- Permet de secher l'air en chauffant plus

---

## 7. ENTITES COMPLETES

### 7.1 Helpers (input_boolean)

```
input_boolean.mode_vacance
input_boolean.mode_humidite_cuisine
input_boolean.mode_humidite_parents
input_boolean.mode_humidite_loann
input_boolean.mode_humidite_salon
input_boolean.mode_humidite_axel
input_boolean.mode_humidite_maeva
input_boolean.planning_0805_actif
```

### 7.2 Helpers (input_number)

```
input_number.mode_chauffage_global (16-22, step 0.5)
input_number.seuil_humidite_chauffage (40-80, defaut 61)
```

### 7.3 Helpers (input_select)

```
input_select.mode_chauffage_cuisine
input_select.mode_chauffage_parents
input_select.mode_chauffage_loann
input_select.mode_chauffage_salon
input_select.mode_chauffage_axel
input_select.mode_chauffage_maeva
```

Options: MODEJOUR, STOP, Confort3(21), Confort2(20), Confort(19), Eco2(18.5), Eco(18), Hors-Gel2(17), Hors-Gel(16)

### 7.4 Capteurs

```
sensor.th_cuisine_temperature / sensor.th_cuisine_humidity
sensor.th_parents_temperature / sensor.th_parents_humidity
sensor.th_loann_temperature / sensor.th_loann_humidity
sensor.th_salon_temperature / sensor.th_salon_humidity
sensor.th_axel_temperature / sensor.th_axel_humidity
sensor.th_maeva_temperature / sensor.th_maeva_humidity
sensor.mode_chauffage_global_temperature
```

### 7.5 Actuateurs

```
switch.thermostat (chaudiere GAZ)
climate.climatisation_salon
climate.climatisation_axel
climate.climatisation_maeva
remote.clim_salon
remote.clim_axel
remote.clim_maeva
```

---

## 8. AUTOMATIONS COMPLETES

### 8.1 Planning (3)

| Automation | Trigger | Action |
|------------|---------|--------|
| Chauffage - Planning Automatique Horaire | 05:45, 08:00, 17:00, 22:30 | Toutes pieces → MODEJOUR |
| Chauffage - Mise a jour Mode Global | 05:45, 08:00, 17:00, 22:30 | Change temperature globale |
| Chauffage - Planning 08:05 Mode Global 19C | 08:05 | Mode global → 19C (si active) |

### 8.2 Pilotage (4)

| Automation | Cycle | Cible |
|------------|-------|-------|
| Chauffage - Pilotage Chaudiere GAZ | 3 min | switch.thermostat |
| Climatisation - Pilotage Salon | 3 min | climate.climatisation_salon |
| Climatisation - Pilotage Axel | 3 min | climate.climatisation_axel |
| Climatisation - Pilotage Maeva | 3 min | climate.climatisation_maeva |

### 8.3 Humidite (12)

| Piece | Activation | Desactivation |
|-------|------------|---------------|
| Cuisine | humidite_seuil_cuisine_on | humidite_seuil_cuisine_off |
| Parents | humidite_seuil_parents_on | humidite_seuil_parents_off |
| Loann | humidite_seuil_loann_on | humidite_seuil_loann_off |
| Salon | humidite_seuil_salon_on | humidite_seuil_salon_off |
| Axel | humidite_seuil_axel_on | humidite_seuil_axel_off |
| Maeva | humidite_seuil_maeva_on | humidite_seuil_maeva_off |

---

## 9. CORRECTIONS APPLIQUEES

### 9.1 Historique des bugs corriges

| Date | Bug | Cause | Solution |
|------|-----|-------|----------|
| 22/12/2025 | Consigne 3C au lieu de 21C | Regex `\d+` trouvait "3" dans "Confort3(21)" | Regex `\((\d+\.?\d*)\)` |
| 22/12/2025 | IndexError GAZ | regex_findall avant check MODEJOUR | Check MODEJOUR avant regex |
| 22/12/2025 | Doublons automations | Plusieurs automations meme ID | Suppression manuelle |
| 06/01/2026 | Clim bipe sans agir | Doublons automations Salon | Suppression du doublon |
| 06/01/2026 | Clim ne s'arrete pas | Condition `< -0.5` au lieu de `<= -0.5` | Corrige a `<= -0.5` |

### 9.2 Points de vigilance

1. **Pas de doublons d'automations** - Verifier qu'il n'y a qu'une seule automation par piece
2. **Remotes Broadlink** - Peuvent se deconnecter, etat `remote.clim_*` doit etre `on`
3. **Trigger 05:45** - A surveiller si fonctionne correctement

---

## 10. FICHIERS YAML DU PROJET

### 10.1 Automations principales

```
automation_chauffage_GAZ_v4_humidite.yaml
automation_climatisation_SALON_v5_corrige.yaml
automation_climatisation_AXEL_v4_corrige.yaml
automation_climatisation_MAEVA_v4_corrige.yaml
automation_planning_horaire_v3_modejour.yaml
automation_planning_mise_a_jour_mode_global.yaml
automation_planning_0805_mode_global.yaml
```

### 10.2 Automations humidite

```
automation_humidite_cuisine.yaml
automation_humidite_parents.yaml
automation_humidite_loann.yaml
automation_humidite_salon.yaml
automation_humidite_axel.yaml
automation_humidite_maeva.yaml
```

### 10.3 Dashboards

```
dashboard_chauffage_complet.yaml
dashboard_debugging_modes_v2.yaml
dashboard_carte_planning_0805.yaml
```

---

## 11. UTILISATION QUOTIDIENNE

### 11.1 Fonctionnement normal

Laisser toutes les pieces en `MODEJOUR`. Le planning gere automatiquement:
- 05:45 → 19C (reveil)
- 08:00 → 17C (depart)
- 17:00 → 19C (retour)
- 22:30 → 17C (nuit)

### 11.2 Modifier une piece temporairement

1. Changer `input_select.mode_chauffage_*` vers le mode souhaite
2. La piece utilisera cette temperature
3. Au prochain creneau, elle reviendra en MODEJOUR

### 11.3 Partir en vacances

1. Activer `input_boolean.mode_vacance`
2. Tout passe en mode hors-gel (16C)
3. Desactiver au retour

### 11.4 Activer le creneau 08:05

1. Activer `input_boolean.planning_0805_actif`
2. A 08:05, le mode global passera a 19C au lieu de 17C

---

**FIN DU DOCUMENT**
