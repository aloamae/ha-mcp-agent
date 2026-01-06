# GUIDE UI SIMPLE - ÉTAPE PAR ÉTAPE

**Temps:** 5 minutes
**Méthode:** Interface graphique seulement

---

## 🎯 AUTOMATION 1: DÉPART

### Via l'interface HA (PAS de YAML)

```
1. Automations → + CRÉER UNE AUTOMATION

2. Nom: Depart maison

3. DÉCLENCHEUR:
   - Cliquer "+ Ajouter un déclencheur"
   - Sélectionner: État
   - Entité: zone.home
   - À: 0
   - Laisser "De:" vide

4. ACTION 1 - Créer scène:
   - Cliquer "+ Ajouter une action"
   - Sélectionner: Appeler un service
   - Service: Chercher "scene.create"
   - NE PAS utiliser l'éditeur visuel des données
   - Cliquer "BASCULER VERS LE MODE YAML" (en bas)
   - Copier EXACTEMENT:

scene_id: avant_depart
snapshot_entities:
  - input_select.mode_chauffage_salon
  - input_select.mode_chauffage_cuisine

5. ACTION 2 - Mode Salon Absent:
   - Cliquer "+ Ajouter une action"
   - Sélectionner: Appeler un service
   - Service: Chercher "input_select.select_option"
   - Cible: input_select.mode_chauffage_salon
   - Option: Hors-Gel(16)

6. ACTION 3 - Mode Cuisine Absent:
   - Cliquer "+ Ajouter une action"
   - Sélectionner: Appeler un service
   - Service: Chercher "input_select.select_option"
   - Cible: input_select.mode_chauffage_cuisine
   - Option: Hors-Gel(16)

7. ENREGISTRER
```

---

## 🎯 AUTOMATION 2: RETOUR

### Via l'interface HA

```
1. Automations → + CRÉER UNE AUTOMATION

2. Nom: Retour maison

3. DÉCLENCHEUR:
   - Cliquer "+ Ajouter un déclencheur"
   - Sélectionner: État
   - Entité: zone.home
   - De: 0
   - Laisser "À:" vide

4. ACTION 1 - Délai:
   - Cliquer "+ Ajouter une action"
   - Sélectionner: Délai
   - Heures: 0
   - Minutes: 1
   - Secondes: 0

5. ACTION 2 - Restaurer scène:
   - Cliquer "+ Ajouter une action"
   - Sélectionner: Appeler un service
   - Service: Chercher "scene.turn_on"
   - Cible: scene.avant_depart

6. ENREGISTRER
```

---

## 🎯 AUTOMATION 3: ACTIVER REMOTES DÉMARRAGE

### Via l'interface HA

```
1. Automations → + CRÉER UNE AUTOMATION

2. Nom: Activer remotes demarrage

3. DÉCLENCHEUR:
   - Cliquer "+ Ajouter un déclencheur"
   - Sélectionner: Démarrage de Home Assistant

4. ACTION 1 - Délai:
   - Cliquer "+ Ajouter une action"
   - Sélectionner: Délai
   - Heures: 0
   - Minutes: 0
   - Secondes: 30

5. ACTION 2 - Activer remotes:
   - Cliquer "+ Ajouter une action"
   - Sélectionner: Appeler un service
   - Service: Chercher "homeassistant.turn_on"
   - Cible:
     → Cliquer "Ajouter une entité"
     → Sélectionner: remote.clim_salon
     → Cliquer "Ajouter une entité"
     → Sélectionner: remote.clim_maeva
     → Cliquer "Ajouter une entité"
     → Sélectionner: remote.clim_axel

6. ENREGISTRER
```

---

## 🎯 AUTOMATION 4: RÉACTIVER REMOTE SALON

### Via l'interface HA

```
1. Automations → + CRÉER UNE AUTOMATION

2. Nom: Reactiver remote Salon

3. DÉCLENCHEUR:
   - Cliquer "+ Ajouter un déclencheur"
   - Sélectionner: État
   - Entité: remote.clim_salon
   - À: off
   - Laisser "De:" vide

4. ACTION 1 - Délai:
   - Cliquer "+ Ajouter une action"
   - Sélectionner: Délai
   - Heures: 0
   - Minutes: 0
   - Secondes: 5

5. ACTION 2 - Activer:
   - Cliquer "+ Ajouter une action"
   - Sélectionner: Appeler un service
   - Service: Chercher "homeassistant.turn_on"
   - Cible: remote.clim_salon

6. ENREGISTRER
```

---

## 🎯 AUTOMATION 5: RÉACTIVER REMOTE MAEVA

**Répéter exactement comme Automation 4, mais:**
- Nom: Reactiver remote Maeva
- Entité déclencheur: remote.clim_maeva
- Cible action: remote.clim_maeva

---

## 🎯 AUTOMATION 6: RÉACTIVER REMOTE AXEL

**Répéter exactement comme Automation 4, mais:**
- Nom: Reactiver remote Axel
- Entité déclencheur: remote.clim_axel
- Cible action: remote.clim_axel

---

## ✅ VALIDATION

### Test automation départ

```
1. Outils dev → États → zone.home
2. Cliquer sur l'entité
3. Changer l'état à: 0
4. Attendre 5 secondes
5. Automations → Depart maison → Historique
6. Vérifier: Dernière exécution réussie
7. Outils dev → États → Chercher "scene"
8. Vérifier: scene.avant_depart existe ✅
```

### Test automation retour

```
1. Outils dev → États → zone.home
2. Changer l'état de 0 à: 1
3. Attendre 1 minute
4. Automations → Retour maison → Historique
5. Vérifier: Dernière exécution réussie
6. Vérifier: Modes restaurés ✅
```

### Test remotes

```
1. Redémarrer Home Assistant
2. Attendre 1 minute
3. Outils dev → États → remote.clim_salon
4. Vérifier: État = on ✅

5. Cliquer "TURN OFF"
6. Attendre 6 secondes
7. Vérifier: Repassé à on automatiquement ✅
```

---

## 💡 IMPORTANT

### NE PAS créer de scène manuellement

La scène `avant_depart` est créée **AUTOMATIQUEMENT** par l'automation de départ.

Tu ne dois PAS:
- ❌ Aller dans Scènes → + Créer
- ❌ Créer une scène "avant_depart" manuellement

L'automation le fait toute seule avec `scene.create`.

---

## 🐛 SI PROBLÈME

### Automation timeout encore

**Utilise la version YAML simple:**

```
Automations → + CRÉER
→ ... → Modifier au format YAML
→ Copier fichier: automation_depart_simple.yaml
→ ENREGISTRER
```

### Scène ne se crée pas

**Vérifier:**
```
1. Automation départ activée (ON)
2. Exécuter manuellement: Automations → Depart maison → EXÉCUTER
3. Attendre 5 secondes
4. Outils dev → États → Chercher "avant_depart"
5. Si pas là → Vérifier logs: Outils dev → Logs
```

---

**Suis ce guide EXACTEMENT, étape par étape!** ✅

**Temps total:** 5 minutes pour les 6 automations.
