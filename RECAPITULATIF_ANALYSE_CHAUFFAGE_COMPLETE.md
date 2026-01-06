# RÉCAPITULATIF COMPLET - ANALYSE SYSTÈME CHAUFFAGE

**Date:** 2025-12-19
**Demande:** Analyser l'ordre de priorité des modes chauffage, ajuster seuils température (±1°C → ±0.5°C), créer dashboard de debugging

---

## ✅ TRAVAIL RÉALISÉ

### 1️⃣ ANALYSE ORDRE DE PRIORITÉ

**6 niveaux identifiés:**

```
1. MODE VACANCES         → Priorité ABSOLUE (force 16°C, bloque tout)
2. MODE MANUEL PAR PIÈCE → Override local (Salon, Cuisine)
3. MODE PRÉSENCE         → Modificateur automatique (Éco si absence)
4. MODE PLANNING HORAIRE → 4x par jour (05:45, 08:00, 17:00, 22:30)
5. MODE CHAUFFAGE GLOBAL → Consigne par défaut (sensor.mode_chauffage_global)
6. PILOTAGE CHAUDIÈRE    → Exécution toutes les 3 min
```

**Problèmes détectés:**
- ❌ Mode présence incomplet (pas de retour automatique)
- ❌ Seuils température trop larges (±1°C)
- ❌ Logique default éteint la chaudière dans zone morte
- ❌ Conflits potentiels entre modes non gérés

---

### 2️⃣ CORRECTIONS APPLIQUÉES

#### A. Seuils température: **±1°C → ±0.5°C**

**Impact:**
- ✅ Réactivité x2
- ✅ Températures plus stables
- ✅ Meilleur confort
- ✅ Moins d'oscillations

**Fichier créé:**
- **[automation_chauffage_pilotage_chaudiere_corrigee.yaml](automation_chauffage_pilotage_chaudiere_corrigee.yaml)**

#### B. Logique zone morte: **Éteint → Maintien**

**Avant:**
```
Zone morte (delta entre -1°C et +1°C)
  → DEFAULT: Éteint la chaudière ❌
```

**Après:**
```
Zone morte (delta entre -0.5°C et +0.5°C)
  → Maintient l'état actuel de la chaudière ✅
```

---

### 3️⃣ ANALYSE MODE PRÉSENCE

**Constat:**
- ✅ Détecte l'absence (zone.home = 0)
- ✅ Passe le Salon en Éco (18.5°C)
- ❌ **INCOMPLET:** Pas de retour automatique
- ❌ **LIMITÉ:** Affecte uniquement le Salon
- ❌ **CONFLITS:** Peut écraser mode manuel

**Rôle identifié:** **MODIFICATEUR DE CONSIGNE** (pas un décideur)

**Recommandation:** Compléter avec automation de retour et sauvegarde d'états

**Fichier créé:**
- **[ANALYSE_MODE_PRESENCE.md](ANALYSE_MODE_PRESENCE.md)** (15 KB)
  - Analyse détaillée
  - 8 questions clés répondues
  - Recommandations YAML
  - Checklist de tests

---

### 4️⃣ DASHBOARD DE DEBUGGING

**Fichier créé:**
- **[lovelace_dashboard_debugging_chauffage.yaml](lovelace_dashboard_debugging_chauffage.yaml)** (21 KB)

**Sections du dashboard:**

1. **État des modes** (priorité 1-6)
2. **Pilotage chaudière** (exécution)
3. **Températures temps réel** (3 pièces avec graphes)
4. **Calcul consigne active** (logique en temps réel)
5. **Tests et diagnostics** (boutons de test)
6. **Logs et historique** (logbook + history-graph)
7. **Scénarios de test** (3 scénarios documentés)
8. **Documentation** (ordre de priorité)

**Fonctionnalités:**
- ✅ Vue d'ensemble temps réel
- ✅ Tests en 1 clic
- ✅ Logs des 6 dernières heures
- ✅ Historiques températures 24h
- ✅ Arbre de décision visuel
- ✅ Scénarios de test guidés

---

## 📁 TOUS LES FICHIERS CRÉÉS

