# ANALYSE COMPLÈTE - MODE PRÉSENCE

## 🎯 RÉSUMÉ EXÉCUTIF

**Situation actuelle:**
Le MODE PRÉSENCE existe dans ton système mais est **incomplet et limité**:
- ✅ Détecte l'absence (zone.home = 0)
- ✅ Passe le Salon en mode Éco (18.5°C)
- ❌ **PAS d'automation de retour**
- ❌ Affecte uniquement le Salon
- ❌ Conflit potentiel avec mode manuel non géré

**Rôle réel:** **MODIFICATEUR DE CONSIGNE** (pas un décideur absolu)

**Recommandation:** Compléter le système ou le désactiver pour éviter les incohérences.

---

## 📊 ÉTAT ACTUEL DU MODE PRÉSENCE

### Automation existante

**Fichier:** `automations.yaml` ligne 577
**Nom:** `Chauffage Auto - Présence`

```yaml
triggers:
  - entity_id: zone.home
    to: '0'  # Quand zone.home passe à 0 (plus personne)
    trigger: state
actions:
  - data:
      entity_id: input_select.mode_chauffage_salon
      option: Eco2(18.5)
    action: input_select.select_option
```

### Ce qu'elle fait:

1. **Déclencheur:** `zone.home` passe à `0` (tout le monde est parti)
2. **Action:** Change `input_select.mode_chauffage_salon` → `Eco2(18.5)`
3. **Portée:** **UNIQUEMENT LE SALON**
4. **Retour:** **AUCUNE automation de retour**

---

## ❓ QUESTIONS CLÉS - RÉPONSES

### 1️⃣ À quoi sert le MODE PRÉSENCE?

**Réponse:**
Économiser l'énergie automatiquement quand tout le monde est absent, sans avoir à activer manuellement le mode Éco ou Vacances.

**Différence avec Planning:**
- **Planning:** Change de consigne selon l'heure (05:45, 08:00, 17:00, 22:30)
- **Présence:** Change de consigne selon la présence (présent/absent)

**Exemple concret:**
```
10h00 - Planning actif: Éco journée (18.5°C)
10h30 - Tout le monde part → Présence passe Salon en Éco (18.5°C)

17h00 - Planning actif: Confort soir (19°C)
17h30 - Tout le monde part → Présence passe Salon en Éco (18.5°C)
         ⚠️ Écrase le planning!
```

### 2️⃣ Ce qu'il apporte que le planning ne fait pas?

✅ **Réactivité à la présence réelle:**
- Planning: change selon l'heure (fixe)
- Présence: change selon qui est là (dynamique)

✅ **Économies d'énergie:**
- Évite de chauffer en mode Confort quand personne n'est là

❌ **Mais limites importantes:**
- Ne gère que le Salon
- Pas de retour automatique
- Peut entrer en conflit avec mode manuel

### 3️⃣ Ce qu'il apporte que le mode manuel ne fait pas?

✅ **Automatisme:**
- Mode manuel: tu changes manuellement
- Mode présence: change automatiquement quand tu pars

❌ **Mais conflit:**
```
Scénario problématique:
1. Tu mets manuellement Salon en Confort (19.5°C)
2. Tu pars (zone.home = 0)
3. Mode présence écrase et met Éco (18.5°C)
4. Tu rentres
5. Consigne reste en Éco! (pas de retour automatique)
```

### 4️⃣ Est-il indispensable, optionnel ou redondant?

**Réponse: OPTIONNEL avec conditions**

**Indispensable SI:**
- ✅ Tu veux des économies automatiques basées sur la présence
- ✅ Tu complètes le système (retour, toutes pièces, gestion conflits)
- ✅ Tu utilises la géolocalisation (zone.home)

**Redondant SI:**
- ❌ Le planning Éco journée (08:00-17:00) couvre déjà les absences
- ❌ Tu actives manuellement le mode Éco quand tu pars
- ❌ Tu utilises déjà le mode Vacances pour absences longues

**Recommandation actuelle:** **REDONDANT ET INCOMPLET**

Pourquoi?
- Planning Éco journée = 18.5°C (même consigne que mode présence)
- Pas de retour automatique → Perte de confort au retour
- Affecte uniquement Salon → Incohérent

