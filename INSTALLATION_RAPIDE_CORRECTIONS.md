# INSTALLATION RAPIDE - FICHIERS CORRIGES

**Date:** 20 décembre 2025

---

## ✅ FICHIERS CORRIGES

### 1. Automation retour mode présence (CORRIGEE)

**Fichier:** `automation_mode_presence_retour.yaml`

**Problème résolu:** "Message malformed: extra keys not allowed"
- Changé `triggers:` → `trigger:`
- Changé `actions:` → `action:`
- Changé `conditions:` → `condition:`
- Retiré emojis et accents

**Installation:**

1. **Copier le fichier:**
   ```
   Ouvrir: automation_mode_presence_retour.yaml
   Ctrl+A → Ctrl+C
   ```

2. **Dans Home Assistant:**
   ```
   Paramètres → Automations et scènes
   → + CRÉER UNE AUTOMATION
   → ... (3 points) → Modifier au format YAML
   → COLLER (Ctrl+V)
   → ENREGISTRER
   ```

3. **Vérifier:**
   ```
   Nom: "Mode Presence - Retour a la maison"
   État: Activée (ON)
   Pas d'erreur YAML
   ```

---

### 2. Dashboard debugging (CORRIGE)

**Fichier:** `dashboard_debugging_simple.yaml`

**Problèmes résolus:**
- Retiré custom cards (custom:template-entity-row, custom:apexcharts-card)
- Retiré boutons complexes
- Utilisé uniquement cartes standard HA
- YAML 100% valide

**Installation:**

1. **Copier le fichier:**
   ```
   Ouvrir: dashboard_debugging_simple.yaml
   Ctrl+A → Ctrl+C
   ```

2. **Dans Home Assistant:**
   ```
   Paramètres → Tableaux de bord
   → + AJOUTER UN TABLEAU DE BORD
   → Nom: "Debugging Modes"
   → Icône: mdi:bug
   → CRÉER
   ```

3. **Ajouter le contenu:**
   ```
   Ouvrir le nouveau tableau de bord
   → ... (3 points) → Modifier le tableau de bord
   → + AJOUTER UNE CARTE
   → En bas: "Afficher l'éditeur de code"
   → SUPPRIMER tout le contenu
   → COLLER le YAML complet
   → ENREGISTRER
   ```

**Contenu du dashboard:**
- Section 1: Ordre de priorité (6 niveaux)
- Section 2: Températures actuelles
- Section 3: Climatisations Broadlink (états)
- Section 4: Tests rapides (instructions)
- Section 5: Logs chauffage (6h)

---

### 3. Script activation remotes Broadlink

**Fichier:** `activer_remotes_broadlink.ps1`

**Utilisation:**

```powershell
# Méthode 1: Via PowerShell
cd C:\DATAS\AI\Projets\Perso\Domotique
.\activer_remotes_broadlink.ps1

# Méthode 2: Avec token explicite
$env:HA_TOKEN = 'jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4'
.\activer_remotes_broadlink.ps1
```

**Ce que fait le script:**
1. Active `remote.clim_salon`
2. Active `remote.clim_maeva`
3. Active `remote.clim_axel`
4. Vérifie les états (ON/OFF)