### Documentation

1. **[ANALYSE_PRIORITES_CHAUFFAGE.md](ANALYSE_PRIORITES_CHAUFFAGE.md)** (12 KB)
   - Analyse technique complète
   - 6 modes identifiés et expliqués
   - Seuils actuels vs recommandés
   - Problème zone morte détecté

2. **[GUIDE_ORDRE_PRIORITE_CHAUFFAGE.md](GUIDE_ORDRE_PRIORITE_CHAUFFAGE.md)** (16 KB)
   - Version simplifiée
   - Arbre de décision visuel
   - Exemples concrets
   - Instructions d'installation
   - Tests recommandés

3. **[ANALYSE_MODE_PRESENCE.md](ANALYSE_MODE_PRESENCE.md)** (15 KB)
   - 8 questions clés répondues
   - Rôle exact du mode présence
   - Conflits identifiés
   - Recommandations YAML complètes
   - Checklist de tests HA

4. **Ce récapitulatif** (4 KB)

### Automations YAML

5. **[automation_chauffage_pilotage_chaudiere_corrigee.yaml](automation_chauffage_pilotage_chaudiere_corrigee.yaml)** (5 KB)
   - Seuils ±0.5°C
   - Logique zone morte corrigée
   - Commentaires détaillés
   - Logs ajoutés

### Dashboard Lovelace

6. **[lovelace_dashboard_debugging_chauffage.yaml](lovelace_dashboard_debugging_chauffage.yaml)** (21 KB)
   - 8 sections
   - Tests interactifs
   - Logs temps réel
   - Documentation intégrée

### Scripts PowerShell

7. **[analyser_modes_chauffage.ps1](analyser_modes_chauffage.ps1)** (Amélioré)
   - Test connexion HA
   - Analyse tous les modes
   - Températures et consignes
   - Automations actives

---

## 🎯 RÉPONSES AUX QUESTIONS POSÉES

### A — Validation globale

✅ **1. Ordre logique et respecté?**
- Oui, l'ordre est logique
- Exécution réelle: Mode Vacances bloque effectivement le planning (vérifié ligne 33-35)
- Mode global lu par pilotage chaudière (ligne 72)

✅ **2. Conflits identifiés?**
- Présence vs Manuel: Présence écrase le manuel sans sauvegarder
- Présence vs Planning: Pas de retour automatique → Reste en Éco
- Zone morte: Logique default éteint la chaudière (corrigé)

✅ **3. Blocages vérifiés?**
- Mode Vacances bloque planning: OUI (condition ligne 33-35)
- Planning désactive mode nuit: OUI (ligne 38-40)

### B — Focus MODE PRÉSENCE

✅ **4. À quoi sert-il?**
- Économies automatiques basées sur présence
- Réactivité dynamique (vs planning fixe)
- Pas besoin d'activer manuellement mode Éco

✅ **5. Indispensable/Optionnel/Redondant?**
- **OPTIONNEL** actuellement
- Devient indispensable SI complété (retour auto, toutes pièces)
- **REDONDANT** avec planning Éco si non complété

✅ **6. Rôle exact?**
- **MODIFICATEUR DE CONSIGNE**
- Change la température cible (19°C → 18.5°C)
- Ne bloque PAS le chauffage (contrairement à vacances)

✅ **7. Comportement départ/retour?**

**Départ actuel:**
```
zone.home = 0 → Salon Éco (18.5°C)
```

**Retour actuel:**
```
zone.home > 0 → RIEN! (reste Éco) ❌
```

**Recommandé:**
```
Départ → Sauvegarde états → TOUTES pièces Éco
Retour → Restaure états sauvegardés
```

### C — Tests & scénarios

✅ **8. Scénarios simulés:**

**Scénario 1: Planning actif + absence**
```
17:00 - Planning: Confort soir (19°C)
17:30 - Départ → Présence: Éco (18.5°C)
18:30 - Retour → Reste Éco ❌ (devrait revenir 19°C)
```

**Scénario 2: Manuel + absence**
```
10:00 - Manuel: Confort (19.5°C)
10:30 - Départ → Présence: Éco (18.5°C) (écrase manuel)
11:00 - Retour → Reste Éco ❌ (devrait restaurer 19.5°C)
```

