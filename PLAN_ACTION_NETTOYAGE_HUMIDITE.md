# PLAN D'ACTION - NETTOYAGE + HUMIDITÉ

**Date:** 21 décembre 2025
**Objectif:** Nettoyer système + Intégrer mode humidité

---

## 📋 TASK BOARD

### ✅ Phase 1: NETTOYAGE (30 min)
- [ ] Supprimer 16 fichiers obsolètes
- [ ] Vérifier automations actives Home Assistant
- [ ] Désactiver anciennes automations en doublon

### 🔧 Phase 2: HUMIDITÉ (45 min)
- [ ] Créer 2 automations humidité > seuil (Cuisine + Salon)
- [ ] Créer 2 automations humidité < seuil (Cuisine + Salon)
- [ ] Modifier automations GAZ/Clim pour intégrer priorité humidité
- [ ] Tester système humidité

### 📚 Phase 3: DOCUMENTATION (15 min)
- [ ] Créer guide ordre de priorité avec exemples
- [ ] Mettre à jour dashboard debugging
- [ ] Créer fiche récapitulative

---

## 🎯 NOUVEL ORDRE DE PRIORITÉ (6 NIVEAUX)

```
1️⃣ MODE VACANCES
   └─> Force 16°C GAZ + OFF Climatisations
   └─> BLOQUE TOUT

2️⃣ MODE HUMIDITÉ PAR PIÈCE
   └─> SI humidité > seuil ET mode_humidite_* = ON
   └─> Augmente consigne temporairement (+2°C)
   └─> Priorité sur modes manuels

3️⃣ MODE MANUEL PAR PIÈCE
   └─> Contrôle utilisateur direct
   └─> input_select.mode_chauffage_*

4️⃣ MODE PLANNING HORAIRE
   └─> 4x par jour (05:45, 08:00, 17:00, 22:30)
   └─> Actif si modes manuels = MODEJOUR

5️⃣ MODE CHAUFFAGE GLOBAL
   └─> sensor.mode_chauffage_global
   └─> Fallback: 18.5°C

6️⃣ PILOTAGE (Exécution)
   └─> Cycle: Toutes les 3 min
   └─> Seuils: ±0.5°C
   └─> Zone morte = ÉTEINDRE
```

---

## 📖 EXPLICATION DÉTAILLÉE AVEC EXEMPLES

### Niveau 1: MODE VACANCES (Priorité Absolue)

**Fonctionnement:**
```
SI input_boolean.mode_vacance = ON:
  → Chaudière GAZ: Force 16°C (hors-gel)
  → Toutes climatisations: Force OFF
  → IGNORE tous les autres modes
```

**Exemple:**
```
Situation: Départ vacances 1 semaine
Action: Activer input_boolean.mode_vacance

Résultat:
- Cuisine, Parents, Loann → Chaudière 16°C
- Salon, Axel, Maeva → Climatisations OFF
- Humidité IGNORÉE
- Modes manuels IGNORÉS
- Planning IGNORÉ
```

---

### Niveau 2: MODE HUMIDITÉ (Nouveau - Priorité 2)

**Fonctionnement:**
```
POUR CHAQUE PIÈCE avec capteur humidité:

SI sensor.th_*_humidity > input_number.seuil_humidite_chauffage
   ET input_boolean.mode_humidite_* = ON:
  → Augmente consigne de +2°C (temporaire)
  → Override le mode manuel
  → But: Assécher l'air

Exemple concret Cuisine:
- Humidité normale: 45%
- Seuil défini: 60%
- Mode manuel: Eco(18°C)
- input_boolean.mode_humidite_cuisine: ON

Scénario:
1. Cuisson → Humidité monte à 65%
2. Trigger: 65% > 60% (au-dessus seuil)
3. Action: Consigne devient 18 + 2 = 20°C
4. Résultat: Chauffe plus → Air plus sec
5. Quand humidité < 60%: Retour à 18°C
```

**Variables créées:**
```yaml
POUR GAZ (Cuisine):
  consigne_base = 18°C (mode Eco)
  humidite_active = ON si mode_humidite_cuisine = ON ET humidity > seuil
  consigne_finale = consigne_base + (2 si humidite_active else 0)

  Exemple:
  - Humidité 45% → consigne_finale = 18°C
  - Humidité 65% → consigne_finale = 20°C

POUR CLIMATISATION (Salon):
  consigne_base = 21°C (mode Confort3)
  humidite_active = ON si mode_humidite_salon = ON ET humidity > seuil
  consigne_finale = consigne_base + (2 si humidite_active else 0)

  Exemple:
  - Humidité 50% → consigne_finale = 21°C
  - Humidité 70% → consigne_finale = 23°C
```

