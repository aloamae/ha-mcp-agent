# INSTALLATION RAPIDE - AUTOMATION CORRIGÉE

## ⚡ MÉTHODE RAPIDE (5 MINUTES)

### 📋 CE DONT TU AS BESOIN

1. ✅ Accès à Home Assistant via navigateur: http://192.168.0.166:8123
2. ✅ Le fichier: `automation_chauffage_pilotage_chaudiere_corrigee.yaml`
3. ✅ Un éditeur de texte (Notepad)

---

## 🚀 ÉTAPES D'INSTALLATION

### ÉTAPE 1: Ouvrir le fichier automation corrigée

```
1. Double-cliquer sur:
   automation_chauffage_pilotage_chaudiere_corrigee.yaml

2. Ou clic droit → "Ouvrir avec" → Notepad

3. TOUT SÉLECTIONNER (Ctrl+A)

4. COPIER (Ctrl+C)
```

---

### ÉTAPE 2: Ouvrir Home Assistant

```
1. Ouvrir le navigateur

2. Aller sur: http://192.168.0.166:8123

3. Se connecter si nécessaire
```

---

### ÉTAPE 3: Accéder à l'automation

```
1. Cliquer sur le menu hamburger (☰) en haut à gauche

2. Cliquer sur "Paramètres"

3. Cliquer sur "Automations et scènes"

4. Dans la barre de recherche, taper: "chaudière"

5. Cliquer sur: "Chauffage - Pilotage Chaudière GAZ"
```

**Si l'automation n'existe pas:**
```
1. Cliquer sur "+ CRÉER UNE AUTOMATION" (en bas à droite)
2. Cliquer sur "..." (3 points) en haut à droite
3. Cliquer sur "Modifier au format YAML"
4. Passer directement à ÉTAPE 4 point 3
```

---

### ÉTAPE 4: Remplacer l'automation

```
1. Dans l'automation, cliquer sur les 3 POINTS (⋮) en haut à droite

2. Cliquer sur "Modifier au format YAML"

3. TOUT SÉLECTIONNER dans l'éditeur YAML (Ctrl+A)

4. SUPPRIMER (Delete ou Backspace)

5. COLLER le contenu copié à l'ÉTAPE 1 (Ctrl+V)

6. Vérifier que le YAML est correctement affiché
   (pas d'erreur rouge)

7. Cliquer sur "ENREGISTRER" en bas à droite
```

---

### ÉTAPE 5: Vérifier l'installation

```
1. Tu devrais revenir à la vue de l'automation

2. Vérifier:
   ✓ Nom: "Chauffage - Pilotage Chaudière GAZ"
   ✓ Description: "seuils ±0.5°C"
   ✓ État: Activée (ON) - bouton bleu

3. Cliquer sur "EXÉCUTER" (en haut à droite)
   pour tester

4. Si pas d'erreur → C'est bon! ✅
```

---

### ÉTAPE 6: Vérifier les logs

```
1. Cliquer sur le menu (☰)

2. Cliquer sur "Outils de développement"

3. Cliquer sur l'onglet "Logs"

4. Attendre 3 minutes (premier cycle automatique)

5. Chercher dans les logs (Ctrl+F):
   - "ZONE MORTE"
   - "ALLUMAGE"
   - "EXTINCTION"

6. Tu devrais voir un message comme:
   "⏸️ ZONE MORTE - Maintien état chaudière"
   ou
   "🔥 ALLUMAGE chaudière"
```

---

## ✅ C'EST TERMINÉ!

L'automation corrigée est maintenant installée et fonctionne.

**Ce qui a changé:**
- ✅ Seuils: ±1°C → ±0.5°C (2x plus réactif)
- ✅ Zone morte: Éteint → Maintien (évite oscillations)
- ✅ Logs ajoutés (debugging)

---

## 🐛 EN CAS DE PROBLÈME

### Problème 1: "Message malformed" ou erreur YAML

**Solution:**
```
1. Retourner à l'ÉTAPE 4
2. Recommencer en copiant À NOUVEAU le fichier
3. Vérifier qu'il n'y a PAS de TAB (tabulations)
4. Vérifier l'indentation (2 espaces par niveau)
```

### Problème 2: L'automation ne se déclenche pas