### 5️⃣ Rôle exact: Décideur, Modificateur ou Filtre?

**Réponse: MODIFICATEUR DE CONSIGNE**

**Définitions:**
- **Décideur:** Décide s'il faut chauffer ou non (ex: mode vacances bloque tout)
- **Modificateur:** Change la consigne mais ne bloque rien (ex: présence passe en Éco)
- **Filtre:** Autorise/interdit le chauffage (ex: condition if/else)

**Mode présence actuel:**
```yaml
# C'est un MODIFICATEUR:
- action: input_select.select_option
  data:
    entity_id: input_select.mode_chauffage_salon
    option: Eco2(18.5)  # MODIFIE la consigne
```

**Il ne décide PAS** s'il faut chauffer, il change juste la cible de 19°C à 18.5°C.

### 6️⃣ Que doit-il se passer à l'absence?

**Comportement actuel:**
```
Absence détectée (zone.home = 0)
  ↓
Salon → Eco2(18.5°C)
  ↓
Autres pièces → Inchangées
```

**Comportement recommandé:**
```
Absence détectée (zone.home = 0)
  ↓
TOUTES les pièces → Eco (16-17°C)
  ↓
OU Mode Vacances automatique si absence > X heures
```

### 7️⃣ Que doit-il se passer au retour de présence?

**Comportement actuel:**
```
Retour détecté (zone.home > 0)
  ↓
RIEN! ❌
  ↓
Salon reste en Éco (18.5°C)
  ↓
Il faut changer manuellement ou attendre le prochain planning
```

**Comportement recommandé - OPTION A (Simple):**
```
Retour détecté (zone.home > 0)
  ↓
Restaurer consigne planning actuelle
  ↓
Exemple: 18h = Confort soir (19°C)
```

**Comportement recommandé - OPTION B (Intelligent):**
```
Retour détecté (zone.home > 0)
  ↓
SI mode manuel était actif avant départ
  → Restaurer mode manuel
SINON
  → Restaurer consigne planning
```

### 8️⃣ Conflit avec planning ou manuel?

**Conflits identifiés:**

#### Conflit 1: Présence vs Planning
```
17:00 - Planning: Confort soir (19°C)
17:30 - Départ (zone.home = 0)
        → Présence: Salon Éco (18.5°C)
18:30 - Retour (zone.home > 0)
        → Aucun changement! Reste Éco
        → Planning ne se redéclenche qu'à 22:30
```

**Solution:** Automation de retour qui restaure la consigne planning.

#### Conflit 2: Présence vs Mode Manuel
```
10:00 - Manuel: Salon Confort (19.5°C)
10:30 - Départ (zone.home = 0)
        → Présence: Salon Éco (18.5°C) ← Écrase le manuel!
11:00 - Retour (zone.home > 0)
        → Reste Éco! ← Manuel perdu
```

**Solution:** Sauvegarder l'état avant départ et le restaurer au retour.

#### Conflit 3: Présence vs Vacances
```
Mode Vacances ON (16°C)
  ↓
Départ (zone.home = 0)
  ↓
Présence: Salon Éco (18.5°C) ← Écrase vacances! ❌
```

**Solution:** Ajouter condition: ne pas agir si mode vacances actif.

---

## 🔧 RECOMMANDATIONS YAML

### Option 1: COMPLÉTER LE SYSTÈME (Recommandé)

#### A. Automation de départ (améliorer l'existante)

```yaml
id: chauffage_auto_presence_depart
alias: Chauffage - Départ (Absence détectée)
description: Passe en mode Éco quand tout le monde est parti

trigger:
  - platform: state
    entity_id: zone.home
    to: '0'
    for: '00:05:00'  # Attendre 5 min pour éviter faux positifs

condition:
  # Ne pas agir si mode vacances déjà actif
  - condition: state
    entity_id: input_boolean.mode_vacance
    state: 'off'

action:
  # Sauvegarder les états actuels AVANT de changer
  - service: scene.create
    data:
      scene_id: avant_depart
      snapshot_entities:
        - input_select.mode_chauffage_salon
        - input_select.mode_chauffage_cuisine
        # Ajouter autres pièces

  # Notification (optionnel)
  - service: telegram_bot.send_message
    data:
      chat_id: 8486475897
      message: |
        🚪 Départ détecté
        Passage en mode Éco automatique

  # Passer TOUTES les pièces en mode Éco
  - service: input_select.select_option
    data:
      entity_id:
        - input_select.mode_chauffage_salon
        - input_select.mode_chauffage_cuisine
        # Ajouter autres pièces
      option: "Eco2(18.5)"

mode: single
```

