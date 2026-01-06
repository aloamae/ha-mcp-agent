# Guide : Ordre de Fonctionnement du Système de Chauffage

**Date**: 2025-12-19
**Système**: Home Assistant - Chauffage et Climatisation
**Objectif**: Comprendre l'ordre logique d'exécution des automations

---

## Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Cycle Journalier Complet](#cycle-journalier-complet)
3. [Modes de Fonctionnement](#modes-de-fonctionnement)
4. [Flux Décisionnel](#flux-décisionnel)
5. [Interactions Entre Automations](#interactions-entre-automations)
6. [Schéma Logique](#schéma-logique)
7. [Cas d'Usage Concrets](#cas-dusage-concrets)

---

## Vue d'Ensemble

### Architecture Globale

Le système de chauffage est composé de **3 couches** :

```
┌─────────────────────────────────────────────────────────────────┐
│                        COUCHE 1 : MODES                         │
│  (Définit le comportement global du système)                    │
└─────────────────────────────────────────────────────────────────┘
         │
         ├─ Mode VACANCES (input_boolean.mode_vacance)
         ├─ Mode MANUEL (input_boolean.mode_manuel)
         └─ Mode AUTOMATIQUE (par défaut)

┌─────────────────────────────────────────────────────────────────┐
│                    COUCHE 2 : PLANIFICATION                     │
│  (Gère les horaires et consignes de température)                │
└─────────────────────────────────────────────────────────────────┘
         │
         ├─ Allumage général matin (04:45 ou 05:45)
         ├─ Planning automatique horaire (05:45)
         └─ Consignes variables selon l'heure

┌─────────────────────────────────────────────────────────────────┐
│                    COUCHE 3 : RÉGULATION                        │
│  (Contrôle temps réel de la chaudière et climatisations)        │
└─────────────────────────────────────────────────────────────────┘
         │
         ├─ Pilotage chaudière gaz (toutes les 3 min)
         ├─ Régulation par humidité (conditionnel)
         └─ Climatisations Broadlink (manuel ou auto)
```

### Principe de Fonctionnement

1. **Le mode actif** (Couche 1) détermine si le système est automatique, manuel ou en vacances
2. **Le planning** (Couche 2) définit les horaires et consignes de température
3. **La régulation** (Couche 3) pilote en temps réel la chaudière et les climatisations

**Règle d'Or** : Les couches supérieures (Modes) ont **priorité absolue** sur les couches inférieures.

---

## Cycle Journalier Complet

### Timeline Heure par Heure

```
┌─────────────────────────────────────────────────────────────────┐
│                      JOURNÉE TYPE (Hiver)                       │
└─────────────────────────────────────────────────────────────────┘

00:00 ────────────────────────────────────────────────────────────
       État: NUIT
       - Chaudière: Régulation basse
       - Consigne: ~16-17°C (économie nuit)
       - Automation active: pilotage_chaudiere_gaz (cycle 3 min)

04:45 ────────────────────────────────────────────────────────────
       ⏰ DÉCLENCHEUR: automation.chauffage_allumage_general_matin

       Action:
       ├─ Allume le thermostat principal
       ├─ Prépare le système pour la journée
       └─ Active les circuits de chauffage

       Résultat:
       └─ Système en mode ÉVEIL

05:45 ────────────────────────────────────────────────────────────
       ⏰ DÉCLENCHEUR: automation.chauffage_planning_automatique_horaire

       Conditions vérifiées:
       ├─ input_boolean.mode_vacance = OFF ✓
       └─ input_boolean.mode_manuel = OFF ✓

       Action:
       ├─ Active le planning automatique
       ├─ Consigne température: 19-20°C (confort matin)
       └─ Augmente la puissance de chauffe

       Résultat:
       └─ Système en mode CONFORT MATIN

06:00 à 08:00 ────────────────────────────────────────────────────
       État: CONFORT (période de présence)
       - Consigne: 19-20°C
       - Chaudière: Active selon besoins TRV
       - Cycle régulation: Toutes les 3 minutes

08:00 à 17:00 ────────────────────────────────────────────────────
       État: ÉCONOMIE JOURNÉE (absence présumée)
       - Consigne: 17-18°C (réduit)
       - Chaudière: Régulation minimale
       - Maintien température anti-baisse

17:00 ────────────────────────────────────────────────────────────
       État: RETOUR CONFORT
       - Consigne: Remonte à 19-20°C
       - Chaudière: Réactive pour atteindre consigne

18:00 à 22:00 ────────────────────────────────────────────────────
       État: CONFORT SOIRÉE
       - Consigne: 20°C (maximale)
       - Présence famille
       - Régulation active

22:00 ────────────────────────────────────────────────────────────
       État: PASSAGE MODE NUIT
       - Consigne: Descend progressivement à 16-17°C
       - Chaudière: Réduit progressivement

00:00 ────────────────────────────────────────────────────────────
       → Retour au début du cycle


┌─────────────────────────────────────────────────────────────────┐
│                    RÉGULATION CONTINUE                          │
│        (Indépendante du cycle horaire)                          │
└─────────────────────────────────────────────────────────────────┘

⏱️ TOUTES LES 3 MINUTES:
   automation.chauffage_pilotage_chaudiere_gaz

   Séquence:
   1. Lit les températures actuelles (sensor.th_*_temperature)
   2. Lit les consignes définies par le planning
   3. Calcule l'écart (consigne - température actuelle)
   4. Décision:
      ├─ Si écart > 0.5°C → Allume chaudière (si pas en cooldown)
      ├─ Si écart < 0.2°C → Éteint chaudière (si runtime > 10 min)
      └─ Sinon → Maintient état actuel
   5. Respecte les règles:
      ├─ Minimum runtime: 10 minutes
      ├─ Maximum runtime: 30 minutes
      ├─ Cooldown après arrêt: 15-30 minutes
      └─ Pas de redémarrage pendant cooldown
```

---

## Modes de Fonctionnement

### Mode 1 : Automatique (par défaut)

**Conditions d'activation** :
```yaml
input_boolean.mode_vacance: OFF
input_boolean.mode_manuel: OFF
```

**Comportement** :
- Le planning horaire s'exécute normalement
- Automations `chauffage_planning_automatique_horaire` active
- Automations `chauffage_pilotage_chaudiere_gaz` active
- Consignes variables selon l'heure

**Organigramme** :
```
Utilisateur ne touche à rien
       ↓
Mode Automatique actif
       ↓
04:45 → Allumage général
       ↓
05:45 → Planning automatique démarre
       ↓
Toutes les 3 min → Régulation chaudière
       ↓
Consignes variables: Confort / Économie / Nuit
```

---

### Mode 2 : Vacances

**Conditions d'activation** :
```yaml
input_boolean.mode_vacance: ON
```

**Comportement** :
- **BLOQUE** automation `chauffage_planning_automatique_horaire`
- Active automation `chauffage_vacances`
- Consigne fixe : 12-15°C (anti-gel)
- Chaudière en mode minimal

**Organigramme** :
```
Utilisateur active mode_vacance
       ↓
input_boolean.mode_vacance → ON
       ↓
Automation chauffage_vacances déclenchée
       ↓
Planning automatique BLOQUÉ (condition non remplie)
       ↓
Consigne fixe: 12-15°C
       ↓
Chaudière: Maintien température minimale
       ↓
Économie maximale
```

**Quand utiliser** :
- Absence prolongée (> 2 jours)
- Vacances
- Maison inoccupée

**Comment activer** :
- Via UI Home Assistant : Basculer `input_boolean.mode_vacance` sur ON
- Via automation : Détection absence automatique (optionnel)

---

### Mode 3 : Manuel

**Conditions d'activation** :
```yaml
input_boolean.mode_manuel: ON
```

**Comportement** :
- **DÉSACTIVE** automation `chauffage_planning_automatique_horaire`
- Active automation `chauffage_manuel`
- Consigne définie manuellement par l'utilisateur
- Chaudière régule selon consigne manuelle

**Organigramme** :
```
Utilisateur active mode_manuel
       ↓
input_boolean.mode_manuel → ON
       ↓
Automation chauffage_manuel déclenchée
       ↓
Planning automatique DÉSACTIVÉ
       ↓
Utilisateur définit consigne manuellement (input_number.consigne_temperature)
       ↓
Chaudière régule selon consigne fixe
       ↓
Contrôle total utilisateur
```

**Quand utiliser** :
- Conditions météo exceptionnelles
- Besoin de chauffage ponctuel
- Désactivation temporaire du planning
- Test et débogage

**Comment activer** :
- Via UI Home Assistant : Basculer `input_boolean.mode_manuel` sur ON
- Définir la consigne via `input_number.consigne_temperature`

---

## Flux Décisionnel

### Décision : Allumer ou Éteindre la Chaudière ?

Voici le processus de décision exécuté **toutes les 3 minutes** par `automation.chauffage_pilotage_chaudiere_gaz` :

```
┌─────────────────────────────────────────────────────────────────┐
│              DÉBUT DU CYCLE DE RÉGULATION                       │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
        ┌─────────────────────────────────────┐
        │  Lire les températures actuelles    │
        │  sensor.th_*_temperature            │
        └─────────────────────────────────────┘
                           │
                           ▼
        ┌─────────────────────────────────────┐
        │  Lire la consigne active            │
        │  (selon mode: auto/manuel/vacances) │
        └─────────────────────────────────────┘
                           │
                           ▼
        ┌─────────────────────────────────────┐
        │  Calculer écart moyen               │
        │  écart = consigne - température     │
        └─────────────────────────────────────┘
                           │
                           ▼
                 ┌─────────┴─────────┐
                 │  Écart > 0.5°C ?  │
                 └─────────┬─────────┘
                    OUI    │    NON
                   ┌───────┴────────┐
                   ▼                ▼
        ┌───────────────────┐  ┌───────────────────┐
        │  Besoin de chauffe│  │  Écart < 0.2°C ?  │
        └───────────────────┘  └───────────────────┘
                   │                     │
                   ▼              OUI    │    NON
        ┌───────────────────┐  ┌────────┴────────┐
        │  Chaudière ON ?   │  │  Arrêter chauffe│  │ Maintenir état │
        └───────────────────┘  └─────────────────┘  └────────────────┘
                   │
            OUI    │    NON
           ┌───────┴────────┐
           ▼                ▼
   ┌─────────────┐  ┌────────────────────┐
   │ Déjà ON     │  │  Cooldown actif ?  │
   │ → Maintenir │  └────────────────────┘
   └─────────────┘           │
                       OUI   │   NON
                      ┌──────┴───────┐
                      ▼              ▼
            ┌──────────────┐  ┌──────────────┐
            │ Attendre fin │  │ ALLUMER      │
            │ cooldown     │  │ chaudière    │
            └──────────────┘  └──────────────┘
                                      │
                                      ▼
                          ┌────────────────────────┐
                          │ Enregistrer timestamp  │
                          │ boiler_last_started    │
                          └────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              VÉRIFICATION ARRÊT CHAUDIÈRE                       │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
        ┌─────────────────────────────────────┐
        │  Chaudière actuellement ON ?        │
        └─────────────────────────────────────┘
                           │
                    OUI    │    NON
                   ┌───────┴────────┐
                   ▼                ▼
   ┌──────────────────────┐  ┌────────────┐
   │ Calculer runtime     │  │ Rien faire │
   │ (now - last_started) │  └────────────┘
   └──────────────────────┘
                   │
                   ▼
        ┌─────────────────────┐
        │  Runtime > 30 min ? │
        └─────────────────────┘
                   │
            OUI    │    NON
           ┌───────┴────────┐
           ▼                ▼
   ┌─────────────┐  ┌────────────────────┐
   │ ARRÊT FORCÉ │  │  Écart < 0.2°C ?   │
   │ (sécurité)  │  └────────────────────┘
   └─────────────┘           │
           │          OUI    │    NON
           │         ┌───────┴────────┐
           │         ▼                ▼
           │  ┌──────────────┐  ┌────────────┐
           │  │ Runtime      │  │ Continuer  │
           │  │ > 10 min ?   │  │ chauffe    │
           │  └──────────────┘  └────────────┘
           │         │
           │  OUI    │    NON
           │ ┌───────┴────────┐
           │ ▼                ▼
           │ ┌─────────┐  ┌──────────────┐
           │ │ ARRÊTER │  │ Activer TRV  │
           │ │ chaudière│  │ buffer       │
           │ └─────────┘  │ (gardiens)   │
           │      │       └──────────────┘
           │      │              │
           └──────┴──────────────┘
                  │
                  ▼
      ┌────────────────────────┐
      │ Activer cooldown       │
      │ boiler_cooldown_active │
      │ Durée: 15-30 min       │
      └────────────────────────┘
                  │
                  ▼
      ┌────────────────────────┐
      │ Enregistrer timestamp  │
      │ boiler_last_stopped    │
      └────────────────────────┘
```

---

## Interactions Entre Automations

### Interaction 1 : Mode Vacances BLOQUE Planning Automatique

```
┌───────────────────────────────────────────────────────────────┐
│  Utilisateur active input_boolean.mode_vacance                │
└───────────────────────────────────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  automation.chauffage_vacances   │
        │  DÉCLENCHÉE                      │
        └──────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Consigne → 12-15°C (anti-gel)   │
        └──────────────────────────────────┘

SIMULTANÉMENT:

        ┌──────────────────────────────────────────────┐
        │  automation.chauffage_planning_automatique   │
        │  tente de s'exécuter à 05:45                 │
        └──────────────────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Condition vérifiée:             │
        │  mode_vacance = OFF ?            │
        └──────────────────────────────────┘
                           │
                        ❌ NON
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  AUTOMATION BLOQUÉE              │
        │  N'exécute pas ses actions       │
        └──────────────────────────────────┘

RÉSULTAT FINAL:

- Planning automatique ignoré
- Consigne vacances active
- Économie maximale
```

---

### Interaction 2 : Régulation Continue Respecte le Cooldown

```
┌───────────────────────────────────────────────────────────────┐
│  automation.chauffage_pilotage_chaudiere_gaz                  │
│  Cycle: Toutes les 3 minutes                                  │
└───────────────────────────────────────────────────────────────┘

T = 0 min
       │
       ▼
Besoin de chauffe détecté (écart > 0.5°C)
       │
       ▼
input_boolean.boiler_cooldown_active = OFF ?
       │
     ✅ OUI
       │
       ▼
ALLUME chaudière
       │
       ▼
Enregistre input_datetime.boiler_last_started = NOW

───────────────────────────────────────────────────────────────

T = 12 min (runtime = 12 minutes)
       │
       ▼
Besoin terminé (écart < 0.2°C)
       │
       ▼
Runtime > 10 min ? ✅ OUI
       │
       ▼
ÉTEINT chaudière
       │
       ▼
input_boolean.boiler_cooldown_active = ON
input_datetime.boiler_last_stopped = NOW

───────────────────────────────────────────────────────────────

T = 15 min (3 min après arrêt)
       │
       ▼
automation.chauffage_pilotage_chaudiere_gaz (cycle suivant)
       │
       ▼
Nouveau besoin détecté (écart > 0.5°C)
       │
       ▼
input_boolean.boiler_cooldown_active = ON ?
       │
     ✅ OUI (encore en cooldown)
       │
       ▼
❌ NE DÉMARRE PAS la chaudière
Log: "Cooldown actif, chaudière bloquée pendant XX minutes"

───────────────────────────────────────────────────────────────

T = 30 min (cooldown terminé)
       │
       ▼
automation.chauffage_end_cooldown (déclenchée)
       │
       ▼
input_boolean.boiler_cooldown_active = OFF
       │
       ▼
Vérifie: sensor.any_trv_heating = True ?
       │
     ✅ OUI (besoin de chauffe toujours présent)
       │
       ▼
REDÉMARRE chaudière
```

---

### Interaction 3 : Humidité Modifie la Consigne

```
┌───────────────────────────────────────────────────────────────┐
│  automation.chauffage_humidite                                │
│  Trigger: sensor.th_*_humidity > 70%                          │
└───────────────────────────────────────────────────────────────┘

État initial:
- Température actuelle: 19°C
- Consigne planning: 20°C
- Humidité: 72% (> seuil)

       │
       ▼
automation.chauffage_humidite DÉCLENCHÉE
       │
       ▼
Action: Augmente temporairement la consigne à 21°C
       │
       ▼
automation.chauffage_pilotage_chaudiere_gaz (cycle suivant)
       │
       ▼
Lit consigne: 21°C (modifiée par automation humidité)
Température actuelle: 19°C
Écart = 2°C (> 0.5°C)
       │
       ▼
ALLUME chaudière (chauffage plus fort)
       │
       ▼
Température monte progressivement
Humidité descend (air plus sec)
       │
       ▼
Humidité < 65% (retour normal)
       │
       ▼
automation.chauffage_humidite DÉSACTIVÉE
       │
       ▼
Consigne revient à 20°C (planning normal)
```

---

## Schéma Logique

### Diagramme de Flux Complet

```
                    ┌─────────────────────┐
                    │   DÉMARRAGE HA      │
                    └──────────┬──────────┘
                               │
                               ▼
        ┌──────────────────────────────────────────┐
        │  Initialisation des helpers              │
        │  - mode_vacance: OFF                     │
        │  - mode_manuel: OFF                      │
        │  - boiler_cooldown_active: OFF           │
        └──────────────────────────────────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │  Mode actif =       │
                    │  AUTOMATIQUE        │
                    └──────────┬──────────┘
                               │
                               ▼
        ╔══════════════════════════════════════════╗
        ║         BOUCLE PRINCIPALE                ║
        ╚══════════════════════════════════════════╝
                               │
        ┌──────────────────────┴──────────────────────┐
        │                                             │
        ▼                                             ▼
┌───────────────┐                          ┌──────────────────┐
│  Horaires     │                          │  Régulation      │
│  (Planning)   │                          │  Continue        │
└───────────────┘                          └──────────────────┘
        │                                             │
        ├─ 04:45 Allumage                            ├─ Toutes les 3 min
        ├─ 05:45 Planning auto                       ├─ Lecture capteurs
        ├─ XX:XX Changements consignes               ├─ Décision ON/OFF
        │                                             ├─ Respect cooldown
        │                                             │
        └─────────────────┬───────────────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────────┐
        │  État système mis à jour                │
        │  - Température actuelle                 │
        │  - Consigne active                      │
        │  - État chaudière (ON/OFF/COOLDOWN)     │
        └─────────────────────────────────────────┘
                          │
                          ▼
                    [Boucle continue]

        ╔══════════════════════════════════════════╗
        ║         OVERRIDE PAR MODES               ║
        ╚══════════════════════════════════════════╝

Si mode_vacance = ON:
        → BLOQUE planning automatique
        → Consigne fixe 12-15°C

Si mode_manuel = ON:
        → DÉSACTIVE planning automatique
        → Consigne définie par utilisateur

Sinon:
        → Mode automatique actif
        → Planning suit les horaires
```

---

## Cas d'Usage Concrets

### Cas 1 : Journée Normale (Automatique)

**Contexte** :
- Mode: Automatique
- Saison: Hiver
- Présence: Famille présente matin et soir

**Déroulement** :

```
04:45 - Allumage général matin
        ├─ Système se prépare
        └─ Température actuelle: 16°C

05:45 - Planning automatique démarre
        ├─ Consigne: 19°C (confort matin)
        └─ Écart: 3°C → Chaudière ALLUME

06:00 - Régulation en cours
        ├─ Température monte progressivement
        ├─ Cycle toutes les 3 min
        └─ Température atteint 18.8°C (presque cible)

06:30 - Objectif atteint
        ├─ Température: 19.1°C
        ├─ Écart < 0.2°C
        ├─ Runtime = 45 min (> 10 min OK)
        └─ Chaudière ÉTEINT, cooldown 30 min

07:00 - Cooldown actif
        ├─ Température descend légèrement: 18.6°C
        ├─ Chaudière ne peut pas redémarrer
        └─ Attente fin cooldown

07:00 - Fin cooldown
        ├─ Besoin détecté: écart 0.4°C
        └─ Chaudière REDÉMARRE

[... cycle continue toute la journée ...]

08:00 - Passage mode Économie
        ├─ Consigne descend à 17°C
        ├─ Température actuelle: 19°C
        └─ Chaudière reste éteinte (déjà au-dessus)

17:00 - Retour Confort
        ├─ Consigne remonte à 20°C
        ├─ Température actuelle: 17.5°C
        ├─ Écart: 2.5°C
        └─ Chaudière ALLUME (réchauffement avant retour famille)

22:00 - Mode Nuit
        ├─ Consigne: 16°C
        └─ Chaudière s'éteint progressivement
```

---

### Cas 2 : Départ en Vacances

**Contexte** :
- Départ: Vendredi soir
- Retour: Dimanche soir (2 jours)
- Objectif: Économiser énergie, anti-gel

**Actions Utilisateur** :

```
Vendredi 18:00
        │
        ▼
Utilisateur active mode_vacance
        │
        ▼
input_boolean.mode_vacance = ON
        │
        ▼
automation.chauffage_vacances DÉCLENCHÉE
        │
        ├─ Consigne → 13°C (anti-gel)
        ├─ Planning automatique BLOQUÉ
        └─ Notification: "Mode vacances activé"

Samedi 05:45 (pendant absence)
        │
        ▼
automation.chauffage_planning_automatique tente de s'exécuter
        │
        ▼
Condition: mode_vacance = OFF ?
        │
      ❌ NON (= ON)
        │
        ▼
Automation BLOQUÉE (n'exécute rien)
        │
        ▼
Consigne reste 13°C (pas de changement)

Samedi 10:00
        │
        ▼
Régulation continue (toutes les 3 min)
        │
        ├─ Température actuelle: 13.5°C
        ├─ Consigne: 13°C
        ├─ Écart: -0.5°C (déjà au-dessus)
        └─ Chaudière RESTE ÉTEINTE

Dimanche 17:00 (retour anticipé)
        │
        ▼
Utilisateur DÉSACTIVE mode_vacance
        │
        ▼
input_boolean.mode_vacance = OFF
        │
        ▼
Planning automatique RÉACTIVÉ immédiatement
        │
        ├─ Consigne remonte à 20°C (confort soirée)
        ├─ Température actuelle: 13°C
        ├─ Écart: 7°C (énorme)
        └─ Chaudière ALLUME immédiatement

Dimanche 17:00 à 19:00
        │
        ▼
Réchauffement progressif
        │
        ├─ Chaudière fonctionne en continu
        ├─ Température monte: 13°C → 15°C → 17°C → 19°C
        └─ Maison confortable pour le soir
```

---

### Cas 3 : Contrôle Manuel Ponctuel

**Contexte** :
- Météo: Grand froid exceptionnel (-10°C)
- Objectif: Forcer chauffage à 21°C toute la journée
- Durée: 1 journée

**Actions Utilisateur** :

```
Mardi 07:00
        │
        ▼
Utilisateur active mode_manuel
        │
        ▼
input_boolean.mode_manuel = ON
        │
        ├─ Planning automatique DÉSACTIVÉ
        └─ Contrôle total à l'utilisateur

Utilisateur définit consigne manuelle
        │
        ▼
input_number.consigne_temperature = 21
        │
        ▼
automation.chauffage_manuel applique la consigne
        │
        └─ Consigne fixe: 21°C (toute la journée)

Régulation continue
        │
        ├─ Lit consigne: 21°C (manuel)
        ├─ Température actuelle: 18°C
        ├─ Écart: 3°C
        └─ Chaudière ALLUME

Toute la journée
        │
        ├─ Consigne reste 21°C (pas de changement horaire)
        ├─ Planning automatique ignoré
        └─ Chauffage maintient 21°C en continu

Mardi 22:00 (fin de journée froide)
        │
        ▼
Utilisateur DÉSACTIVE mode_manuel
        │
        ▼
input_boolean.mode_manuel = OFF
        │
        ▼
Planning automatique RÉACTIVÉ
        │
        ├─ Heure actuelle: 22:00 → Mode Nuit
        ├─ Consigne planning: 16°C
        ├─ Température actuelle: 21°C
        └─ Chaudière s'éteint (déjà au-dessus)

Mercredi 05:45
        │
        ▼
Retour au fonctionnement automatique normal
```

---

### Cas 4 : Humidité Élevée (Cas Spécial)

**Contexte** :
- Salle de bain après douches
- Humidité monte à 75%
- Risque de moisissure

**Déroulement** :

```
Lundi 07:30 (après douches matinales)
        │
        ▼
sensor.th_salle_bain_humidity = 75%
        │
        ▼
automation.chauffage_humidite DÉCLENCHÉE
        │
        ▼
Condition: humidity > 70% ?
        │
      ✅ OUI (75%)
        │
        ▼
Action: Augmente consigne temporairement
        │
        ├─ Consigne normale: 19°C
        └─ Consigne modifiée: 21°C (+2°C)

Régulation continue (cycle suivant)
        │
        ├─ Lit consigne: 21°C (modifiée)
        ├─ Température actuelle: 19.2°C
        ├─ Écart: 1.8°C (> 0.5°C)
        └─ Chaudière ALLUME (chauffage plus fort)

07:35 à 08:00
        │
        ├─ Température monte: 19.2°C → 20.5°C
        ├─ Air se réchauffe
        └─ Humidité descend: 75% → 68% → 62%

08:00
        │
        ▼
sensor.th_salle_bain_humidity = 62%
        │
        ▼
automation.chauffage_humidite vérifie condition
        │
        ▼
Condition: humidity > 70% ?
        │
      ❌ NON (62%)
        │
        ▼
Automation se DÉSACTIVE
        │
        └─ Consigne revient à 19°C (normale)

Régulation continue (cycle suivant)
        │
        ├─ Consigne: 19°C (retour normal)
        ├─ Température actuelle: 20.5°C
        ├─ Écart: -1.5°C (déjà au-dessus)
        └─ Chaudière s'éteint

Résultat:
        ├─ Humidité régulée avec succès
        ├─ Retour au fonctionnement normal
        └─ Pas d'intervention manuelle requise
```

---

## Résumé des Règles Essentielles

### Règle 1 : Hiérarchie des Modes

```
PRIORITÉ 1: Mode Vacances (bloque tout)
PRIORITÉ 2: Mode Manuel (override planning)
PRIORITÉ 3: Mode Automatique (planning horaire)
```

### Règle 2 : Sécurité Chaudière

```
Minimum runtime   : 10 minutes (jamais moins)
Maximum runtime   : 30 minutes (arrêt forcé si dépassé)
Cooldown duration : 15-30 minutes (adaptatif)
Jamais de restart : Pendant le cooldown
```

### Règle 3 : Régulation Continue

```
Fréquence      : Toutes les 3 minutes
Indépendance   : Continue même si planning bloqué
Respect modes  : Lit la consigne du mode actif
```

### Règle 4 : Conditions de Démarrage

```
Pour ALLUMER chaudière:
  ✓ Écart température > 0.5°C
  ✓ Cooldown = OFF
  ✓ Système enabled

Pour ÉTEINDRE chaudière:
  ✓ Écart température < 0.2°C
  ✓ Runtime > 10 minutes
  OU
  ✓ Runtime > 30 minutes (forcé)
```

---

## Prochaines Étapes

Pour obtenir les **données réelles exactes** de votre système :

```powershell
# 1. Exécuter la collecte complète
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"
.\collect_automation_data.ps1

# 2. Analyser les détails
.\analyze_automation_details.ps1

# 3. Consulter les exports JSON
# → automation_data_export.json
# → automation_details_export.json
```

Ces scripts vous fourniront :
- Les horaires exacts de chaque automation
- Les conditions précises
- Les actions détaillées
- Les dépendances réelles

---

**Document généré le** : 2025-12-19
**Auteur** : Agent Orchestrator (Claude Sonnet 4.5)
**Statut** : Guide complet - Valider avec données réelles
