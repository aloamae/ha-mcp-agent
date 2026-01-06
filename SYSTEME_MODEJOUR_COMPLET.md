# SYSTÈME MODEJOUR COMPLET - INSTALLÉ

**Date d'installation:** 21 décembre 2025
**Statut:** ✅ OPÉRATIONNEL

---

## 🎯 RÉSUMÉ EXÉCUTIF

**NOUVEAU SYSTÈME INSTALLÉ:**
- ✅ Planning horaire avec MODEJOUR (toutes pièces)
- ✅ Mode global contrôlable (input_number + sensor template)
- ✅ 4 créneaux horaires automatiques
- ✅ Compatible avec système humidité
- ✅ 6 niveaux de priorité clairs

---

## 📋 COMPOSANTS INSTALLÉS

### Helpers (2)

**1. input_number.mode_chauffage_global**
- Stocke la température du mode global
- Min: 16°C, Max: 22°C, Step: 0.5°C
- Modifiable manuellement ou par automation

**2. sensor.mode_chauffage_global_temperature**
- Template sensor qui lit l'input_number
- Utilisé par les automations de pilotage
- Se met à jour automatiquement

---

### Automations Planning (2)

**1. Chauffage - Planning Automatique Horaire**
```yaml
Triggers: 05:45, 08:00, 17:00, 22:30
Action: Met toutes les 6 pièces en MODEJOUR
Condition: mode_vacance = OFF
```

**2. Chauffage - Mise à jour Mode Global**
```yaml
Triggers: 05:45, 08:00, 17:00, 22:30
Action: Change input_number.mode_chauffage_global
Températures:
  - 05:45 (Confort Matin) → 19°C
  - 08:00 (Éco Journée) → 17°C
  - 17:00 (Confort Soir) → 19°C
  - 22:30 (Hors-Gel Nuit) → 17°C
```

---

### Automations Pilotage Modifiées (4)

**1. Chauffage - Pilotage Chaudiere GAZ**
- Modifié pour lire `sensor.mode_chauffage_global_temperature`
- Si pièce = MODEJOUR → Utilise mode global
- Si boost humidité actif → +2°C

**2. Climatisation - Pilotage Salon**
**3. Climatisation - Pilotage Axel**
**4. Climatisation - Pilotage Maeva**
- Modifiées pour lire `sensor.mode_chauffage_global_temperature`
- Si mode = MODEJOUR → Suit température globale
- Si boost humidité actif → +2°C

---

## 🔄 FONCTIONNEMENT COMPLET

### Scénario 1: Planning Normal (Journée Type)

```
05:45:00 - RÉVEIL MATIN
├─ Planning met toutes pièces → MODEJOUR
├─ Mode global change → 19°C
└─ Résultat: Toutes pièces chauffent à 19°C (ou 21°C si humidité)

08:00:00 - DÉPART JOURNÉE
├─ Planning garde toutes pièces → MODEJOUR
├─ Mode global change → 17°C
└─ Résultat: Économie énergie (17°C hors-gel)

17:00:00 - RETOUR SOIRÉE
├─ Planning garde toutes pièces → MODEJOUR
├─ Mode global change → 19°C
└─ Résultat: Confort soirée (19°C)

22:30:00 - NUIT
├─ Planning garde toutes pièces → MODEJOUR
├─ Mode global change → 17°C
└─ Résultat: Économie nuit (17°C)
```

---

### Scénario 2: Modification Manuelle d'une Pièce

```
SITUATION:
- Il est 14:00 (entre 08:00 et 17:00)
- Mode global = 17°C
- Toutes pièces en MODEJOUR (suivent 17°C)

ACTION UTILISATEUR:
- Change Salon → Confort3(21°C) manuellement
- Les autres pièces restent en MODEJOUR (17°C)

RÉSULTAT:
- Salon chauffe à 21°C (mode manuel prioritaire)
- Cuisine, Parents, Loann, Axel, Maeva → 17°C (suivent global)

À 17:00:00 (PROCHAIN CRÉNEAU):
- Planning remet Salon → MODEJOUR
- Salon revient à suivre le mode global (qui passe à 19°C)
```

---

### Scénario 3: Mode Vacances Actif

```
ACTION UTILISATEUR:
- Active input_boolean.mode_vacance

COMPORTEMENT:
05:45:00 - Planning NE s'exécute PAS
08:00:00 - Planning NE s'exécute PAS
17:00:00 - Planning NE s'exécute PAS
22:30:00 - Planning NE s'exécute PAS

PILOTAGE:
- Chauffage GAZ force 16°C (hors-gel)
- Climatisations forcées OFF
- Mode vacances est PRIORITAIRE sur tout
```

---

### Scénario 4: Boost Humidité + Planning

```
SITUATION:
- Il est 06:00 (mode global = 19°C)
- Toutes pièces en MODEJOUR
- Humidité Cuisine monte à 70% > seuil (61%)

AUTOMATIQUE:
T+2 min: mode_humidite_cuisine = ON
T+3 min: Pilotage GAZ s'exécute
         → consigne_base = 19°C (mode global)
         → boost_humidite = ON
         → consigne_finale = 19 + 2 = 21°C
         → Chaudière chauffe à 21°C

RÉSULTAT:
- Cuisine (et toutes pièces GAZ) chauffent à 21°C
- Boost prioritaire sur mode global
- Quand humidité < 61% pendant 5 min → retour 19°C
```

