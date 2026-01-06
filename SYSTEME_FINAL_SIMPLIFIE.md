# SYSTÈME FINAL SIMPLIFIÉ - CHAUFFAGE GAZ

**Date:** 20 décembre 2025
**Version:** Finale simplifiée

---

## 🎯 SYSTÈME RETENU

### Chauffage: GAZ uniquement
- ✅ Chaudière GAZ pilotée automatiquement
- ✅ TRV radiateurs (optionnel)
- ❌ Climatisations Broadlink = PAS UTILISÉES

### Raison
Le système GAZ suffit pour chauffer toute la maison.

---

## 📊 ORDRE DE PRIORITÉ (SIMPLIFIÉ)

```
1. MODE VACANCES (Priorité MAX)
   └─> 16°C hors-gel
   └─> BLOQUE tout

2. MODES MANUELS PAR PIÈCE (Priorité 2)
   └─> input_select.mode_chauffage_salon
   └─> input_select.mode_chauffage_cuisine
   └─> Consigne = MINIMUM des 2 pièces
   └─> Exemple: Salon 21°C + Cuisine 19°C → Chaudière 19°C

3. MODE PLANNING HORAIRE (Priorité 3)
   └─> 4 planifications/jour
   └─> Actif si modes manuels = STOP ou MODEJOUR

4. MODE CHAUFFAGE GLOBAL (Priorité 4)
   └─> sensor.mode_chauffage_global
   └─> Fallback par défaut: 18.5°C

5. PILOTAGE CHAUDIÈRE (Exécution)
   └─> automation.chauffage_pilotage_chaudiere_gaz
   └─> Seuils ±0.5°C
   └─> Cycle: Toutes les 3 min
```

---

## 🔧 AUTOMATIONS FINALES (2 fichiers)

### 1. Pilotage chaudière avec Mode Manuel

**Fichier:** `automation_chauffage_FINAL_avec_mode_manuel.yaml`

**Fonctionnement:**

```yaml
Consigne calculée:
  SI mode_vacances ON:
    → 16°C

  SINON SI modes manuels actifs:
    Salon: Extraire température (ex: "Confort2(19.5)" → 19.5)
    Cuisine: Extraire température
    → Consigne = MIN(Salon, Cuisine)

  SINON:
    → sensor.mode_chauffage_global (fallback 18.5°C)

Pilotage:
  SI au moins 1 pièce >= +0.5°C de delta:
    → ALLUMER chaudière

  SI toutes pièces <= -0.5°C de delta:
    → ÉTEINDRE chaudière

  SINON (zone morte -0.5 à +0.5):
    → MAINTENIR état actuel
```

**Changements vs version précédente:**
- ✅ Modes manuels prioritaires
- ✅ Consigne = minimum des pièces
- ✅ Seuils ±0.5°C maintenus
- ✅ Zone morte maintient état

### 2. Départ/Retour maison

**Fichier:** `automation_depart_retour_FINAL.yaml`

**Fonctionnement:**

```
DÉPART (zone.home → 0):
1. Créer scène "avant_depart" (sauvegarde modes actuels)
2. Passer Salon en Hors-Gel(16)
3. Passer Cuisine en Hors-Gel(16)

RETOUR (zone.home → 1+):
1. Délai 1 minute
2. Restaurer scène "avant_depart"
```

**Note:** Ce n'est PAS un "Mode Présence" modificateur, juste sauvegarde/restauration.

---

## 📥 INSTALLATION

### Étape 1: Automation chaudière (REMPLACER l'ancienne)

```
1. Automations → Chercher "Chauffage - Pilotage Chaudière GAZ"
2. Cliquer dessus
3. ... → Modifier au format YAML
4. TOUT sélectionner → Supprimer
5. Copier automation_chauffage_FINAL_avec_mode_manuel.yaml
6. COLLER
7. ENREGISTRER
```

### Étape 2: Automations Départ/Retour (CRÉER si n'existent pas)

**Départ:**
```
Automations → + CRÉER
→ ... → Modifier YAML
→ Copier première partie de automation_depart_retour_FINAL.yaml
→ ENREGISTRER
```

**Retour:**
```
Automations → + CRÉER
→ ... → Modifier YAML
→ Copier deuxième partie de automation_depart_retour_FINAL.yaml
→ ENREGISTRER
```

---

## ✅ VALIDATION

### Test 1: Mode Vacances

```
1. Activer: input_boolean.mode_vacance → ON
2. Attendre 3 minutes
3. Logs: Chercher "Consigne: 16"
4. Vérifier: Chaudière gère avec 16°C ✅
5. Désactiver mode vacances
```

### Test 2: Mode Manuel

```
1. Mode Salon → Confort3(21)
2. Mode Cuisine → Eco(18)
3. Attendre 3 minutes
4. Logs: Chercher "Consigne: 18"
5. Vérifier: Consigne = 18°C (minimum) ✅
```

### Test 3: Mode Manuel prioritaire

```
1. Mode Salon → Confort2(19.5)
2. Mode Cuisine → STOP
3. Attendre 3 minutes
4. Logs: Chercher "Consigne: 19.5"
5. Vérifier: Prend Salon même si Cuisine STOP ✅
```

### Test 4: Fallback mode global

