# GUIDE SIMPLIFIÉ - ORDRE DE PRIORITÉ CHAUFFAGE

## 🎯 RÉSUMÉ RAPIDE

Voici l'ordre de priorité des différents modes de chauffage dans ton système:

```
1️⃣ MODE VACANCES           → Force 16°C partout, bloque tout
2️⃣ MODE MANUEL PAR PIÈCE   → Contrôle manuel (Salon, Cuisine, Chambre)
3️⃣ MODE PRÉSENCE           → Passe en Éco si absence
4️⃣ MODE PLANNING HORAIRE   → Définit consignes 4x par jour
5️⃣ MODE CHAUFFAGE GLOBAL   → Consigne par défaut
6️⃣ PILOTAGE CHAUDIÈRE      → Exécute toutes les 3 min
```

---

## 📊 MODES DÉTAILLÉS

### 1️⃣ MODE VACANCES (Priorité ABSOLUE)

**Entité:** `input_boolean.mode_vacance`

**Quand activé:**
- ✅ Force **16°C** (hors-gel) partout
- ❌ Bloque le planning horaire
- ❌ Ignore tous les autres modes

**Usage:** Vacances ou absence prolongée

**Comment activer:**
- Dashboard principal
- App mobile
- Automation (si configurée)

**⚠️ ATTENTION:** Penser à le désactiver au retour!

---

### 2️⃣ MODE MANUEL PAR PIÈCE

**Entités:**
- `input_select.mode_chauffage_salon`
- `input_select.mode_chauffage_cuisine`
- `input_select.mode_chauffage_chambre` (à vérifier)

**Options typiques:**
- Confort2 (19.5°C)
- Éco2 (18.5°C)
- Hors-gel (16°C)
- OFF

**Priorité:** Écrase le planning horaire et le mode global POUR LA PIÈCE concernée

**Usage:** Contrôle manuel temporaire d'une pièce

---

### 3️⃣ MODE PRÉSENCE

**Déclencheur:** `zone.home = 0` (tout le monde parti)

**Action:**
- Passe le **Salon** en mode **Éco2 (18.5°C)**

**Automation:** `Chauffage Auto - Présence` (ligne 577 dans automations.yaml)

**Limite actuelle:** Agit uniquement sur le Salon

**Question:** Automation de retour à définir?

---

### 4️⃣ MODE PLANNING HORAIRE

**Automation:** `Chauffage - Planning Automatique Horaire`

**Programme:**

| Heure | Mode | Consigne | Action |
|-------|------|----------|--------|
| 05:45 | Confort matin | 19°C | Réveil |
| 08:00 | Éco journée | 18.5°C | Jour |
| 17:00 | Confort soir | 19°C | Retour |
| 22:30 | Hors-gel nuit | 16°C | Nuit |

**Actions:**
- Désactive le mode nuit
- Configure les 3 TRV (vannes thermostatiques)
- Allume le thermostat chaudière

**Condition:** Ne fonctionne QUE si `mode_vacance = OFF`

---

### 5️⃣ MODE CHAUFFAGE GLOBAL

**Entité:** `sensor.mode_chauffage_global`

**Rôle:**
- Fournit la consigne par défaut
- Utilisé par le pilotage chaudière et climatisations
- Agrège ou calcule la consigne selon contexte

**Logique:**
```
SI mode_vacance = ON → 16°C
SINON → sensor.mode_chauffage_global (défaut 18.5°C)
```

**Question:** Comment est calculé ce sensor? (à vérifier dans configuration.yaml)

---

### 6️⃣ PILOTAGE CHAUDIÈRE (Exécution)

**Automation:** `Chauffage - Pilotage Chaudière GAZ`

**Fréquence:** Toutes les **3 minutes**

**Logique de décision:**

#### SEUILS AVANT CORRECTION (±1°C):
- **Allume** si ≥1 pièce à **-1°C** ou plus de la consigne
- **Éteint** si TOUTES les pièces à **+1°C** ou plus de la consigne
- **Zone morte:** Entre -1°C et +1°C → Éteint (PROBLÈME!)

