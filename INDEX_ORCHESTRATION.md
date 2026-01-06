# Index - Orchestration Système Chauffage Home Assistant

**Date**: 2025-12-19
**Mission**: Analyse complète automations + Diagnostic Broadlink

---

## Documents Principaux

### 🎯 Démarrage Rapide

| Document | Objectif | Action |
|----------|----------|--------|
| **README_ORCHESTRATION_COMPLETE.md** | Guide complet d'exécution | 📖 **COMMENCER ICI** |

---

## 📊 Rapports d'Analyse

### 1. Automations de Chauffage

| Document | Contenu | Utilisation |
|----------|---------|-------------|
| **RECAPITULATIF_AUTOMATIONS_CHAUFFAGE.md** | Liste des 17 automations, timeline journalière, dépendances | Comprendre le système existant |

**Sections principales** :
- Inventaire des Automations
- Timeline Journalière
- Détails par Automation
- Dépendances et Helpers
- Ordre de Priorité

---

### 2. Diagnostic Broadlink

| Document | Contenu | Utilisation |
|----------|---------|-------------|
| **DIAGNOSTIC_BROADLINK.md** | Analyse des problèmes climatisations, solutions étape par étape | Réparer les climatisations |

**Sections principales** :
- État Actuel des Climatisations (Salon, Maeva, Axel)
- Erreurs Identifiées
- Analyse des Causes
- Solutions Recommandées
- Plan d'Action Étape par Étape

**Problème principal identifié** :
- Entités `remote.clim_*` désactivées (OFF)
- Broadlink Maeva (192.168.0.136) : Network timeout

---

### 3. Guide de Fonctionnement

| Document | Contenu | Utilisation |
|----------|---------|-------------|
| **GUIDE_ORDRE_FONCTIONNEMENT.md** | Explication de l'ordre d'exécution, flux décisionnel, cas d'usage | Comprendre la logique du système |

**Sections principales** :
- Cycle Journalier Complet (heure par heure)
- Modes de Fonctionnement (Auto, Vacances, Manuel)
- Flux Décisionnel (diagrammes)
- Interactions Entre Automations
- Cas d'Usage Concrets

---

## 🔧 Scripts PowerShell

### Scripts de Diagnostic

| Script | Fonction | Commande |
|--------|----------|----------|
| **collect_automation_data.ps1** | Collecte toutes les données HA | `.\collect_automation_data.ps1` |
| **analyze_automation_details.ps1** | Analyse détaillée des automations | `.\analyze_automation_details.ps1` |
| **check_broadlink_status.ps1** | Diagnostic Broadlink complet | `.\check_broadlink_status.ps1` |

### Prérequis

```powershell
# Définir le token HA
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"

# Naviguer vers le répertoire
cd "c:\DATAS\AI\Projets\Perso\Domotique"
```

---

## 📁 Fichiers Générés

### Exports JSON (après exécution des scripts)

| Fichier | Contenu | Taille |
|---------|---------|--------|
| `automation_data_export.json` | Données brutes de toutes les entités HA | ~50-100 KB |
| `automation_details_export.json` | Triggers, conditions, actions de chaque automation | ~100-200 KB |
| `broadlink_diagnostic_export.json` | État et problèmes des climatisations | ~10-20 KB |

---

## 🗺️ Plan d'Exécution Recommandé

### Phase 1 : Collecte (10 min)

```powershell
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"
cd "c:\DATAS\AI\Projets\Perso\Domotique"

.\collect_automation_data.ps1        # 2 min
.\analyze_automation_details.ps1      # 3 min
.\check_broadlink_status.ps1          # 2 min
```

### Phase 2 : Analyse (15 min)

1. Lire `README_ORCHESTRATION_COMPLETE.md`
2. Consulter les exports JSON
3. Lire `RECAPITULATIF_AUTOMATIONS_CHAUFFAGE.md`
4. Lire `DIAGNOSTIC_BROADLINK.md`

