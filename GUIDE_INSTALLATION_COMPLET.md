# GUIDE D'INSTALLATION COMPLET - SYSTÈME CHAUFFAGE & CLIMATISATIONS

**Date:** 20 décembre 2025
**Statut:** ✅ Automation chaudière installée | ⏳ Reste à installer

---

## ✅ DÉJÀ INSTALLÉ

### 1. Automation chaudière corrigée

**Fichier:** `automation_chauffage_pilotage_chaudiere_corrigee.yaml`

**État:** ✅ **INSTALLÉE ET FONCTIONNELLE**

**Preuve:** Log du 20/12 à 23:18
```
⏸️ ZONE MORTE - Maintien état chaudière
Cuisine: 19.19°C (-0.2°C)
Parents: 19.2°C (-0.2°C)
Loann: 19.7°C (-0.7°C)
Consigne: 19.0°C
État chaudière: on
```

**Changements:**
- Seuils: ±1°C → ±0.5°C ✅
- Zone morte: Éteint → Maintien état ✅
- Logs détaillés ✅

---

## 📥 À INSTALLER MAINTENANT

### 2. Automation retour mode présence

**Fichier:** `automation_mode_presence_retour.yaml`

**Objectif:** Restaure automatiquement les modes de chauffage quand tu rentres à la maison

**Installation:**

1. **Copier le fichier:**
   - Ouvrir: `automation_mode_presence_retour.yaml`
   - Ctrl+A → Ctrl+C (tout copier)

2. **Dans Home Assistant:**
   ```
   Paramètres → Automations et scènes
   → + CRÉER UNE AUTOMATION
   → ... (3 points) → Modifier au format YAML
   → Coller le YAML
   → ENREGISTRER
   ```

3. **Vérifier:**
   ```
   Nom: "Mode Présence - Retour à la maison"
   État: Activée (ON)
   Déclencheur: zone.home change de 0 à 1+
   ```

4. **Tester:**
   ```
   Option 1: Sortir puis rentrer (GPS)
   Option 2: Simuler dans Outils dev → États
     - Changer zone.home de 1 à 0 (départ)
     - Attendre 5 secondes
     - Changer zone.home de 0 à 1 (retour)
     - Vérifier logs: Message "RETOUR À LA MAISON"
   ```

---

### 3. Dashboard de debugging modes

**Fichier:** `dashboard_debugging_modes_complet.yaml`

**Objectif:** Visualiser et débugger tous les modes + climatisations

**Installation:**

1. **Copier le fichier:**
   - Ouvrir: `dashboard_debugging_modes_complet.yaml`
   - Ctrl+A → Ctrl+C (tout copier)

2. **Dans Home Assistant:**
   ```
   Paramètres → Tableaux de bord
   → + AJOUTER UN TABLEAU DE BORD
   → Nom: "Debugging Modes"
   → Icône: mdi:bug
   → Créer
   ```

3. **Ajouter le contenu:**
   ```
   Ouvrir le nouveau tableau de bord
   → ... (3 points) → Modifier le tableau de bord
   → + AJOUTER UNE CARTE
   → En bas: "Afficher l'éditeur de code"
   → Coller le YAML complet
   → ENREGISTRER
   ```

4. **Contenu du dashboard:**
   - Section 1: Ordre de priorité des modes
   - Section 2: Températures temps réel
   - Section 3: **Climatisations Broadlink** (diagnostic)
   - Section 4: Sensor mode_chauffage_global
   - Section 5: Logs en temps réel
   - Section 6: Tests & diagnostics
   - Section 7: Documentation

---

## 🔧 VÉRIFICATIONS À FAIRE DANS HA

### Quand Home Assistant sera accessible

**Checklist:**

1. **Climatisations Broadlink:**
   ```
   [ ] Outils dev → États → remote.clim_salon
       → Vérifier état = ON (pas OFF)
   [ ] Outils dev → États → remote.clim_maeva
       → Vérifier état = ON
   [ ] Outils dev → États → remote.clim_axel
       → Vérifier état = ON

   Si OFF → Utiliser le dashboard debugging → Bouton "Activer tous les remotes"
   ```

2. **Test manuel climatisation:**
   ```
   [ ] Outils dev → Services
       Service: climate.turn_on
       Entité: climate.climatisation_salon
       Appeler le service
   [ ] Observer:
       - LED Broadlink clignote?
       - Climatisation physique réagit?
       - Logs HA: erreur?
   ```

3. **Sensor mode_chauffage_global:**
   ```
   [ ] Paramètres → Auxiliaires
       → Chercher: "mode chauffage global"
       → Noter: Type (input_select, sensor template?)
       → Noter: Valeurs possibles

   OU

   [ ] Outils dev → États
       → Chercher: sensor.mode_chauffage_global
       → Noter: Attributs
       → Vérifier: Friendly name, device_class
   ```

4. **Automation mode présence retour:**
   ```
   [ ] Paramètres → Automations
       → Chercher: "Mode Présence - Retour"
       → Vérifier: Activée (ON)
       → Tester: Exécuter manuellement
       → Vérifier logs: Message "RETOUR À LA MAISON"
   ```

5. **Dashboard debugging:**
   ```
   [ ] Ouvrir le dashboard
   [ ] Vérifier toutes les entités affichées
   [ ] Tester boutons:
       - "Activer tous les remotes"
       - "Exécuter automation chaudière"
       - "Test climatisation Salon"
   ```

---

## 📊 DIAGNOSTIC CLIMATISATIONS

### Problème: "Broadlink ne répond pas"

**Causes possibles:**

