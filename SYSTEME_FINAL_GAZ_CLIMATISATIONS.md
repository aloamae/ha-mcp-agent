# SYSTÈME FINAL - GAZ + CLIMATISATIONS

**Date:** 21 décembre 2025
**Version:** Finale complète

---

## 🎯 SYSTÈME RETENU

### Chauffage: GAZ + CLIMATISATIONS

**Pièces GAZ (chaudière unique):**
- ✅ Cuisine (sensor.th_cuisine_temperature)
- ✅ Chambre Parents (sensor.th_parents_temperature)
- ✅ Chambre Loann (sensor.th_loann_temperature)

**Pièces CLIMATISATIONS (individuelles):**
- ✅ Salon (climate.climatisation_salon)
- ✅ Chambre Axel (climate.climatisation_axel)
- ✅ Chambre Maeva (climate.climatisation_maeva)

---

## 📊 ORDRE DE PRIORITÉ FINAL (5 NIVEAUX)

```
1. MODE VACANCES (Priorité MAX)
   └─> GAZ: 16°C hors-gel
   └─> CLIMATISATIONS: OFF
   └─> BLOQUE tout

2. MODES MANUELS PAR PIÈCE (Priorité 2)

   A) CHAUFFAGE GAZ:
      └─> input_select.mode_chauffage_cuisine
      └─> input_select.mode_chauffage_parents
      └─> input_select.mode_chauffage_loann
      └─> Consigne = MIN(Cuisine, Parents, Loann)
      └─> Exemple: Cuisine 21°C + Parents 19°C + Loann 18°C → Chaudière 18°C

   B) CLIMATISATIONS INDIVIDUELLES:
      └─> input_select.mode_chauffage_salon → Pilotage Salon
      └─> input_select.mode_chauffage_axel → Pilotage Axel
      └─> input_select.mode_chauffage_maeva → Pilotage Maeva
      └─> Chaque pièce gérée indépendamment

3. MODE PLANNING HORAIRE (Priorité 3)
   └─> 4 planifications/jour
   └─> Actif si modes manuels = STOP ou MODEJOUR

4. MODE CHAUFFAGE GLOBAL (Priorité 4)
   └─> sensor.mode_chauffage_global
   └─> Fallback par défaut: 18.5°C
   └─> Utilisé si MODEJOUR sélectionné

5. PILOTAGE (Exécution)
   └─> automation.chauffage_pilotage_chaudiere_gaz (GAZ)
   └─> automation.climatisation_pilotage_salon (Salon)
   └─> automation.climatisation_pilotage_axel (Axel)
   └─> automation.climatisation_pilotage_maeva (Maeva)
   └─> Seuils ±0.5°C pour tous
   └─> Cycle: Toutes les 3 min
```

---

## 🔧 AUTOMATIONS FINALES (5 fichiers)

### 1. Pilotage Chaudière GAZ - Mode Manuel 3 pièces

**Fichier:** `automation_chauffage_GAZ_FINAL.yaml`

**Fonctionnement:**

```yaml
Consigne calculée (PIÈCES GAZ UNIQUEMENT):
  SI mode_vacances ON:
    → 16°C

  SINON SI modes manuels actifs (Cuisine, Parents, Loann):
    Cuisine: Extraire température (ex: "Confort2(19.5)" → 19.5)
    Parents: Extraire température
    Loann: Extraire température

    SI au moins 1 pièce != STOP/MODEJOUR:
      → Consigne = MIN(températures actives)

    Exemple:
      - Cuisine: Confort3(21)
      - Parents: STOP
      - Loann: Eco(18)
      → Consigne = MIN(21, 18) = 18°C

  SINON (tous en STOP/MODEJOUR):
    → sensor.mode_chauffage_global (fallback 18.5°C)

Pilotage chaudière:
  SI au moins 1 pièce GAZ >= +0.5°C de delta:
    → ALLUMER chaudière

  SI toutes pièces GAZ <= -0.5°C de delta:
    → ÉTEINDRE chaudière

  SINON (zone morte -0.5 à +0.5):
    → MAINTENIR état actuel
```

### 2. Pilotage Climatisation SALON - Mode Manuel individuel

**Fichier:** `automation_climatisation_SALON.yaml`

**Fonctionnement:**