### Phase 3 : Réparation Broadlink (30-60 min)

Suivre le plan d'action dans `DIAGNOSTIC_BROADLINK.md` :
1. Tester connectivité Broadlink Maeva (192.168.0.136)
2. Redémarrer appareil si nécessaire
3. Activer les 3 entités `remote.clim_*`
4. Tester les 3 climatisations

### Phase 4 : Optimisation (optionnel, 30 min)

- Réserver adresses IP DHCP
- Ajouter monitoring
- Centraliser pilotage Broadlink

---

## 🔍 Navigation Rapide

### Par Problème

| Problème | Document | Section |
|----------|----------|---------|
| Climatisation ne démarre pas | `DIAGNOSTIC_BROADLINK.md` | État Actuel des Climatisations |
| Network timeout Broadlink | `DIAGNOSTIC_BROADLINK.md` | Erreurs Identifiées → Erreur 2 |
| Remote entity OFF | `DIAGNOSTIC_BROADLINK.md` | Solutions Recommandées → Solution #1 |
| Comprendre ordre automations | `GUIDE_ORDRE_FONCTIONNEMENT.md` | Cycle Journalier Complet |
| Mode vacances | `GUIDE_ORDRE_FONCTIONNEMENT.md` | Modes de Fonctionnement → Mode 2 |
| Doublon automation | `RECAPITULATIF_AUTOMATIONS_CHAUFFAGE.md` | Inventaire des Automations |

### Par Tâche

| Tâche | Document | Section |
|-------|----------|---------|
| Collecter données | `README_ORCHESTRATION_COMPLETE.md` | Phase 1 : Collecte des Données Réelles |
| Activer remote Broadlink | `DIAGNOSTIC_BROADLINK.md` | Solution #1 : Activer les Entités Remote |
| Redémarrer Broadlink | `DIAGNOSTIC_BROADLINK.md` | Solution #2 : Diagnostiquer et Réparer Broadlink Maeva |
| Tester climatisation | `DIAGNOSTIC_BROADLINK.md` | Phase 4 : Tests Fonctionnels |
| Comprendre timeline | `RECAPITULATIF_AUTOMATIONS_CHAUFFAGE.md` | Timeline Journalière |
| Ajouter monitoring | `DIAGNOSTIC_BROADLINK.md` | Prévention Future → Recommandation #2 |

---

## 📚 Documentation Complémentaire

### Fichiers Existants

| Fichier | Description |
|---------|-------------|
| `CLIMATE_CONTROL_BEST_PRACTICES.md` | Best practices pour contrôle climatisation (TRV, chaudière) |
| `MCP_COMMANDS_REFERENCE.md` | Référence des commandes MCP Home Assistant |
| `.claude/claude.md` | Playbook d'utilisation des agents HA |
| `.claude/home-assistant-commands.md` | Commandes MCP avec exemples |

---

## ⚙️ Configuration

### Home Assistant

| Paramètre | Valeur |
|-----------|--------|
| URL | http://192.168.0.166:8123 |
| Port MCP Agent | 8099 |
| Token | `jZT5-o3QZ...` (dans `.claude/.env`) |

### Broadlink

| Appareil | Entité Remote | Entité Climate | IP |
|----------|---------------|----------------|-----|
| Salon | `remote.clim_salon` | `climate.climatisation_salon` | 192.168.0.??? |
| Maeva | `remote.clim_maeva` | `climate.climatisation_maeva` | 192.168.0.136 |
| Axel | `remote.clim_axel` | `climate.climatisation_axel` | 192.168.0.??? |

---

## ✅ Checklist de Validation

### Avant Exécution