#### SEUILS APRÈS CORRECTION (±0.5°C):
- **Allume** si ≥1 pièce à **-0.5°C** ou plus de la consigne
- **Éteint** si TOUTES les pièces à **+0.5°C** ou plus de la consigne
- **Zone morte:** Entre -0.5°C et +0.5°C → **MAINTIEN état actuel** (CORRIGÉ!)

**Pièces surveillées:**
- Cuisine (`sensor.th_cuisine_temperature`)
- Parents (`sensor.th_parents_temperature`)
- Loann (`sensor.th_loann_temperature`)

---

## 🔄 ARBRE DE DÉCISION COMPLET

```
┌─────────────────────────────────┐
│  Mode Vacances activé?          │
└─────────┬───────────────────────┘
          │
    OUI ──┤                    NON
          │                     │
          ▼                     ▼
    ┌──────────┐      ┌──────────────────────┐
    │ 16°C     │      │ Mode Manuel activé?  │
    │ (Partout)│      │ (pour cette pièce)   │
    └──────────┘      └─────────┬────────────┘
                                │
                          OUI ──┤         NON
                                │          │
                                ▼          ▼
                          ┌──────────┐  ┌─────────────────┐
                          │ Consigne │  │ Présence = 0?   │
                          │ Manuelle │  └────────┬────────┘
                          └──────────┘           │
                                           OUI ──┤   NON
                                                 │    │
                                                 ▼    ▼
                                           ┌──────┐ ┌──────────────────┐
                                           │18.5°C│ │ Planning horaire │
                                           │(Salon)│ │ (05:45/08:00/   │
                                           └──────┘ │ 17:00/22:30)    │
                                                    └────────┬─────────┘
                                                             │
                                                             ▼
                                                    ┌─────────────────┐
                                                    │ Mode Chauffage  │
                                                    │ Global          │
                                                    │ (défaut 18.5°C) │
                                                    └────────┬────────┘
                                                             │
                                                             ▼
                                                    ┌─────────────────┐
                                                    │ Pilotage        │
                                                    │ Chaudière       │
                                                    │ (toutes 3 min)  │
                                                    └─────────────────┘
```

---

## 📝 EXEMPLE CONCRET

**Situation:** Mardi 10h00, tout le monde présent, mode vacances OFF

### Étape 1: Calcul de la consigne

1. ✅ Mode vacances OFF → Continue
2. ❓ Mode manuel Salon → Non défini → Continue
3. ❓ Présence → Oui (zone.home > 0) → Continue
4. ✅ Planning horaire → 10h = "Éco journée" → **Consigne = 18.5°C**

### Étape 2: Pilotage chaudière (toutes les 3 min)

**Températures mesurées:**
- Cuisine: 18.2°C
- Parents: 18.8°C
- Loann: 18.4°C

**Calcul deltas:**
- Delta Cuisine: 18.5 - 18.2 = **+0.3°C**
- Delta Parents: 18.5 - 18.8 = **-0.3°C**
- Delta Loann: 18.5 - 18.4 = **+0.1°C**

**Décision avec seuils ±0.5°C:**
- Besoin chauffage? NON (aucun delta >= +0.5°C)
- Trop chaud? NON (aucun delta <= -0.5°C)
- → **ZONE MORTE** → Maintien état chaudière actuel

**Décision avec anciens seuils ±1°C:**
- Besoin chauffage? NON (aucun delta >= +1°C)
- Trop chaud? NON (aucun delta <= -1°C)
- → **DEFAULT** → Éteint chaudière ❌ (PROBLÈME!)

---

## ⚙️ MODIFICATIONS APPORTÉES

### 1. Seuils température

**Avant:** ±1°C
**Après:** ±0.5°C

**Impact:**
- ✅ 2x plus réactif
- ✅ Températures plus stables
- ✅ Meilleur confort

### 2. Logique zone morte

**Avant:** Zone morte → Éteint chaudière
**Après:** Zone morte → Maintien état actuel