```yaml
Consigne calculée (SALON UNIQUEMENT):
  SI mode_vacances ON:
    → OFF (éteindre climatisation)

  SINON SI mode_chauffage_salon == STOP:
    → OFF

  SINON SI mode_chauffage_salon == MODEJOUR:
    → sensor.mode_chauffage_global

  SINON:
    → Température extraite du mode (ex: "Confort2(19.5)" → 19.5)

Pilotage climatisation Salon:
  SI consigne == OFF:
    → climate.turn_off (climatisation_salon)

  SI delta >= +0.5°C:
    → climate.set_temperature + hvac_mode: heat

  SI delta <= -0.5°C:
    → climate.turn_off (trop chaud)

  SINON (zone morte):
    → MAINTENIR état actuel
```

### 3. Pilotage Climatisation AXEL - Mode Manuel individuel

**Fichier:** `automation_climatisation_AXEL.yaml`

**Même logique que Salon**, appliquée à:
- `input_select.mode_chauffage_axel`
- `climate.climatisation_axel`

### 4. Pilotage Climatisation MAEVA - Mode Manuel individuel

**Fichier:** `automation_climatisation_MAEVA.yaml`

**Même logique que Salon**, appliquée à:
- `input_select.mode_chauffage_maeva`
- `climate.climatisation_maeva`

### 5. Départ/Retour maison

**Fichier:** `automation_depart_retour_FINAL.yaml`

**Fonctionnement:**

```
DÉPART (zone.home → 0):
1. Créer scène "avant_depart" (sauvegarde modes des 6 pièces)
2. Passer TOUTES les pièces en Hors-Gel(16) ou STOP

RETOUR (zone.home → 1+):
1. Délai 1 minute
2. Restaurer scène "avant_depart"
```

---

## 📥 INSTALLATION

### Étape 1: Vérifier helpers existants

**Helpers requis (input_select):**

Vérifier que tu as ces 6 helpers:
```
input_select.mode_chauffage_cuisine
input_select.mode_chauffage_parents
input_select.mode_chauffage_loann
input_select.mode_chauffage_salon
input_select.mode_chauffage_axel
input_select.mode_chauffage_maeva
```

**Si manquants:**
```
Paramètres → Appareils et services → Auxiliaires
→ + CRÉER UN AUXILIAIRE → Liste déroulante
→ Nom: "Mode Chauffage [Pièce]"
→ Options: STOP, MODEJOUR, Hors-Gel(16), Eco(18), Confort1(19), Confort2(19.5), Confort3(21)
```

### Étape 2: Automation Chaudière GAZ (REMPLACER l'ancienne)

```
1. Automations → Chercher "Chauffage - Pilotage Chaudière GAZ"
2. Cliquer dessus
3. ... → Modifier au format YAML
4. TOUT sélectionner → Supprimer
5. Copier automation_chauffage_GAZ_FINAL.yaml
6. COLLER
7. ENREGISTRER
```

### Étape 3: Automations Climatisations (CRÉER 3 nouvelles)

**Pour SALON:**
```
Automations → + CRÉER
→ ... → Modifier YAML
→ Copier automation_climatisation_SALON.yaml
→ ENREGISTRER
```

**Répéter pour:**
- automation_climatisation_AXEL.yaml
- automation_climatisation_MAEVA.yaml

### Étape 4: Automations Départ/Retour (si n'existent pas déjà)

```
Automations → + CRÉER
→ ... → Modifier YAML
→ Copier première partie de automation_depart_retour_FINAL.yaml
→ ENREGISTRER

Répéter pour deuxième automation (Retour)
```

### Étape 5: Réactiver remotes Broadlink

**Vérifier que remotes sont ON:**
```
Outils dev → États
→ Chercher: remote.clim_salon
→ Vérifier état: on
```

**Si OFF, créer automation réactivation:**
```
Automations → + CRÉER
→ Copier automation_reactiver_remotes_broadlink.yaml
```

---

## ✅ VALIDATION

### Test 1: Mode Vacances (GAZ + Climatisations)

```
1. Activer: input_boolean.mode_vacance → ON
2. Attendre 3 minutes
3. Logs GAZ: Chercher "Consigne: 16"
4. Logs Climatisations: Chercher "OFF" (Salon, Axel, Maeva)
5. Vérifier: Chaudière à 16°C ✅
6. Vérifier: Climatisations éteintes ✅
7. Désactiver mode vacances
```

### Test 2: Mode Manuel GAZ - Minimum des 3 pièces

```
1. Mode Cuisine → Confort3(21)
2. Mode Parents → Eco(18)
3. Mode Loann → Confort2(19.5)
4. Attendre 3 minutes
5. Logs: Chercher "Consigne: 18"
6. Vérifier: Consigne = 18°C (minimum) ✅
```

### Test 3: Mode Manuel GAZ - Avec STOP