**Vérifications:**
```
1. Vérifier que l'automation est ACTIVÉE (bouton ON)
2. Attendre 3 minutes pour le premier cycle
3. Vérifier dans Outils dev → États:
   - switch.thermostat (existe?)
   - sensor.th_cuisine_temperature (existe?)
   - sensor.th_parents_temperature (existe?)
   - sensor.th_loann_temperature (existe?)
```

### Problème 3: Pas de logs

**Cause possible:** Script script.log_chauffage n'existe pas

**Solution:**
```
1. Retourner dans l'automation
2. "..." → "Modifier au format YAML"
3. Rechercher toutes les lignes contenant:
   "action: script.log_chauffage"
4. Supprimer ces blocs (lignes avec "- action: script.log_chauffage"
   et les 2 lignes suivantes "data:" et "message:")
5. Sauvegarder
```

**Exemple de ce qu'il faut supprimer:**
```yaml
- action: script.log_chauffage
  data:
    message: >
      🔥 ALLUMAGE chaudière
      ...
```

### Problème 4: Chaudière ne réagit pas

**Vérifications:**
```
1. Outils dev → États → switch.thermostat
2. Essayer de l'allumer/éteindre manuellement
3. Si ça ne marche pas → Problème avec le switch, pas l'automation
```

---

## 📸 CAPTURES D'ÉCRAN (Aide visuelle)

### Où cliquer dans Home Assistant:

```
Navigation:
Menu (☰) → Paramètres → Automations et scènes
→ Chercher "chaudière"
→ Cliquer sur l'automation
→ ⋮ (3 points) → "Modifier au format YAML"

Éditeur YAML:
[Zone de texte avec YAML]
→ Ctrl+A (tout sélectionner)
→ Delete (supprimer)
→ Ctrl+V (coller le nouveau)
→ Bouton "ENREGISTRER" en bas
```

---

## 📊 VÉRIFICATION VISUELLE

**Dans l'éditeur YAML, tu devrais voir:**

```yaml
id: chauffage_gaz_control
alias: Chauffage - Pilotage Chaudière GAZ
description: Pilotage automatique de la chaudière selon températures des pièces (seuils ±0.5°C)

triggers:
  - minutes: /3
    trigger: time_pattern

actions:
  - variables:
      consigne: >
        {% if is_state('input_boolean.mode_vacance','on') %}
          16
        ...

      need_heat: >
        {{ (consigne - t_cuisine) >= 0.5     ← VÉRIFIER: 0.5 (pas 1)
           or (consigne - t_parents) >= 0.5  ← VÉRIFIER: 0.5 (pas 1)
           ...

      too_hot: >
        {{ (consigne - t_cuisine) <= -0.5    ← VÉRIFIER: -0.5 (pas -1)
           and (consigne - t_parents) <= -0.5 ← VÉRIFIER: -0.5 (pas -1)
           ...
```

**Points clés à vérifier:**
- ✅ `>= 0.5` (et PAS `>= 1`)
- ✅ `<= -0.5` (et PAS `<= -1`)
- ✅ Section `default:` avec message "ZONE MORTE"

---

## 🎯 RÉSUMÉ

**Temps nécessaire:** 5 minutes

**Étapes:**
1. Copier le fichier YAML corrigé
2. Ouvrir HA → Automations
3. Trouver l'automation chaudière
4. Modifier au format YAML
5. Remplacer tout
6. Sauvegarder
7. Tester

**Vérification:**
- Bouton EXÉCUTER fonctionne
- Logs apparaissent (3 min)
- Messages avec températures

---

## 🆘 BESOIN D'AIDE IMMÉDIATE?

**Option 1: Copier-coller direct**

Ouvre ce fichier et copie TOUT ce qu'il y a dedans:
```
C:\DATAS\AI\Projets\Perso\Domotique\automation_chauffage_pilotage_chaudiere_corrigee.yaml
```

Puis colle-le directement dans l'éditeur YAML de Home Assistant.

**Option 2: Vérifier que HA est accessible**

Ouvre le navigateur et va sur:
```
http://192.168.0.166:8123
```

Si ça ne charge pas:
- Vérifier que Home Assistant est démarré
- Vérifier l'adresse IP
- Essayer depuis le PC qui héberge HA

**Option 3: Restaurer l'ancienne version**

Si tu as fait une sauvegarde à l'ÉTAPE 4 point 3:
- Copie le YAML sauvegardé
- Remets-le dans l'automation
- Sauvegarde

---

**L'installation est simple et rapide!** ✅

Suis les étapes 1 à 6 et tu auras terminé en 5 minutes.