```
1. Mode Salon → STOP
2. Mode Cuisine → STOP
3. Attendre 3 minutes
4. Logs: Chercher "Consigne"
5. Vérifier: Utilise sensor.mode_chauffage_global ✅
```

### Test 5: Départ/Retour

```
DÉPART:
1. Modes actuels: Salon Confort2(19.5), Cuisine Eco(18)
2. Changer zone.home → 0
3. Attendre 10 secondes
4. Vérifier: Modes = Hors-Gel(16) ✅
5. Vérifier: scene.avant_depart existe ✅

RETOUR:
6. Changer zone.home → 1
7. Attendre 1 minute
8. Vérifier: Salon = Confort2(19.5) ✅
9. Vérifier: Cuisine = Eco(18) ✅
```

---

## 📋 EXEMPLES CONCRETS

### Exemple 1: Journée normale

```
08:00 - Planning Matin
  → Mode global: Confort (19°C)
  → Chaudière chauffe jusqu'à 19°C

12:00 - Ajustement manuel Salon
  → Mode Salon: Confort3(21°C)
  → Mode Cuisine: reste MODEJOUR
  → Consigne: 21°C (Salon manuel prioritaire)

14:00 - Départ maison
  → zone.home → 0
  → Sauvegarde: Salon=Confort3(21), Cuisine=MODEJOUR
  → Passage: Hors-Gel(16°C)

18:00 - Retour maison
  → zone.home → 1
  → Restauration: Salon=Confort3(21), Cuisine=MODEJOUR
  → Chaudière chauffe à 21°C
```

### Exemple 2: Week-end froid

```
Samedi 10:00
  → Mode Salon: Confort3(21°C)
  → Mode Cuisine: Confort2(19.5°C)
  → Consigne: 19.5°C (minimum)
  → Toutes pièces chauffent

Dimanche matin
  → Modes manuels restent actifs
  → Consigne: 19.5°C maintenue
```

### Exemple 3: Vacances

```
Départ vacances:
  → Activer: mode_vacances
  → Consigne forcée: 16°C
  → Modes manuels IGNORÉS
  → Planning IGNORÉ
  → Chaudière maintient hors-gel

Retour vacances:
  → Désactiver: mode_vacances
  → Modes manuels reprennent priorité
```

---

## 🎯 AVANTAGES SYSTÈME SIMPLIFIÉ

### vs Version précédente

| Avant | Après |
|-------|-------|
| ❌ Modes manuels ignorés | ✅ Modes manuels prioritaires |
| ❌ Mode Présence incomplet | ✅ Supprimé (Départ/Retour simple) |
| ❌ Climatisations non fonctionnelles | ✅ Supprimées (GAZ suffit) |
| ❌ Complexité inutile | ✅ Système simple et clair |

### Points forts

1. ✅ **Mode Manuel fonctionne**
   - Consigne par pièce
   - Minimum des pièces = intelligent
   - Prioritaire sur planning

2. ✅ **Seuils précis**
   - ±0.5°C (2x plus réactif que ±1°C)
   - Zone morte maintient état
   - Moins d'oscillations

3. ✅ **Départ/Retour simple**
   - Sauvegarde automatique
   - Restauration au retour
   - Pas de complexité inutile

4. ✅ **Logs détaillés**
   - Toutes les 3 minutes
   - Températures affichées
   - Debugging facile

---

## 📁 FICHIERS DU SYSTÈME

### À installer (2 fichiers)

1. ✅ `automation_chauffage_FINAL_avec_mode_manuel.yaml`
2. ✅ `automation_depart_retour_FINAL.yaml`

### Documentation

1. ✅ `SYSTEME_FINAL_SIMPLIFIE.md` (ce fichier)
2. ✅ `GUIDE_INSTALLATION_SYSTEME_FINAL.md` (guide installation)

### À ignorer

- ❌ Tous fichiers climatisations
- ❌ Fichiers "Mode Présence" ancienne version
- ❌ Guides obsolètes

---

## 🚀 PROCHAINES ÉTAPES

### Immédiat

1. ✅ Installer automation chaudière FINAL
2. ✅ Tester modes manuels
3. ✅ Valider consigne minimum pièces

### Court terme

4. ✅ Installer automations Départ/Retour
5. ✅ Tester sauvegarde/restauration
6. ✅ Surveiller logs 24h

### Optionnel (plus tard)

- ⏳ Gestion TRV individuelle par pièce
- ⏳ Dashboard monitoring avancé
- ⏳ Statistiques consommation

---

## 📞 SUPPORT

### Problème Mode Manuel

**Vérifier:**
```
Logs → Chercher "Consigne"
→ Doit afficher la température du mode manuel
→ Pas sensor.mode_chauffage_global
```

**Si mode manuel ignoré:**
1. Vérifier automation chaudière = version FINAL
2. Vérifier modes != STOP ni MODEJOUR
3. Relancer automation manuellement

### Problème Départ/Retour

**Vérifier:**
```
Outils dev → États → scene.avant_depart
→ Doit exister après départ
```

**Si scène pas créée:**
1. Vérifier automation départ activée
2. Tester manuellement: zone.home → 0
3. Vérifier logs

---

**Système finalisé et simplifié!** ✅

**Installation:** 10 minutes
**Validation:** 5 tests
**Maintenance:** Automatique