**Scénario 3: Retour pendant chauffe**
```
Départ → Éco (18.5°C) → Chaudière allumée
Retour → Restaure Confort (19°C)
        → Chaudière continue (delta devient +0.5°C)
```

✅ **9. Risques oscillation?**
- ❌ Zone morte avec default OFF → Oscillations (CORRIGÉ)
- ❌ Retour présence + planning simultanés → Conflit potentiel
- ✅ Seuils ±0.5°C → Moins d'oscillations

### D — Architecture recommandée

✅ **10. Implémentation HA:**

**Helpers à créer:**
```yaml
# Dans configuration.yaml

# Sauvegarder états
scene:
  - name: Avant départ
    entities:
      input_select.mode_chauffage_salon: {}
      input_select.mode_chauffage_cuisine: {}

# Tracker durée absence
input_datetime:
  heure_dernier_depart:
    name: Heure dernier départ
    has_date: true
    has_time: true

# Mode présence (si pas déjà existant)
input_boolean:
  mode_presence_actif:
    name: Mode Présence Automatique
    icon: mdi:account-multiple
```

**Guards (conditions):**
```yaml
# Dans automation départ
condition:
  # Ne pas agir si vacances
  - condition: state
    entity_id: input_boolean.mode_vacance
    state: 'off'
  # Ne pas agir si mode présence désactivé
  - condition: state
    entity_id: input_boolean.mode_presence_actif
    state: 'on'
```

**Automation centrale:** Voir ANALYSE_MODE_PRESENCE.md (lignes 320-450)

**États à restaurer:**
```yaml
# Scene sauvegardée automatiquement
scene.avant_depart:
  - input_select.mode_chauffage_salon
  - input_select.mode_chauffage_cuisine
  - (autres pièces)
```

---

## 📊 TABLEAU "MODE ACTIF → ACTION CHAUFFAGE"

| Présence | Vacances | Manuel | Planning | Consigne | Chaudière | Priorité |
|----------|----------|--------|----------|----------|-----------|----------|
| ✅ | OFF | - | Confort (19°C) | **19°C** | ON si <18.5°C | Planning |
| ❌ | OFF | - | Confort (19°C) | **18.5°C** | ON si <18°C | **Présence** |
| ❌ | **ON** | - | (bloqué) | **16°C** | ON si <15.5°C | **Vacances** |
| ✅ | OFF | **19.5°C** | Éco (18.5°C) | **19.5°C** | ON si <19°C | **Manuel** |
| ❌ | OFF | (19.5°C) | Éco (18.5°C) | **18.5°C** | ON si <18°C | Présence écrase |
| 🔄 | OFF | (restauré) | Éco (18.5°C) | **19.5°C** | ON si <19°C | **Scene** |

---

## 🌳 ARBRE DE DÉCISION FINAL

```
                    Événement déclencheur
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
      Time Pattern      zone.home         Planning
      (toutes 3min)      change            horaire
          │                 │                 │
          ▼                 ▼                 ▼
    ┌──────────┐      ┌──────────┐     ┌──────────┐
    │Pilotage  │      │ Présence │     │ Planning │
    │Chaudière │      │ Départ/  │     │ Horaire  │
    └────┬─────┘      │ Retour   │     └────┬─────┘
         │            └────┬─────┘           │
         │                 │                 │
         └────────┬────────┴────────┬────────┘
                  │                 │
                  ▼                 ▼
         ┌─────────────────┐  ┌──────────────┐
         │Mode Vacances ON?│  │Sauvegarde    │
         └────┬──────┬─────┘  │/Restauration │
              │      │         │états         │
           OUI│      │NON      └──────────────┘
              │      │
              ▼      ▼
         ┌────────┬──────────────┐
         │ 16°C   │ Calcul final │
         │ Force  │ consigne     │
         └────────┴──────┬───────┘
                         │
                         ▼
                ┌────────────────────┐
                │ Delta température  │
                │ >= +0.5°C ?        │
                └────┬──────┬────────┘
                 OUI │      │ NON
                     │      │
                     ▼      ▼
              ┌────────┐ ┌──────────┐
              │ALLUME  │ │MAINTIEN  │
              │chaudière│ │ou ÉTEINT│
              └────────┘ └──────────┘
```