```
1. Mode Cuisine → STOP
2. Mode Parents → Confort2(19.5)
3. Mode Loann → Eco(18)
4. Attendre 3 minutes
5. Logs: Chercher "Consigne: 18"
6. Vérifier: Prend MIN des actifs (ignore STOP) ✅
```

### Test 4: Mode Manuel Climatisation Salon (indépendant)

```
1. Mode Salon → Confort3(21)
2. Mode Cuisine (GAZ) → Eco(18)
3. Attendre 3 minutes
4. Logs GAZ: "Consigne: 18" ✅
5. Logs Salon: "Consigne: 21" ✅
6. Vérifier: Chaudière à 18°C, Salon à 21°C (indépendants) ✅
```

### Test 5: Climatisations individuelles différentes

```
1. Mode Salon → Confort3(21)
2. Mode Axel → Eco(18)
3. Mode Maeva → STOP
4. Attendre 3 minutes
5. Logs Salon: "Consigne: 21" ✅
6. Logs Axel: "Consigne: 18" ✅
7. Logs Maeva: "OFF" ✅
8. Vérifier: Chaque clim gérée indépendamment ✅
```

### Test 6: Départ/Retour (6 pièces)

```
DÉPART:
1. Modes actuels:
   - Cuisine: Confort2(19.5)
   - Parents: Eco(18)
   - Loann: Confort1(19)
   - Salon: Confort3(21)
   - Axel: Eco(18)
   - Maeva: STOP
2. Changer zone.home → 0
3. Attendre 10 secondes
4. Vérifier: Tous modes = Hors-Gel(16) ou STOP ✅
5. Vérifier: scene.avant_depart existe ✅

RETOUR:
6. Changer zone.home → 1
7. Attendre 1 minute
8. Vérifier: Tous modes restaurés ✅
```

---

## 📋 EXEMPLES CONCRETS

### Exemple 1: Journée normale hiver

```
08:00 - Planning Matin
  GAZ:
    → Mode global: Confort (19°C)
    → Cuisine, Parents, Loann: 19°C

  CLIMATISATIONS:
    → Salon: Mode global 19°C
    → Axel: STOP (absent)
    → Maeva: STOP (absente)

12:00 - Ajustement manuel Salon (confort personnel)
  → Mode Salon: Confort3(21°C)
  → GAZ: reste 19°C (indépendant)
  → Salon chauffe à 21°C

14:00 - Ajustement manuel Cuisine (cuisson)
  → Mode Cuisine: Confort3(21°C)
  → Modes Parents + Loann: restent 19°C
  → Consigne GAZ: MIN(21, 19, 19) = 19°C
  → Chaudière chauffe à 19°C
```

### Exemple 2: Soirée froide (toutes pièces utilisées)

```
18:00 - Retour à la maison
  → Salon: Confort3(21°C) — Famille au salon
  → Axel: Confort2(19.5°C) — Axel rentre
  → Maeva: Confort2(19.5°C) — Maeva rentre

  → Cuisine: Confort2(19.5°C)
  → Parents: Confort2(19.5°C)
  → Loann: Confort1(19°C)

  Résultat:
  - Chaudière GAZ: 19°C (minimum des 3 pièces GAZ)
  - Climatisation Salon: 21°C (indépendante)
  - Climatisation Axel: 19.5°C (indépendante)
  - Climatisation Maeva: 19.5°C (indépendante)
```

### Exemple 3: Nuit (économie énergie)

```
22:00 - Coucher
  → Salon: STOP (personne)
  → Axel: Confort1(19°C) — Dort
  → Maeva: Confort1(19°C) — Dort

  → Cuisine: Hors-Gel(16°C)
  → Parents: Confort2(19.5°C) — Nuit
  → Loann: Confort1(19°C) — Dort

  Résultat:
  - Chaudière GAZ: 16°C (minimum = hors-gel)
  - Climatisation Salon: OFF
  - Climatisation Axel: 19°C
  - Climatisation Maeva: 19°C
```

### Exemple 4: Vacances

```
Départ vacances:
  → Activer: mode_vacances

  Résultat:
  - Chaudière GAZ: 16°C (forcé)
  - Toutes climatisations: OFF (forcé)
  - Modes manuels IGNORÉS
  - Planning IGNORÉ

Retour vacances:
  → Désactiver: mode_vacances
  → Modes manuels reprennent priorité
```

---

## 🎯 AVANTAGES SYSTÈME COMPLET

### vs Version GAZ seul

| Avant (GAZ seul) | Après (GAZ + Clims) |
|------------------|---------------------|
| ❌ 3 pièces seulement chauffées | ✅ 6 pièces chauffées |
| ❌ Salon pas de contrôle individuel | ✅ Salon pilotage indépendant |
| ❌ Chambres enfants sans clim | ✅ Axel + Maeva climatisations actives |
| ❌ Climatisations inutilisées | ✅ Climatisations intégrées |