#### B. Automation de retour (NOUVELLE)

```yaml
id: chauffage_auto_presence_retour
alias: Chauffage - Retour (Présence détectée)
description: Restaure les consignes quand quelqu'un rentre

trigger:
  - platform: state
    entity_id: zone.home
    from: '0'

condition:
  - condition: state
    entity_id: input_boolean.mode_vacance
    state: 'off'

action:
  # Notification (optionnel)
  - service: telegram_bot.send_message
    data:
      chat_id: 8486475897
      message: "🏠 Retour détecté - Restauration consignes"

  # Restaurer les états sauvegardés
  - service: scene.turn_on
    target:
      entity_id: scene.avant_depart

mode: single
```

#### C. Amélioration avec input_datetime pour absences longues

```yaml
# Dans configuration.yaml - Créer un helper
input_datetime:
  heure_dernier_depart:
    name: Heure dernier départ
    has_date: true
    has_time: true

# Automation départ - Sauvegarder l'heure
- id: save_departure_time
  trigger:
    - platform: state
      entity_id: zone.home
      to: '0'
  action:
    - service: input_datetime.set_datetime
      target:
        entity_id: input_datetime.heure_dernier_depart
      data:
        datetime: "{{ now() }}"

# Automation retour - Vérifier durée absence
- id: chauffage_retour_intelligent
  trigger:
    - platform: state
      entity_id: zone.home
      from: '0'
  action:
    - variables:
        duree_absence: >
          {{ (now() - states('input_datetime.heure_dernier_depart') | as_datetime).total_seconds() / 3600 }}
    - choose:
        # Si absence < 4h: Restaurer états
        - conditions:
            - condition: template
              value_template: "{{ duree_absence < 4 }}"
          sequence:
            - service: scene.turn_on
              target:
                entity_id: scene.avant_depart

        # Si absence >= 4h: Activer progressivement
        - conditions:
            - condition: template
              value_template: "{{ duree_absence >= 4 }}"
          sequence:
            - service: input_select.select_option
              data:
                entity_id:
                  - input_select.mode_chauffage_salon
                  - input_select.mode_chauffage_cuisine
                option: "Confort2(19.5)"
            - service: telegram_bot.send_message
              data:
                chat_id: 8486475897
                message: "🏠 Retour après {{ duree_absence | round(1) }}h - Préchauffage activé"
```

---

### Option 2: DÉSACTIVER LE SYSTÈME (Plus simple)

Si tu ne veux pas gérer la complexité:

```yaml
# Désactiver l'automation existante
- id: chauffage_auto_presence
  alias: Chauffage Auto - Présence
  # ... (automation existante)
  # Passer en mode: disabled
```

**Avantages:**
- ✅ Pas de conflits
- ✅ Comportement prévisible
- ✅ Planning et mode manuel fonctionnent normalement

**Inconvénients:**
- ❌ Pas d'économies automatiques basées sur présence
- ❌ Il faut penser à activer mode Éco/Vacances manuellement

---

## 📋 CHECKLIST DE TESTS HOME ASSISTANT

### Test 1: Départ simple
```
☐ 1. Activer mode Manuel Salon → Confort (19.5°C)
☐ 2. Vérifier température Salon
☐ 3. Simuler départ (zone.home = 0)
     Outils dev → Services → zone.set
☐ 4. Attendre 5 min
☐ 5. Vérifier: Salon → Éco (18.5°C)
☐ 6. Vérifier: Scene "avant_depart" créée
```

### Test 2: Retour simple
```
☐ 1. Départ effectué (Test 1)
☐ 2. Simuler retour (zone.home = 1)
☐ 3. Vérifier: Salon → Confort (19.5°C) restauré
☐ 4. Vérifier: Notification Telegram reçue
```