**Impact:**
- ✅ Évite oscillations
- ✅ Moins de cycles on/off
- ✅ Meilleure durée de vie chaudière

---

## 📁 FICHIERS CRÉÉS

1. **[ANALYSE_PRIORITES_CHAUFFAGE.md](ANALYSE_PRIORITES_CHAUFFAGE.md)**
   - Analyse technique complète
   - Tous les modes identifiés
   - Problèmes détectés

2. **[automation_chauffage_pilotage_chaudiere_corrigee.yaml](automation_chauffage_pilotage_chaudiere_corrigee.yaml)**
   - Automation corrigée avec seuils ±0.5°C
   - Logique zone morte fixée
   - Commentaires explicatifs détaillés

3. **Ce guide [GUIDE_ORDRE_PRIORITE_CHAUFFAGE.md](GUIDE_ORDRE_PRIORITE_CHAUFFAGE.md)**
   - Version simplifiée
   - Arbre de décision visuel
   - Exemples concrets

---

## 🚀 INSTALLATION

### Remplacer l'automation actuelle

1. **Sauvegarder l'ancienne (IMPORTANT!):**
   ```bash
   cp automations.yaml automations.yaml.backup
   ```

2. **Ouvrir automations.yaml:**
   - Fichier → Modificateur de fichiers → automations.yaml

3. **Trouver l'automation:**
   - Chercher `id: chauffage_gaz_control`
   - Ligne 64 dans le fichier actuel

4. **Remplacer ENTIÈREMENT** l'automation:
   - Depuis `- id: chauffage_gaz_control` (ligne 64)
   - Jusqu'à `mode: single` (ligne 102)
   - Par le contenu de `automation_chauffage_pilotage_chaudiere_corrigee.yaml`

5. **Sauvegarder** le fichier

6. **Recharger les automations:**
   - Outils de développement → YAML
   - Cliquer sur "AUTOMATIONS" → Recharger

7. **Vérifier:**
   - Paramètres → Automations
   - Chercher "Chauffage - Pilotage Chaudière GAZ"
   - Cliquer dessus → Vérifier que les modifications apparaissent

---

## 🧪 TESTS RECOMMANDÉS

### Test 1: Vérifier les seuils

1. Noter la température actuelle d'une pièce
2. Ajuster la consigne à **température + 0.6°C**
3. Attendre 3 minutes
4. Vérifier que la chaudière s'allume

### Test 2: Zone morte

1. Consigne = Température (delta = 0°C)
2. Attendre 3 minutes
3. Vérifier que la chaudière MAINTIENT son état (ne s'éteint pas)

### Test 3: Logs

1. Outils de développement → Logs
2. Chercher "ZONE MORTE" ou "ALLUMAGE" ou "EXTINCTION"
3. Vérifier que les messages apparaissent toutes les 3 min

---

## ⚠️ POINTS D'ATTENTION

### 1. Modes manuels par pièce

**À clarifier:**
- Comment sont-ils utilisés actuellement?
- Sont-ils prioritaires sur le planning?
- Où les définir?

### 2. Mode présence

**Limite actuelle:** Agit uniquement sur le Salon

**À faire:**
- Créer automation de retour?
- Étendre aux autres pièces?

### 3. Mode chauffage global

**Question:** Comment est calculé `sensor.mode_chauffage_global`?

**À vérifier:**
- Dans `configuration.yaml` ou `sensors.yaml`
- Est-ce un helper ou un template sensor?

---

## 💡 AMÉLIORATIONS FUTURES

### 1. Dashboard de contrôle

Créer une vue avec:
- État de tous les modes
- Priorité active actuelle
- Températures et consignes par pièce
- Logs en temps réel

### 2. Unification des modes

Créer un `input_select.mode_prioritaire` avec:
- Auto (planning horaire)
- Manuel
- Présence
- Vacances
- Nuit

### 3. Automation de retour présence

Quand quelqu'un rentre (`zone.home > 0`):
- Restaurer le mode précédent
- Ou passer en mode confort

---

Tout est prêt pour être installé! Veux-tu que je clarifie un point ou que je crée d'autres automations?
