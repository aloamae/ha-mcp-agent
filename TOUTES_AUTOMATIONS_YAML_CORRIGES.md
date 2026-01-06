# TOUTES LES AUTOMATIONS - YAML CORRIGÉS

**Temps:** 3 minutes
**Méthode:** Copier-coller ces YAML

---

## ✅ AUTOMATION 1: DÉPART MAISON

**Copier ce YAML:**

```yaml
alias: Depart maison
description: Sauvegarde modes et passe en Hors-Gel au depart
mode: single

triggers:
  - trigger: state
    entity_id:
      - zone.home
    to: "0"

conditions: []

actions:
  - action: scene.create
    metadata: {}
    data:
      scene_id: avant_depart
      snapshot_entities:
        - input_select.mode_chauffage_salon
        - input_select.mode_chauffage_cuisine

  - action: input_select.select_option
    target:
      entity_id: input_select.mode_chauffage_salon
    data:
      option: Hors-Gel(16)

  - action: input_select.select_option
    target:
      entity_id: input_select.mode_chauffage_cuisine
    data:
      option: Hors-Gel(16)
```

**Installation:**
```
Automations → + CRÉER
→ ... → Modifier au format YAML
→ COLLER
→ ENREGISTRER
```

---

## ✅ AUTOMATION 2: RETOUR MAISON

**Copier ce YAML:**

```yaml
alias: Retour maison
description: Restaure modes au retour
mode: single

triggers:
  - trigger: state
    entity_id:
      - zone.home
    from: "0"

conditions: []

actions:
  - delay:
      hours: 0
      minutes: 1
      seconds: 0

  - action: scene.turn_on
    target:
      entity_id: scene.avant_depart
    metadata: {}
```

---

## ✅ AUTOMATION 3: ACTIVER REMOTES DÉMARRAGE

**Copier ce YAML:**

```yaml
alias: Activer remotes demarrage
description: Active remotes Broadlink au demarrage HA
mode: single

triggers:
  - trigger: homeassistant
    event: start

conditions: []

actions:
  - delay:
      hours: 0
      minutes: 0
      seconds: 30

  - action: homeassistant.turn_on
    target:
      entity_id:
        - remote.clim_salon
        - remote.clim_maeva
        - remote.clim_axel
    metadata: {}
```

---

## ✅ AUTOMATION 4: RÉACTIVER REMOTE SALON

**Copier ce YAML:**

```yaml
alias: Reactiver remote Salon
description: Reactive remote Salon si passe OFF
mode: single

triggers:
  - trigger: state
    entity_id:
      - remote.clim_salon
    to: "off"

conditions: []

actions:
  - delay:
      hours: 0
      minutes: 0
      seconds: 5

  - action: homeassistant.turn_on
    target:
      entity_id: remote.clim_salon
    metadata: {}
```

---

## ✅ AUTOMATION 5: RÉACTIVER REMOTE MAEVA

**Copier ce YAML:**

```yaml
alias: Reactiver remote Maeva
description: Reactive remote Maeva si passe OFF
mode: single

triggers:
  - trigger: state
    entity_id:
      - remote.clim_maeva
    to: "off"

conditions: []

actions:
  - delay:
      hours: 0
      minutes: 0
      seconds: 5

  - action: homeassistant.turn_on
    target:
      entity_id: remote.clim_maeva
    metadata: {}
```

---

## ✅ AUTOMATION 6: RÉACTIVER REMOTE AXEL

**Copier ce YAML:**

```yaml
alias: Reactiver remote Axel
description: Reactive remote Axel si passe OFF
mode: single

triggers:
  - trigger: state
    entity_id:
      - remote.clim_axel
    to: "off"

conditions: []

actions:
  - delay:
      hours: 0
      minutes: 0
      seconds: 5

  - action: homeassistant.turn_on
    target:
      entity_id: remote.clim_axel
    metadata: {}
```

---

## 📋 ERREURS CORRIGÉES DANS TON YAML

### ❌ TES ERREURS

1. **Trigger:**
   ```yaml
   attribute: "0"  # ← FAUX
   ```
   **Correct:**
   ```yaml
   to: "0"  # ← BON
   ```

2. **Action scene.create mal formée:**
   ```yaml
   - action: scene.create
     data:
       scene_id: etat  # ← ID différent!
   - scene_id: avant_depart  # ← Bloc séparé, FAUX
     snapshot_entities:
   ```
   **Correct:**
   ```yaml
   - action: scene.create
     data:
       scene_id: avant_depart  # ← Tout dans un bloc
       snapshot_entities:
         - input_select.mode_chauffage_salon
         - input_select.mode_chauffage_cuisine
   ```

3. **Trigger dupliqué:**
   ```yaml
   triggers:
     - trigger: state
       entity_id:
         - zone.home
       attribute: "0"
     - trigger: state  # ← Même chose 2 fois
       entity_id:
         - zone.home
       attribute: "0"
   ```
   **Correct:**
   ```yaml
   triggers:
     - trigger: state  # ← Une seule fois
       entity_id:
         - zone.home
       to: "0"
   ```

---

## ✅ VALIDATION

### Test automation départ

```
1. Copier le YAML corrigé
2. Automations → + CRÉER → Modifier YAML → COLLER
3. ENREGISTRER
4. Outils dev → États → zone.home → Changer à 0
5. Attendre 5 secondes
6. Outils dev → États → Chercher "scene.avant_depart"
7. Vérifier: Scène créée ✅
8. Vérifier: Modes = Hors-Gel(16) ✅
```

### Test automation retour

```
1. Outils dev → États → zone.home → Changer à 1
2. Attendre 1 minute
3. Vérifier: Modes restaurés ✅
```

### Test remotes

```
1. Redémarrer HA
2. Attendre 1 minute
3. Vérifier: remote.clim_salon = on ✅
4. Mettre OFF manuellement
5. Attendre 6 secondes
6. Vérifier: Repassé à on ✅
```

---

## 🎯 RÉSUMÉ

**6 automations à copier-coller:**

1. ✅ Départ maison (crée scène + hors-gel)
2. ✅ Retour maison (restaure scène)
3. ✅ Activer remotes démarrage
4. ✅ Réactiver remote Salon
5. ✅ Réactiver remote Maeva
6. ✅ Réactiver remote Axel

**Temps total:** 3 minutes

**Tous les YAML sont maintenant 100% corrects!** ✅