---

## 📊 SYSTÈME DE PRIORITÉS (6 NIVEAUX)

```
1️⃣ MODE VACANCES (input_boolean.mode_vacance)
   → Force 16°C GAZ + OFF Clims
   → BLOQUE planning + tout
   → Priorité ABSOLUE

2️⃣ MODE HUMIDITÉ PAR PIÈCE (input_boolean.mode_humidite_*)
   → Si humidité > seuil
   → Boost +2°C sur consigne
   → Priorité sur modes manuels/planning

3️⃣ MODE MANUEL PAR PIÈCE (input_select.mode_chauffage_*)
   → Si = Confort(19), Eco(18), etc.
   → Utilise température fixe
   → Priorité sur planning/global

4️⃣ MODE PLANNING HORAIRE ⭐ NOUVEAU
   → Aux 4 horaires (05:45, 08:00, 17:00, 22:30)
   → Met toutes pièces en MODEJOUR
   → Change température globale
   → Respecte vacances

5️⃣ MODE CHAUFFAGE GLOBAL (sensor.mode_chauffage_global_temperature)
   → Si pièce = MODEJOUR
   → Utilise température globale
   → Fallback: 18.5°C

6️⃣ PILOTAGE (Exécution)
   → Cycle: 3 min
   → Seuils: ±0.5°C
   → Zone morte = OFF
```

---

## 🎛️ CONTRÔLE MANUEL

### Changer le mode global temporairement

**Via l'interface:**
1. Helpers → `input_number.mode_chauffage_global`
2. Changer la valeur (ex: 20°C)
3. Toutes pièces en MODEJOUR suivront cette température
4. Au prochain créneau horaire → Valeur sera écrasée par le planning

---

### Sortir une pièce du planning

**Via l'interface:**
1. Input Select → `input_select.mode_chauffage_salon` (exemple)
2. Changer de MODEJOUR vers Confort(19) ou autre
3. Cette pièce ne suivra plus le planning
4. Au prochain créneau horaire → Sera remise en MODEJOUR

---

### Désactiver le planning complètement

**Option 1: Désactiver les automations**
- Paramètres → Automations
- Désactiver "Chauffage - Planning Automatique Horaire"
- Désactiver "Chauffage - Mise à jour Mode Global"

**Option 2: Changer manuellement toutes les pièces**
- Mettre chaque pièce sur un mode fixe (Confort, Eco, etc.)
- Le planning les remettra en MODEJOUR aux horaires
- Si tu veux éviter ça → Utilise Option 1

---

## 🧪 TESTS DE VALIDATION

### Test 1: Vérifier le mode global

```
1. Aller dans États des développeurs
2. Chercher: input_number.mode_chauffage_global
3. Vérifier valeur actuelle
4. Chercher: sensor.mode_chauffage_global_temperature
5. Vérifier que les 2 ont la même valeur
```

### Test 2: Tester MODEJOUR

```
1. Changer une pièce → MODEJOUR
2. Changer input_number.mode_chauffage_global à 20°C
3. Attendre 3 minutes
4. Vérifier que cette pièce chauffe vers 20°C
```

### Test 3: Tester planning (simulation)

```
1. Exécuter manuellement "Chauffage - Planning Automatique Horaire"
2. Vérifier que toutes pièces passent en MODEJOUR
3. Exécuter manuellement "Chauffage - Mise à jour Mode Global"
4. Vérifier que input_number change selon l'heure actuelle
```

---

## ✅ AVANTAGES DU SYSTÈME

**Flexibilité:**
- 🎛️ Contrôle global OU individuel
- 📅 Planning automatique personnalisable
- 🌡️ Température globale modifiable en temps réel

**Économies:**
- 💰 17°C pendant journée/nuit (absent)
- ⚡ 19°C uniquement matin/soir (présent)
- 🎯 Zone morte ±0.5°C (pas de sur-chauffe)

**Confort:**
- 🌡️ Température adaptée selon l'heure
- 💧 Boost humidité automatique
- 🏖️ Protection vacances (hors-gel)

**Contrôle:**
- 🔧 Chaque pièce modifiable individuellement
- 🚫 Mode vacances bloque tout
- 📊 Monitoring complet possible

---

## 🎉 SYSTÈME COMPLET ET OPÉRATIONNEL !

**Le système MODEJOUR + Planning Horaire est maintenant actif.**

Toutes les pièces suivront automatiquement le planning:
- **05:45** → 19°C (Confort Matin)
- **08:00** → 17°C (Éco Journée)
- **17:00** → 19°C (Confort Soir)
- **22:30** → 17°C (Hors-Gel Nuit)

Avec possibilité de:
- ✅ Modifier le mode global manuellement
- ✅ Sortir une pièce du planning
- ✅ Boost humidité automatique (+2°C)
- ✅ Mode vacances (hors-gel 16°C)

---

**Installation complétée avec succès !** 🚀