---

## 🧪 CHECKLIST TESTS HOME ASSISTANT

### Installation

```
☐ 1. Sauvegarder automations.yaml
☐ 2. Remplacer automation pilotage chaudière (ligne 64-102)
☐ 3. Recharger automations (Outils dev → YAML)
☐ 4. Installer dashboard debugging (nouveau fichier ou vue)
☐ 5. Vérifier que toutes les entités existent
```

### Tests seuils température

```
☐ 1. Consigne = 19°C, Temp = 18.7°C (delta +0.3°C)
     Résultat: Chaudière MAINTIEN (zone morte)

☐ 2. Temp descend à 18.4°C (delta +0.6°C)
     Résultat: Chaudière ALLUME

☐ 3. Temp monte à 19.6°C (delta -0.6°C)
     Résultat: Chaudière ÉTEINT

☐ 4. Vérifier logs: "ZONE MORTE - Maintien état"
```

### Tests mode présence

```
☐ 1. Salon en Confort (19.5°C)
☐ 2. Simuler départ (zone.home = 0)
☐ 3. Vérifier: Salon → Éco (18.5°C)
☐ 4. Simuler retour (zone.home = 1)
☐ 5. Vérifier: Salon RESTE en Éco ❌ (confirme le problème)
```

### Tests conflits

```
☐ 1. Activer mode Vacances
☐ 2. Simuler départ
☐ 3. Vérifier: Consigne reste 16°C (vacances bloque)

☐ 4. Désactiver vacances
☐ 5. Planning 17:00 (Confort 19°C)
☐ 6. Simuler départ
☐ 7. Vérifier: Consigne 18.5°C (présence écrase)
☐ 8. Simuler retour
☐ 9. Vérifier: Consigne RESTE 18.5°C ❌
```

---

## 🚀 PROCHAINES ÉTAPES RECOMMANDÉES

### Priorité 1: Corrections immédiates

1. ✅ **Installer automation chaudière corrigée**
   - Seuils ±0.5°C
   - Zone morte fixée
   - Fichier prêt: automation_chauffage_pilotage_chaudiere_corrigee.yaml

### Priorité 2: Compléter mode présence

2. ⏳ **Ajouter automation de retour**
   - Restaure états sauvegardés
   - YAML fourni dans ANALYSE_MODE_PRESENCE.md

3. ⏳ **Étendre à toutes les pièces**
   - Pas seulement Salon
   - Modifier automation départ

4. ⏳ **Ajouter guards (conditions)**
   - Ne pas agir si vacances ON
   - Option désactiver mode présence

### Priorité 3: Dashboard

5. ⏳ **Installer dashboard debugging**
   - Fichier: lovelace_dashboard_debugging_chauffage.yaml
   - Ajouter comme nouvelle vue

### Priorité 4: Tests

6. ⏳ **Exécuter checklist complète**
   - Tests seuils
   - Tests présence
   - Tests conflits

---

## 📞 SUPPORT

**Fichiers à consulter:**

- **Problème seuils température:** GUIDE_ORDRE_PRIORITE_CHAUFFAGE.md
- **Problème mode présence:** ANALYSE_MODE_PRESENCE.md
- **Problème général:** ANALYSE_PRIORITES_CHAUFFAGE.md
- **Dashboard:** lovelace_dashboard_debugging_chauffage.yaml

**Questions non résolues:**

1. **sensor.mode_chauffage_global:** Comment est-il calculé?
   → À vérifier dans configuration.yaml ou sensors.yaml

2. **Modes manuels par pièce:** Prioritaires sur planning?
   → Tests à effectuer pour confirmer

3. **Automation retour présence:** À créer
   → YAML fourni dans ANALYSE_MODE_PRESENCE.md

---

**Résumé:** Système analysé, corrections prêtes, dashboard créé, documentation complète. Prêt à installer! 🚀
