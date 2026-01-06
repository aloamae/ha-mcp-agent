# GUIDE COMPLET - CRÉER TOUTES LES AUTOMATIONS VIA UI

**Temps:** 10 minutes
**Méthode:** Interface graphique (pas de YAML, pas de timeout)

---

## 🎯 ORDRE D'INSTALLATION

1. Automation DÉPART (crée la scène)
2. Automation RETOUR (utilise la scène)
3. Automation activation remotes au démarrage
4. Automation réactivation remote Salon
5. Automation réactivation remote Maeva
6. Automation réactivation remote Axel

---

## 1️⃣ AUTOMATION DÉPART

**Nom:** Depart maison

### Déclencheur
```
Type: État
Entité: zone.home
À: 0
```

### Action 1: Créer scène
```
Service: scene.create
Basculer mode YAML:

scene_id: avant_depart
snapshot_entities:
  - input_select.mode_chauffage_salon
  - input_select.mode_chauffage_cuisine
```

### Action 2: Mode Salon → Absent
```
Service: input_select.select_option
Cible: input_select.mode_chauffage_salon
Option: Absent
```

### Action 3: Mode Cuisine → Absent
```
Service: input_select.select_option
Cible: input_select.mode_chauffage_cuisine
Option: Absent
```

**ENREGISTRER**

---

## 2️⃣ AUTOMATION RETOUR

**Nom:** Retour maison

### Déclencheur
```
Type: État
Entité: zone.home
De: 0
```

### Action 1: Délai
```
Type: Délai
Durée: 00:01:00 (1 minute)
```

### Action 2: Restaurer scène
```
Service: scene.turn_on
Cible: scene.avant_depart
```

### Action 3: Notification
```
Service: persistent_notification.create
Basculer mode YAML:

title: Retour maison
message: Modes de chauffage restaures
```

**ENREGISTRER**

---

## 3️⃣ AUTOMATION ACTIVATION DÉMARRAGE

**Nom:** Activer remotes demarrage

### Déclencheur
```
Type: Démarrage de Home Assistant
```

### Action 1: Délai
```
Type: Délai
Durée: 00:00:30 (30 secondes)
```

### Action 2: Activer remotes
```
Service: homeassistant.turn_on
Cible:
  Ajouter entité: remote.clim_salon
  Ajouter entité: remote.clim_maeva
  Ajouter entité: remote.clim_axel
```

**ENREGISTRER**

---

## 4️⃣ AUTOMATION RÉACTIVATION REMOTE SALON

**Nom:** Reactiver remote Salon

### Déclencheur
```
Type: État
Entité: remote.clim_salon
À: off
```

### Action 1: Délai
```
Type: Délai
Durée: 00:00:05 (5 secondes)
```

### Action 2: Activer
```
Service: homeassistant.turn_on
Cible: remote.clim_salon
```

**ENREGISTRER**

---

## 5️⃣ AUTOMATION RÉACTIVATION REMOTE MAEVA

**Nom:** Reactiver remote Maeva

### Déclencheur
```
Type: État
Entité: remote.clim_maeva
À: off
```

### Action 1: Délai
```
Type: Délai
Durée: 00:00:05 (5 secondes)
```

### Action 2: Activer
```
Service: homeassistant.turn_on
Cible: remote.clim_maeva
```

**ENREGISTRER**

---

## 6️⃣ AUTOMATION RÉACTIVATION REMOTE AXEL

**Nom:** Reactiver remote Axel

### Déclencheur
```
Type: État
Entité: remote.clim_axel
À: off
```

### Action 1: Délai
```
Type: Délai
Durée: 00:00:05 (5 secondes)
```

### Action 2: Activer
```
Service: homeassistant.turn_on
Cible: remote.clim_axel
```

**ENREGISTRER**

---

## ✅ VALIDATION COMPLÈTE

### Après création des 6 automations

```
[ ] Automations → 6 nouvelles automations visibles
[ ] Toutes activées (switch ON)
[ ] Pas de message timeout
```

### Test automation départ

```
1. Outils dev → États → zone.home
2. Changer manuellement à 0
3. Attendre 5 secondes
4. Outils dev → États → Chercher "scene.avant_depart"
5. Vérifier: Scène existe maintenant ✅
6. Vérifier: Mode salon = Absent
7. Vérifier: Mode cuisine = Absent
```

### Test automation retour

```
1. Outils dev → États → zone.home
2. Changer de 0 à 1
3. Attendre 1 minute
4. Notification: "Modes de chauffage restaures" ✅
5. Vérifier: Modes restaurés
```

### Test remotes

```
1. Outils dev → États → remote.clim_salon
2. Cliquer TURN OFF
3. Attendre 6 secondes
4. Vérifier: Repassé à ON automatiquement ✅
```

---

## 🎯 RÉSUMÉ

**6 automations créées via UI:**

1. ✅ Départ maison (crée scène + mode absent)
2. ✅ Retour maison (restaure scène)
3. ✅ Activation remotes démarrage
4. ✅ Réactivation remote Salon
5. ✅ Réactivation remote Maeva
6. ✅ Réactivation remote Axel

**Avantages UI vs YAML:**
- Pas de timeout
- Validation en temps réel
- Plus simple
- Pas d'erreur indentation

**Temps total:** 10 minutes

---

## 💡 ASTUCE

Si tu veux voir le YAML généré par l'UI:

```
Automations → Cliquer sur une automation
→ ... (3 points) → Modifier au format YAML
→ Copier le YAML généré
```

Utile pour backups ou documentation!

---

**Utilise ce guide pour créer TOUTES les automations via UI!** ✅

Aucun timeout, aucun problème YAML, juste point-and-click.