**IMPORTANT:** Home Assistant doit être accessible (http://192.168.0.166:8123)

---

## 🔧 ACTIVATION MANUELLE DES REMOTES

**Si le script ne fonctionne pas (HA inaccessible):**

### Méthode 1: Via l'interface HA

```
Outils de développement → États
→ Chercher: remote.clim_salon
→ Cliquer sur l'entité
→ Bouton "ACTIVER" ou "TURN ON"

Répéter pour:
- remote.clim_maeva
- remote.clim_axel
```

### Méthode 2: Via Services

```
Outils de développement → Services

Service: homeassistant.turn_on
Entité: remote.clim_salon
→ APPELER LE SERVICE

Répéter pour remote.clim_maeva et remote.clim_axel
```

### Méthode 3: Via automation temporaire

```yaml
# Automation one-shot pour activer les remotes
id: activer_remotes_temp
alias: TEMP - Activer remotes Broadlink
mode: single

trigger:
  - platform: homeassistant
    event: start

action:
  - service: homeassistant.turn_on
    target:
      entity_id:
        - remote.clim_salon
        - remote.clim_maeva
        - remote.clim_axel
```

**Installation:**
1. Créer cette automation dans HA
2. Redémarrer Home Assistant
3. Les remotes seront activés au démarrage
4. Supprimer l'automation après

---

## ✅ VÉRIFICATION POST-INSTALLATION

### Automation retour présence

```
[ ] Automation créée dans HA
[ ] Nom: "Mode Presence - Retour a la maison"
[ ] État: ON (activée)
[ ] Pas d'erreur YAML
[ ] Test manuel: Outils dev → Automation → Exécuter
```

### Dashboard debugging

```
[ ] Tableau de bord créé
[ ] Toutes les sections visibles
[ ] Pas d'erreur "carte inconnue"
[ ] Entités affichées correctement
[ ] Cartes thermostat climatisations OK
```

### Remotes Broadlink

```
[ ] Outils dev → États → remote.clim_salon = ON
[ ] Outils dev → États → remote.clim_maeva = ON
[ ] Outils dev → États → remote.clim_axel = ON
```

### Test climatisation

```
[ ] Outils dev → Services
    Service: climate.turn_on
    Entité: climate.climatisation_salon
    → APPELER LE SERVICE

[ ] Observer:
    - LED Broadlink clignote? (émission IR)
    - Climatisation physique réagit?
    - Pas d'erreur dans logs?
```

---

## 🐛 DÉPANNAGE

### Erreur "Message malformed" automation

**Cause:** YAML invalide

**Solution:**
1. Vérifier indentation (2 espaces par niveau)
2. Pas de tabulations (Tab)
3. Utiliser le fichier corrigé `automation_mode_presence_retour.yaml`
4. Copier EXACTEMENT le contenu

### Erreur carte verticale dashboard

**Cause:** Custom cards non installées

**Solution:**
1. Utiliser `dashboard_debugging_simple.yaml` (sans custom cards)
2. NE PAS utiliser `dashboard_debugging_modes_complet.yaml` (nécessite custom cards)

### Remotes Broadlink restent OFF

**Causes possibles:**

| Cause | Vérification | Solution |
|-------|--------------|----------|
| HA inaccessible | Ping 192.168.0.166 | Attendre que HA démarre |
| Broadlink déconnecté | HA → Intégrations | Vérifier connexion Broadlink |
| Commande ignorée | Logs HA | Chercher erreurs "broadlink" |

**Vérifier dans HA:**
```
Paramètres → Appareils et services
→ Chercher: Broadlink
→ Cliquer sur chaque appareil
→ Vérifier: État connecté
→ Vérifier: Entités remote.clim_* visibles
```

---

## 📊 RÉSUMÉ

### Fichiers à installer

1. ✅ `automation_mode_presence_retour.yaml` (CORRIGÉ)
2. ✅ `dashboard_debugging_simple.yaml` (CORRIGÉ)
3. ✅ `activer_remotes_broadlink.ps1` (Script PowerShell)

### Ordre d'installation

```
1. Démarrer Home Assistant
2. Installer automation retour présence (5 min)
3. Installer dashboard debugging (5 min)
4. Activer remotes Broadlink (1 min)
   → Via script PowerShell
   → OU manuellement dans HA
5. Tester climatisations
```

### Temps total: 15 minutes

---

## 📞 AIDE

### Automation chaudière
→ Voir: `INSTALLATION_RAPIDE_AUTOMATION.md`

### Climatisations détails
→ Voir: `REPONSE_COMPLETE_QUESTIONS_CHAUFFAGE.md`

### Priorités modes
→ Voir: `GUIDE_ORDRE_PRIORITE_CHAUFFAGE.md`

---

**Les fichiers sont maintenant corrigés et prêts à installer!** ✅
