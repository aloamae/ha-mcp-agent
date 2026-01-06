# GUIDE D'INSTALLATION - AUTOMATION CHAUDIÈRE CORRIGÉE

## 🎯 OBJECTIF

Remplacer l'automation `Chauffage - Pilotage Chaudière GAZ` existante par la version corrigée avec:
- ✅ Seuils température ±0.5°C (au lieu de ±1°C)
- ✅ Zone morte intelligente (maintien au lieu d'éteindre)
- ✅ Logs détaillés pour debugging

---

## 📋 PRÉREQUIS

Avant de commencer:

```
☐ Accès à Home Assistant (http://192.168.0.166:8123)
☐ Droits d'administration
☐ Sauvegarde récente (recommandé)
```

---

## 🔍 MÉTHODE 1: VIA L'INTERFACE HOME ASSISTANT (RECOMMANDÉ)

### Étape 1: Sauvegarder l'automation actuelle

1. **Ouvrir Home Assistant:**
   - Aller sur http://192.168.0.166:8123
   - Se connecter

2. **Accéder aux automations:**
   - Menu (☰) → **Paramètres**
   - Cliquer sur **Automations et scènes**

3. **Trouver l'automation:**
   - Chercher: `Chauffage - Pilotage Chaudière GAZ`
   - OU chercher: `chauffage_gaz_control` (ID)

4. **Sauvegarder:**
   - Cliquer sur l'automation
   - Cliquer sur les **3 points** (⋮) en haut à droite
   - Sélectionner **"Modifier au format YAML"**
   - **Copier TOUT le YAML** et le sauvegarder dans un fichier texte

### Étape 2: Remplacer par la version corrigée

1. **Toujours dans l'éditeur YAML:**
   - **Tout sélectionner** (Ctrl+A)
   - **Supprimer**

2. **Ouvrir le fichier corrigé:**
   - Ouvrir: `C:\DATAS\AI\Projets\Perso\Domotique\automation_chauffage_pilotage_chaudiere_corrigee.yaml`

3. **Copier le contenu complet:**
   - Sélectionner tout le contenu
   - Copier (Ctrl+C)

4. **Coller dans Home Assistant:**
   - Retour dans l'éditeur YAML HA
   - Coller (Ctrl+V)

5. **Vérifier:**
   - Vérifier qu'il n'y a **pas d'erreur de syntaxe**
   - Le YAML doit être correctement indenté

6. **Sauvegarder:**
   - Cliquer sur **"ENREGISTRER"**
   - Si erreur → Revenir à l'Étape 1 et recommencer

### Étape 3: Vérifier que ça fonctionne

1. **Vérifier l'automation:**
   - Retour dans **Automations et scènes**
   - Chercher `Chauffage - Pilotage Chaudière GAZ`
   - Vérifier qu'elle est **activée** (ON)

2. **Tester manuellement:**
   - Cliquer sur l'automation
   - Cliquer sur **"EXÉCUTER"** en haut à droite
   - Vérifier qu'aucune erreur n'apparaît

3. **Vérifier les logs:**
   - **Outils de développement** → **Logs**
   - Chercher: `chauffage` ou `ZONE MORTE` ou `ALLUMAGE`
   - Tu devrais voir un message toutes les 3 minutes

---

## 🔧 MÉTHODE 2: VIA LE FICHIER AUTOMATIONS.YAML

### Prérequis supplémentaires

```
☐ Accès SSH ou File Editor add-on installé
☐ Connaissance de l'édition YAML
```

### Étape 1: Sauvegarder

```bash
# Via SSH
cd /config
cp automations.yaml automations.yaml.backup.$(date +%Y%m%d_%H%M%S)

# Vérifier la sauvegarde
ls -lh automations.yaml*
```

**OU via File Editor:**
1. Ouvrir File Editor
2. Ouvrir `automations.yaml`
3. Tout copier dans un nouveau fichier
4. Sauvegarder comme `automations.yaml.backup`

### Étape 2: Identifier l'automation à remplacer

1. **Ouvrir automations.yaml:**
   - Via SSH: `nano /config/automations.yaml`
   - Via File Editor: Ouvrir le fichier

2. **Trouver la section:**
   ```yaml
   - id: chauffage_gaz_control
     alias: Chauffage - Pilotage Chaudière GAZ
     triggers:
     ...
     mode: single
   ```

3. **Noter les lignes:**
   - Ligne de début: `- id: chauffage_gaz_control`
   - Ligne de fin: `mode: single` (de cette automation)

### Étape 3: Remplacer

1. **Supprimer l'ancienne automation:**
   - Depuis `- id: chauffage_gaz_control`
   - Jusqu'au `mode: single` de cette automation
   - **ATTENTION:** Ne pas supprimer l'automation suivante!

2. **Copier la nouvelle:**
   - Ouvrir: `automation_chauffage_pilotage_chaudiere_corrigee.yaml`
   - Copier TOUT le contenu

3. **Coller au même endroit:**
   - Coller exactement à l'emplacement de l'ancienne
   - **Vérifier l'indentation** (généralement 0 espace au début)

4. **Sauvegarder:**
   - Via nano: Ctrl+O, Enter, Ctrl+X
   - Via File Editor: Cliquer sur "Enregistrer"

### Étape 4: Recharger les automations

1. **Via l'interface:**
   - **Outils de développement** → **YAML**
   - Section "Configuration YAML"
   - Cliquer sur **"AUTOMATIONS"**
   - Cliquer sur **"Recharger les automations"**

2. **Via SSH:**
   ```bash
   ha automation reload
   ```

3. **Vérifier:**
   - Aller dans **Automations et scènes**
   - Chercher `Chauffage - Pilotage Chaudière GAZ`
   - Vérifier qu'elle apparaît sans erreur

---

## ✅ VÉRIFICATION POST-INSTALLATION

### 1. Vérifier l'automation

```
☐ 1. Ouvrir: Paramètres → Automations et scènes
☐ 2. Chercher: "Chauffage - Pilotage Chaudière GAZ"
☐ 3. Vérifier: État = ON (activée)
☐ 4. Cliquer dessus
☐ 5. Vérifier description: "seuils ±0.5°C"
☐ 6. Cliquer sur "..." → "Modifier au format YAML"
☐ 7. Vérifier présence de: ">= 0.5" et "<= -0.5"
```

### 2. Tester l'exécution

```
☐ 1. Dans l'automation, cliquer "EXÉCUTER"
☐ 2. Vérifier: Aucune erreur
☐ 3. Aller dans: Outils de développement → États
☐ 4. Chercher: switch.thermostat
☐ 5. Vérifier: État change (on/off) selon températures
```

### 3. Vérifier les logs

```
☐ 1. Outils de développement → Logs
☐ 2. Attendre 3 minutes (cycle automatique)
☐ 3. Chercher un message:
     - "🔥 ALLUMAGE chaudière"
     - "❄️ EXTINCTION chaudière"
     - "⏸️ ZONE MORTE - Maintien état"
☐ 4. Vérifier: Températures affichées correctement
```

### 4. Vérifier le comportement réel

**Test zone morte:**

```
Situation:
- Consigne: 19°C
- Température Cuisine: 18.7°C (delta = +0.3°C)
- Température Parents: 18.8°C (delta = +0.2°C)
- Température Loann: 18.6°C (delta = +0.4°C)

Résultat attendu:
✅ Message: "⏸️ ZONE MORTE - Maintien état chaudière"
✅ Chaudière: MAINTIEN de son état actuel (ne s'éteint PAS)
```

**Test allumage:**

```
Situation:
- Consigne: 19°C
- UNE pièce à 18.4°C (delta = +0.6°C >= +0.5°C)

Résultat attendu:
✅ Message: "🔥 ALLUMAGE chaudière"
✅ Chaudière: ON
```

**Test extinction:**

```
Situation:
- Consigne: 19°C
- TOUTES les pièces à 19.6°C+ (delta <= -0.5°C)

Résultat attendu:
✅ Message: "❄️ EXTINCTION chaudière (trop chaud)"
✅ Chaudière: OFF
```

---

## 🐛 DÉPANNAGE

### Erreur: "Message malformed"

**Cause:** Problème d'indentation YAML

**Solution:**
1. Vérifier que chaque niveau d'indentation = **2 espaces**
2. Pas de tabulations (Tab)
3. Copier à nouveau le fichier corrigé

### Erreur: "Unknown tag !input"

**Cause:** YAML invalide

**Solution:**
1. Revenir à l'Étape 1
2. Restaurer la sauvegarde
3. Recommencer en copiant exactement le fichier fourni

### Automation ne se déclenche pas

**Vérifications:**
```
☐ 1. Automation activée? (État ON)
☐ 2. Mode = single (pas queued)
☐ 3. Triggers = time_pattern, minutes: /3
☐ 4. Aucune condition bloquante
```

**Test manuel:**
```
1. Cliquer sur l'automation
2. Cliquer "EXÉCUTER"
3. Si ça marche → Attendre 3 min pour le cycle auto
4. Si erreur → Vérifier les logs
```

### Logs n'apparaissent pas

**Vérifications:**
```
☐ 1. Script script.log_chauffage existe?
     → Outils dev → Services → script.log_chauffage
☐ 2. Si inexistant, retirer les appels script.log_chauffage
     du YAML (lignes avec "action: script.log_chauffage")
```

### Chaudière ne s'allume/éteint pas

**Vérifications:**
```
☐ 1. switch.thermostat fonctionne?
     → Outils dev → États → switch.thermostat
     → Tester manuellement ON/OFF
☐ 2. Températures disponibles?
     → Vérifier sensor.th_cuisine_temperature
     → Vérifier sensor.th_parents_temperature
     → Vérifier sensor.th_loann_temperature
☐ 3. Mode vacances OFF?
     → Vérifier input_boolean.mode_vacance
```

---

## 📊 COMPARAISON AVANT/APRÈS

### Seuils température

| Température | Consigne | Delta | AVANT (±1°C) | APRÈS (±0.5°C) |
|-------------|----------|-------|--------------|----------------|
| 18.7°C | 19°C | +0.3°C | ❌ ÉTEINT (default) | ✅ MAINTIEN |
| 18.4°C | 19°C | +0.6°C | ❌ MAINTIEN | ✅ ALLUME |
| 19.6°C | 19°C | -0.6°C | ❌ MAINTIEN | ✅ ÉTEINT |
| 18.0°C | 19°C | +1.0°C | ✅ ALLUME | ✅ ALLUME |
| 20.0°C | 19°C | -1.0°C | ✅ ÉTEINT | ✅ ÉTEINT |

### Messages logs

**AVANT:**
```
(Pas de logs, comportement silencieux)
```

**APRÈS:**
```
🔥 ALLUMAGE chaudière
Cuisine: 18.2°C (+0.8°C)
Parents: 18.5°C (+0.5°C)
Loann: 18.7°C (+0.3°C)
Consigne: 19°C

⏸️ ZONE MORTE - Maintien état chaudière
Cuisine: 18.7°C (+0.3°C)
Parents: 18.8°C (+0.2°C)
Loann: 18.6°C (+0.4°C)
Consigne: 19°C
État chaudière: on

❄️ EXTINCTION chaudière (trop chaud)
Cuisine: 19.6°C (-0.6°C)
Parents: 19.7°C (-0.7°C)
Loann: 19.8°C (-0.8°C)
Consigne: 19°C
```

---

## 🎯 RÉSUMÉ

### Ce qui change:

1. **Seuils:** ±1°C → ±0.5°C
   - Réactivité doublée
   - Meilleur confort

2. **Zone morte:** Éteint → Maintien
   - Évite oscillations
   - Moins de cycles on/off

3. **Logs:** Ajoutés
   - Debugging facilité
   - Visibilité sur décisions

### Fichiers modifiés:

- `automations.yaml` (1 automation remplacée)

### Fichiers créés:

- `automations.yaml.backup` (sauvegarde)

### À surveiller:

- Logs toutes les 3 minutes
- Comportement chaudière
- Températures stables

---

## 📞 BESOIN D'AIDE?

**Si problème:**

1. **Restaurer la sauvegarde:**
   ```bash
   # Via SSH
   cp automations.yaml.backup automations.yaml
   ha automation reload
   ```

   **Via interface:**
   - Copier le YAML sauvegardé à l'Étape 1.1.4
   - Le remettre dans l'automation

2. **Consulter les docs:**
   - [GUIDE_ORDRE_PRIORITE_CHAUFFAGE.md](GUIDE_ORDRE_PRIORITE_CHAUFFAGE.md)
   - [ANALYSE_PRIORITES_CHAUFFAGE.md](ANALYSE_PRIORITES_CHAUFFAGE.md)

3. **Vérifier les logs HA:**
   - Outils de développement → Logs
   - Chercher erreurs "automation" ou "chauffage"

---

**L'installation est terminée!** ✅

Attends 3 minutes pour le premier cycle automatique et vérifie les logs.