### Points forts système complet

1. ✅ **Modes Manuels GAZ intelligents**
   - Consigne = minimum des 3 pièces GAZ
   - Ignore STOP (prend actifs seulement)
   - Chaudière chauffe efficacement

2. ✅ **Climatisations indépendantes**
   - Chaque pièce pilotée séparément
   - Confort personnalisé par pièce
   - Salon peut être 21°C pendant que Axel est 18°C

3. ✅ **Seuils précis ±0.5°C**
   - GAZ: réactif et précis
   - Climatisations: réactives et précises
   - Zone morte maintient état

4. ✅ **Mode Vacances global**
   - GAZ à 16°C (hors-gel)
   - Toutes clims éteintes
   - Économie maximale

5. ✅ **Départ/Retour 6 pièces**
   - Sauvegarde automatique
   - Restauration au retour
   - Simple et efficace

---

## 📁 FICHIERS DU SYSTÈME

### À installer (5 fichiers)

1. ✅ `automation_chauffage_GAZ_FINAL.yaml` (chaudière)
2. ✅ `automation_climatisation_SALON.yaml` (Salon)
3. ✅ `automation_climatisation_AXEL.yaml` (Axel)
4. ✅ `automation_climatisation_MAEVA.yaml` (Maeva)
5. ✅ `automation_depart_retour_FINAL.yaml` (sauvegarde)

### Optionnel

6. ⏳ `automation_reactiver_remotes_broadlink.yaml` (si remotes OFF)

### Documentation

1. ✅ `SYSTEME_FINAL_GAZ_CLIMATISATIONS.md` (ce fichier)

---

## 🚀 PROCHAINES ÉTAPES

### Immédiat

1. ✅ Vérifier 6 helpers input_select
2. ✅ Installer automation GAZ FINAL
3. ✅ Installer 3 automations climatisations
4. ✅ Tester modes manuels GAZ (minimum 3 pièces)
5. ✅ Tester climatisations individuelles

### Court terme

6. ✅ Installer automations Départ/Retour
7. ✅ Tester sauvegarde/restauration 6 pièces
8. ✅ Surveiller logs 24h (GAZ + Clims)
9. ✅ Vérifier remotes Broadlink (ON/OFF)

### Optionnel (plus tard)

- ⏳ Gestion TRV individuelle par pièce GAZ
- ⏳ Dashboard monitoring avancé (6 pièces)
- ⏳ Statistiques consommation GAZ vs Climatisations

---

## 📞 SUPPORT

### Problème Mode Manuel GAZ

**Vérifier:**
```
Logs → Chercher "Consigne"
→ Doit afficher MIN(Cuisine, Parents, Loann)
→ Pas sensor.mode_chauffage_global si modes actifs
```

**Si minimum incorrect:**
1. Vérifier automation GAZ = version FINAL
2. Vérifier helpers != STOP (ou au moins 1 actif)
3. Relancer automation manuellement

### Problème Climatisation Individuelle

**Vérifier:**
```
Logs → Chercher "CLIMATISATION [PIÈCE]"
→ Doit afficher température et consigne
```

**Si climatisation ne répond pas:**
1. Vérifier remote.clim_[pièce] = on
2. Vérifier automation climatisation activée
3. Tester manuellement: climate.set_temperature
4. Vérifier SmartIR configuré

### Problème Remotes Broadlink OFF

**Réactiver manuellement:**
```
Outils dev → Services
→ Service: homeassistant.turn_on
→ Entité: remote.clim_salon (ou axel, maeva)
→ APPELER LE SERVICE
```

**Installer automation réactivation:**
```
automation_reactiver_remotes_broadlink.yaml
→ Détecte OFF → Réactive après 5 sec
```

---

## 📊 RÉCAPITULATIF COMPLET

**Système finalisé!** ✅

**6 pièces chauffées:**
- 3 GAZ (Cuisine, Parents, Loann) → Minimum des 3
- 3 Climatisations (Salon, Axel, Maeva) → Individuelles

**5 niveaux de priorité:**
1. Mode Vacances (bloque tout)
2. Modes Manuels (GAZ minimum, Clims individuelles)
3. Planning Horaire
4. Mode Global (fallback)
5. Pilotage (±0.5°C)

**Installation:** 15 minutes (5 automations)
**Validation:** 6 tests
**Maintenance:** Automatique

---

**Système complet GAZ + Climatisations prêt!** ✅