### Test 3: Conflit avec Planning
```
☐ 1. Attendre 17:00 (Planning Confort soir)
☐ 2. Vérifier: Consigne = 19°C
☐ 3. Simuler départ
☐ 4. Vérifier: Consigne = 18.5°C
☐ 5. Simuler retour
☐ 6. Vérifier: Consigne restaurée à 19°C
```

### Test 4: Conflit avec Mode Vacances
```
☐ 1. Activer Mode Vacances
☐ 2. Simuler départ
☐ 3. Vérifier: Consigne reste 16°C (vacances prioritaire)
☐ 4. Vérifier: Automation présence ne s'est PAS déclenchée
```

### Test 5: Absence longue
```
☐ 1. Simuler départ
☐ 2. Changer manuellement input_datetime.heure_dernier_depart
     → Il y a 5 heures
☐ 3. Simuler retour
☐ 4. Vérifier: Passage en Confort (préchauffage)
☐ 5. Vérifier: Notification avec durée absence
```

---

## 🎯 TABLEAU "MODE ACTIF → ACTION CHAUFFAGE"

| Mode Présence | Mode Vacances | Mode Manuel | Planning | Consigne Finale | Qui décide? |
|---------------|---------------|-------------|----------|-----------------|-------------|
| Présent | OFF | Non défini | Confort soir (19°C) | **19°C** | Planning |
| **Absent** | OFF | Non défini | Confort soir (19°C) | **18.5°C** | **Présence** |
| Absent | **ON** | Non défini | Confort soir | **16°C** | **Vacances** |
| Présent | OFF | **Confort (19.5°C)** | Éco jour (18.5°C) | **19.5°C** | **Manuel** |
| **Absent** | OFF | **Confort (19.5°C)** | Éco jour (18.5°C) | **18.5°C** | **Présence** (écrase manuel!) |
| **Retour** | OFF | (Confort avant) | Éco jour (18.5°C) | **19.5°C** | **Scene restaurée** |

---

## 🌳 ARBRE DE DÉCISION COMPLET

```
┌─────────────────────┐
│ zone.home change?   │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
  = 0 (Départ)  > 0 (Retour)
     │           │
     ▼           ▼
┌──────────┐  ┌──────────┐
│ Attendre │  │ Restaurer│
│ 5 min    │  │ scene    │
└─────┬────┘  └──────────┘
      │
      ▼
┌──────────────────┐
│ Mode vacances?   │
└──────┬───────────┘
       │
  ┌────┴────┐
  │         │
 ON        OFF
  │         │
  │         ▼
  │    ┌──────────────┐
  │    │ Sauvegarder  │
  │    │ états actuels│
  │    └───────┬──────┘
  │            │
  │            ▼
  │    ┌──────────────┐
  │    │ TOUTES pièces│
  │    │ → Éco (18.5°C)│
  │    └──────────────┘
  │
  └──> FIN (ne rien faire)
```

---

## 💡 RECOMMANDATION FINALE

### Pour ton système actuel:

**OPTION RECOMMANDÉE: Compléter le système**

Pourquoi?
- ✅ Tu as déjà zone.home configuré
- ✅ Tu utilises la géolocalisation
- ✅ Potentiel d'économies significatif
- ✅ Confort amélioré (retour automatique)

**Actions à faire:**

1. ✅ **Ajouter automation de retour** (YAML fourni ci-dessus)
2. ✅ **Ajouter condition mode vacances** dans automation départ
3. ✅ **Étendre à toutes les pièces** (pas seulement Salon)
4. ✅ **Implémenter sauvegarde/restauration** avec scenes
5. ⏳ **Optionnel:** Gérer absences longues avec input_datetime

**Ordre de priorité devient:**

```
1️⃣ MODE VACANCES (bloque tout)
2️⃣ MODE MANUEL + Scene sauvegardée (restauré au retour)
3️⃣ MODE PRÉSENCE (modifie si absent, restaure si retour)
4️⃣ MODE PLANNING HORAIRE (actif si présent)
5️⃣ MODE CHAUFFAGE GLOBAL (par défaut)
6️⃣ PILOTAGE CHAUDIÈRE (exécution)
```

---

Veux-tu que je crée les fichiers YAML complets prêts à installer?