**Exemple complet:**
```
Situation: Cuisine après cuisson

État initial:
- Mode manuel Cuisine: Eco(18°C)
- Humidité: 70% (cuisson vapeur)
- Seuil: 60%
- input_boolean.mode_humidite_cuisine: ON

Déroulement:
1. T+0:  Humidité 70% > 60% pendant 2 minutes
        → Automation "Humidité > Seuil - Cuisine - On" se déclenche
        → Active input_boolean.mode_humidite_cuisine

2. T+3min: Automation pilotage GAZ s'exécute
        → Détecte humidité active
        → Consigne = 18 + 2 = 20°C
        → Chaudière chauffe plus fort

3. T+15min: Humidité descend à 55%
        → Reste < 60% pendant 5 minutes
        → Automation "Humidité < Seuil - Cuisine - Off" se déclenche
        → Désactive input_boolean.mode_humidite_cuisine

4. T+18min: Automation pilotage GAZ s'exécute
        → Humidité plus active
        → Consigne = 18°C (retour normal)
```

---

### Niveau 3: MODE MANUEL PAR PIÈCE

**Fonctionnement:**
```
POUR GAZ (3 pièces):
  Consigne = MIN(pièces actives != STOP/MODEJOUR)

  Exemple:
  - Cuisine: Confort3(21°C)
  - Parents: Eco(18°C)
  - Loann: MODEJOUR

  → Consigne = MIN(21, 18) = 18°C
  → Loann ignoré (MODEJOUR)

POUR CLIMATISATIONS (3 pièces):
  Chaque pièce indépendante

  Exemple:
  - Salon: Confort3(21°C) → Climatisation Salon à 21°C
  - Axel: Eco(18°C) → Climatisation Axel à 18°C
  - Maeva: STOP → Climatisation Maeva OFF
```

**Exemple complet:**
```
Situation: Soirée hiver, toute famille présente

Modes manuels:
- Cuisine: Confort2(19.5°C)
- Parents: Confort(19°C)
- Loann: Eco(18°C)
- Salon: Confort3(21°C)
- Axel: Confort2(19.5°C)
- Maeva: Confort(19°C)

Résultat SANS humidité active:
- Chaudière GAZ: 18°C (MIN des 3 pièces GAZ)
  → Cuisine, Parents, Loann chauffent à 18°C
- Climatisation Salon: 21°C (indépendante)
- Climatisation Axel: 19.5°C (indépendante)
- Climatisation Maeva: 19°C (indépendante)

Résultat AVEC humidité Cuisine 70%:
- Chaudière GAZ: 20°C (MIN(21.5, 19, 18) = 18 + 2 boost humidité)
  → Cuisine boost pour assécher
  → Parents et Loann suivent à 20°C aussi
- Climatisations: inchangées
```

---

### Niveau 4: MODE PLANNING HORAIRE

**Fonctionnement:**
```
SI toutes les pièces = MODEJOUR:
  → Planning prend le contrôle
  → Modifie sensor.mode_chauffage_global selon heure

Horaires proposés:
- 05:45 : Réveil → Confort (19°C)
- 08:00 : Journée → Eco (18°C)
- 17:00 : Retour → Confort (19°C)
- 22:30 : Nuit → Hors-Gel2 (17°C)
```

**Exemple:**
```
Situation: Semaine normale, pas de modes manuels

Modes manuels:
- TOUTES les pièces: MODEJOUR

Déroulement journée:
05:45 → sensor.mode_chauffage_global = Confort (19°C)
        → Toutes pièces chauffent à 19°C

08:00 → sensor.mode_chauffage_global = Eco (18°C)
        → Toutes pièces chauffent à 18°C

17:00 → sensor.mode_chauffage_global = Confort (19°C)
        → Toutes pièces chauffent à 19°C

22:30 → sensor.mode_chauffage_global = Hors-Gel2 (17°C)
        → Toutes pièces chauffent à 17°C

NOTE: Si UNE SEULE pièce passe en mode manuel:
→ Planning N'AFFECTE PAS cette pièce
→ Planning continue pour les autres pièces en MODEJOUR
```

---

### Niveau 5: MODE CHAUFFAGE GLOBAL (Fallback)

**Fonctionnement:**
```
SI aucun mode supérieur actif:
  → Utilise sensor.mode_chauffage_global
  → Valeur par défaut: 18.5°C
```

**Exemple:**
```
Situation: Installation fraîche, aucun mode configuré

État:
- Mode vacances: OFF
- Humidité: < seuil (pas active)
- Modes manuels: Tous en STOP
- Planning: Non configuré

Résultat:
→ sensor.mode_chauffage_global = 18.5°C
→ Toutes pièces chauffent à 18.5°C (sécurité)
```

---

### Niveau 6: PILOTAGE (Exécution)

**Fonctionnement:**
```
Toutes les 3 minutes:
1. Calcule consigne selon priorités 1-5
2. Lit températures actuelles
3. Calcule delta = consigne - température
4. Décide action:
   - delta >= +0.5°C → ALLUMER
   - delta < +0.5°C → ÉTEINDRE (zone morte)
5. Vérifie état actuel avant commande
   - Si déjà dans bon état → Ne rien faire
   - Sinon → Envoyer commande
```