- [ ] PowerShell installé
- [ ] Accès à Home Assistant (http://192.168.0.166:8123)
- [ ] Token HA valide
- [ ] Scripts PowerShell présents dans le répertoire

### Après Collecte

- [ ] `automation_data_export.json` créé
- [ ] `automation_details_export.json` créé
- [ ] `broadlink_diagnostic_export.json` créé
- [ ] Pas d'erreurs dans les scripts

### Après Réparation Broadlink

- [ ] `remote.clim_salon` : ON
- [ ] `remote.clim_maeva` : ON
- [ ] `remote.clim_axel` : ON
- [ ] Ping Broadlink Maeva (192.168.0.136) OK
- [ ] Test climatisation Salon OK
- [ ] Test climatisation Maeva OK
- [ ] Test climatisation Axel OK

---

## 🆘 En Cas de Problème

### Script PowerShell Échoue

**Erreur** : "Variable HA_TOKEN non définie"

**Solution** :
```powershell
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"
```

**Erreur** : "Impossible de se connecter à Home Assistant"

**Solution** :
- Vérifier que HA est accessible : http://192.168.0.166:8123
- Vérifier le token
- Vérifier le réseau

### Broadlink Network Timeout

**Symptôme** : Ping 192.168.0.136 échoue

**Solution** :
1. Débrancher Broadlink RM4 Pro (chambre Maeva)
2. Attendre 10 secondes
3. Rebrancher
4. Attendre 30 secondes
5. Re-tester

### Remote Entity Reste OFF

**Symptôme** : Activation via UI ne fonctionne pas

**Solution** :
1. Redémarrer l'intégration Broadlink dans HA
2. Vérifier que l'appareil Broadlink est accessible
3. Si persistant : Supprimer et reconfigurer l'intégration

---

## 🚀 Actions Prioritaires

### 🔴 Critique (Faire Maintenant)

1. Exécuter `collect_automation_data.ps1`
2. Exécuter `check_broadlink_status.ps1`
3. Tester connectivité Broadlink Maeva (192.168.0.136)
4. Activer les 3 entités `remote.clim_*`

### 🟠 Important (Cette Semaine)

1. Analyser les doublons dans automations
2. Vérifier horaires (04:45 vs 05:45)
3. Réserver adresses IP DHCP pour Broadlink
4. Tester les 3 climatisations

### 🟡 Recommandé (Ce Mois)

1. Ajouter automation de monitoring
2. Centraliser pilotage Broadlink
3. Implémenter logging détaillé
4. Refactoring automations

---

## 📞 Support

### Ressources

- **Documentation Home Assistant** : https://www.home-assistant.io/docs/
- **Community Forum** : https://community.home-assistant.io/
- **Broadlink Integration** : https://www.home-assistant.io/integrations/broadlink/
- **SmartIR GitHub** : https://github.com/smartHomeHub/SmartIR

### Fichiers de Référence

- Configuration MCP : `c:\DATAS\AI\Projets\Perso\Domotique\.claude\mcp.json`
- Environnement : `c:\DATAS\AI\Projets\Perso\Domotique\.claude\.env`

---

## 📊 Statistiques de l'Orchestration

| Métrique | Valeur |
|----------|--------|
| Documents Markdown créés | 4 |
| Scripts PowerShell créés | 3 |
| Pages de documentation | ~70 |
| Temps estimé d'exécution | 1h30 - 2h |
| Problèmes identifiés | 3 (Remote OFF, Network timeout, Doublons) |
| Solutions proposées | 5 |

---

## 🎯 Objectifs Accomplis

- ✅ Inventaire complet des 17 automations de chauffage
- ✅ Timeline journalière documentée
- ✅ Diagnostic approfondi des 3 climatisations Broadlink
- ✅ Plan d'action étape par étape pour réparation
- ✅ Guide complet de l'ordre de fonctionnement
- ✅ Scripts PowerShell automatisés pour collecte
- ✅ Documentation des best practices

---

**Document créé le** : 2025-12-19
**Auteur** : Agent Orchestrator (Claude Sonnet 4.5)
**Statut** : Index complet - Navigation facilitée

**Navigation recommandée** : Commencer par `README_ORCHESTRATION_COMPLETE.md` 📖