| Symptôme | Cause | Solution |
|----------|-------|----------|
| Remote OFF dans HA | Entité désactivée | Dashboard → Activer remotes |
| LED ne clignote pas | Broadlink déconnecté | Vérifier IP, redémarrer appareil |
| Clim ne réagit pas | Code IR invalide | Vérifier device_code SmartIR |
| Erreur dans logs | SmartIR obsolète | HACS → Mettre à jour SmartIR |

**Vérification SmartIR:**

```
1. Paramètres → Modules complémentaires → HACS
2. Intégrations → Chercher: SmartIR
3. Vérifier version installée
4. Si < dernière version → Mettre à jour

5. Vérifier fichier climate code:
   /config/custom_components/smartir/codes/climate/XXXX.json
   (XXXX = device_code de ta climatisation)

6. Logs:
   Outils dev → Logs → Chercher: "smartir"
   Messages attendus:
   - "SmartIR climate component loaded"
   - "Device code XXXX loaded"
```

---

## 🎯 RÉSUMÉ DES FICHIERS

### Automations

| Fichier | Statut | Description |
|---------|--------|-------------|
| `automation_chauffage_pilotage_chaudiere_corrigee.yaml` | ✅ Installée | Pilotage chaudière ±0.5°C |
| `automation_mode_presence_retour.yaml` | ⏳ À installer | Retour mode présence |

### Dashboards

| Fichier | Statut | Description |
|---------|--------|-------------|
| `lovelace_dashboard_debugging_chauffage.yaml` | Ancien | Dashboard simple |
| `dashboard_debugging_modes_complet.yaml` | ⏳ À installer | **Dashboard complet** + climatisations |

### Documentation

| Fichier | Description |
|---------|-------------|
| `REPONSE_COMPLETE_QUESTIONS_CHAUFFAGE.md` | Analyse complète de toutes tes questions |
| `ANALYSE_MODE_PRESENCE.md` | Détails mode présence |
| `GUIDE_ORDRE_PRIORITE_CHAUFFAGE.md` | Guide priorités modes |
| `INSTALLATION_RAPIDE_AUTOMATION.md` | Guide installation rapide |
| `GUIDE_INSTALLATION_AUTOMATION_CORRIGEE.md` | Guide détaillé |
| `GUIDE_INSTALLATION_COMPLET.md` | **Ce fichier** |

### Scripts PowerShell

| Fichier | Description |
|---------|-------------|
| `installer_automation_corrigee_clean.ps1` | Installer automation chaudière |
| `analyser_modes_chauffage.ps1` | Analyser tous les modes |
| `analyser_climatisations.ps1` | Analyser climatisations |
| `get_climate_modes.ps1` | Récupérer modes climat disponibles |

---

## 🚀 ORDRE D'INSTALLATION RECOMMANDÉ

### Immédiat (5 minutes)

1. **Installer automation retour présence**
   - Copier `automation_mode_presence_retour.yaml`
   - Coller dans HA → Automations
   - Activer

2. **Installer dashboard debugging**
   - Copier `dashboard_debugging_modes_complet.yaml`
   - Créer nouveau tableau de bord
   - Coller le YAML

### Ensuite (10 minutes)

3. **Vérifier climatisations**
   - Ouvrir dashboard debugging
   - Section "Climatisations Broadlink"
   - Activer remotes si OFF
   - Tester manuellement

4. **Chercher sensor.mode_chauffage_global**
   - Dashboard debugging → Section 4
   - Ou Paramètres → Auxiliaires
   - Documenter la logique

### Optionnel (plus tard)

5. **Créer automations climatisations**
   - Pilotage automatique par température
   - Synchronisation avec modes chauffage
   - Planifications horaires

---

## ✅ VALIDATION POST-INSTALLATION

### Automation chaudière

```
✅ Log "ZONE MORTE" toutes les 3 min
✅ Seuils ±0.5°C actifs
✅ Maintien état en zone morte
✅ Températures affichées
```

### Automation retour présence

```
[ ] Activée dans Automations
[ ] Test manuel réussi
[ ] Log "RETOUR À LA MAISON" visible
[ ] Scène avant_depart restaurée
```

### Dashboard debugging

```
[ ] Toutes les sections affichées
[ ] Priorités modes visibles
[ ] Climatisations visibles
[ ] Boutons fonctionnent
[ ] Logs en temps réel OK
```

### Climatisations Broadlink

```
[ ] Remotes ON (pas OFF)
[ ] Test manuel réussi (LED clignote)
[ ] Climatisation physique réagit
[ ] Pas d'erreur dans logs SmartIR
```

---

## 🆘 BESOIN D'AIDE?

### Si problème avec automation chaudière
→ Voir: `INSTALLATION_RAPIDE_AUTOMATION.md`

### Si problème avec climatisations
→ Voir: `REPONSE_COMPLETE_QUESTIONS_CHAUFFAGE.md` (Partie 2)

### Si problème avec mode présence
→ Voir: `ANALYSE_MODE_PRESENCE.md`

### Si question sur priorités
→ Voir: `GUIDE_ORDRE_PRIORITE_CHAUFFAGE.md`

---

## 📞 SUPPORT

**Fichiers de diagnostic créés:**
- `DIAGNOSTIC_BROADLINK_FINAL.md` (historique Broadlink)
- `RECAPITULATIF_ANALYSE_CHAUFFAGE_COMPLETE.md` (synthèse)
- `RAPPORT_MODE_VACANCES.md` (analyse mode vacances)

**Scripts de diagnostic:**
- `analyser_modes_chauffage.ps1`
- `analyser_climatisations.ps1`
- `check_broadlink_status.ps1`

---

**Bon courage pour l'installation!** 🚀

Si tu rencontres un problème, consulte le fichier `REPONSE_COMPLETE_QUESTIONS_CHAUFFAGE.md` qui contient TOUTES les réponses à tes questions.