**Exemple Zone Morte:**
```
Situation: Température proche consigne

Cuisine:
- Consigne: 19°C
- Température actuelle: 18.8°C
- Delta: 19 - 18.8 = +0.2°C

Analyse:
- +0.2°C < +0.5°C → Pas besoin chauffer
- Action: ÉTEINDRE chaudière (zone morte)

Avantage:
- Économie d'énergie
- Pas d'oscillations
- Confort maintenu (+0.2°C imperceptible)
```

---

## 🔍 EXEMPLES COMBINÉS (Situations Réelles)

### Exemple 1: Jour Normal avec Cuisson

```
08:00 - Matin
État:
- Mode vacances: OFF
- Modes manuels: Tous MODEJOUR
- Planning: Active → Confort (19°C)

Résultat:
→ Toutes pièces à 19°C

12:00 - Cuisson vapeur Cuisine
État:
- Humidité Cuisine: 75%
- Seuil: 60%
- mode_humidite_cuisine: ON

Changement:
→ Cuisine: 19 + 2 = 21°C (boost humidité)
→ Chaudière GAZ: MIN(21, 19, 19) = 19°C pour l'instant
   MAIS la Cuisine aura la priorité locale

13:00 - Fin cuisson
État:
- Humidité Cuisine: 55%

Résultat:
→ Cuisine: Retour à 19°C
```

### Exemple 2: Soirée Personnalisée

```
18:00 - Retour maison
Action manuelle:
- Salon: Confort3(21°C) (famille au salon)
- Cuisine: Eco(18°C) (pas de cuisson prévue)
- Parents: MODEJOUR (suit planning)
- Loann: Confort(19°C) (devoirs)
- Axel: Confort2(19.5°C) (jeux)
- Maeva: STOP (absente)

Résultat:
→ Chaudière GAZ: MIN(18, planning, 19) = 18°C
→ Climatisation Salon: 21°C
→ Climatisation Axel: 19.5°C
→ Climatisation Maeva: OFF

19:30 - Cuisson dîner
État:
- Humidité Cuisine: 68%
- mode_humidite_cuisine: ON

Changement:
→ Cuisine: 18 + 2 = 20°C (boost)
→ Chaudière GAZ: MIN(20, planning, 19) = 19°C
   (planning 19°C pour Parents reste minimum)
```

### Exemple 3: Week-end Vacances

```
Vendredi 18:00 - Départ vacances
Action:
→ Activer input_boolean.mode_vacance

Résultat IMMÉDIAT:
→ Chaudière GAZ: 16°C (force hors-gel)
→ Toutes climatisations: OFF
→ IGNORE:
  - Humidité (même si Cuisine 80%)
  - Modes manuels (même si Confort3)
  - Planning
  - Mode global

Dimanche 20:00 - Retour vacances
Action:
→ Désactiver input_boolean.mode_vacance

Résultat:
→ Modes manuels reprennent priorité
→ Humidité reprend contrôle si active
→ Système fonctionne normalement
```

---

## 🎯 TABLEAU RÉCAPITULATIF PRIORITÉS

| Niveau | Mode | Condition | Consigne | Override |
|--------|------|-----------|----------|----------|
| 1 | **Vacances** | mode_vacance = ON | 16°C GAZ / OFF Clims | TOUT |
| 2 | **Humidité** | humidity > seuil ET mode_humidite = ON | Base + 2°C | Modes manuels |
| 3 | **Manuel** | input_select != STOP/MODEJOUR | Température définie | Planning + Global |
| 4 | **Planning** | Modes = MODEJOUR | Selon horaire | Global |
| 5 | **Global** | Fallback | sensor.mode_chauffage_global | Rien |
| 6 | **Pilotage** | Exécution | Applique consigne finale | Rien |

---

## ✅ CHECKLIST VALIDATION

### Avant Modifications
- [ ] Sauvegarder configuration actuelle Home Assistant
- [ ] Noter état actuel toutes automations
- [ ] Lister fichiers à supprimer

### Pendant Modifications
- [ ] Supprimer fichiers obsolètes UN PAR UN
- [ ] Vérifier aucune automation active supprimée par erreur
- [ ] Créer automations humidité avec tests

### Après Modifications
- [ ] Vérifier 4 automations principales actives
- [ ] Tester mode humidité (vaporiser eau si besoin)
- [ ] Valider ordre priorité avec exemples réels
- [ ] Documenter changements

---

## 📝 PROCHAINES ÉTAPES

1. **PHASE 1 - NETTOYAGE** (Urgent)
   → Supprimer 16 fichiers obsolètes

2. **PHASE 2 - HUMIDITÉ** (Important)
   → Créer 4 automations humidité (2 par pièce)
   → Modifier automations GAZ/Clim pour boost +2°C

3. **PHASE 3 - DOCUMENTATION** (Utile)
   → Créer guide utilisateur
   → Mettre à jour dashboards

**Prêt à commencer?**
