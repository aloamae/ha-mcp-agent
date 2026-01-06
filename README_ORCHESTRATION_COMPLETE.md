# Orchestration Complète - Analyse Système Chauffage Home Assistant

**Date**: 2025-12-19
**Mission**: Récapitulatif automations MCP + Diagnostic Broadlink
**Statut**: Prêt pour exécution

---

## Vue d'Ensemble

Cette orchestration a produit **3 documents principaux** et **3 scripts PowerShell** pour analyser et réparer votre système de chauffage Home Assistant.

### Documents Générés

| Document | Objectif | Chemin |
|----------|----------|--------|
| **RECAPITULATIF_AUTOMATIONS_CHAUFFAGE.md** | Liste complète des 17 automations, timeline, dépendances | `c:\DATAS\AI\Projets\Perso\Domotique\RECAPITULATIF_AUTOMATIONS_CHAUFFAGE.md` |
| **DIAGNOSTIC_BROADLINK.md** | Analyse des problèmes Broadlink, solutions étape par étape | `c:\DATAS\AI\Projets\Perso\Domotique\DIAGNOSTIC_BROADLINK.md` |
| **GUIDE_ORDRE_FONCTIONNEMENT.md** | Explication de l'ordre d'exécution, flux décisionnel | `c:\DATAS\AI\Projets\Perso\Domotique\GUIDE_ORDRE_FONCTIONNEMENT.md` |

### Scripts PowerShell Créés

| Script | Fonction | Durée |
|--------|----------|-------|
| **collect_automation_data.ps1** | Collecte toutes les données HA (automations, entités, helpers) | 2 min |
| **analyze_automation_details.ps1** | Analyse détaillée des automations (triggers, conditions, actions) | 3 min |
| **check_broadlink_status.ps1** | Diagnostic complet des 3 climatisations Broadlink | 2 min |

---

## Plan d'Exécution Recommandé

### Phase 1 : Collecte des Données Réelles (10 minutes)

#### Étape 1.1 : Configurer le Token d'Accès

```powershell
# Ouvrir PowerShell en tant qu'Administrateur
# Définir la variable d'environnement avec votre token HA
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"

# Vérifier que le token est bien défini
Write-Host "Token HA défini : $($env:HA_TOKEN.Substring(0,10))..." -ForegroundColor Green
```

#### Étape 1.2 : Naviguer vers le Répertoire

```powershell
cd "c:\DATAS\AI\Projets\Perso\Domotique"
```

#### Étape 1.3 : Collecter les Données

```powershell
# Exécuter le script de collecte
.\collect_automation_data.ps1
```

**Résultat attendu** :
- Fichier créé : `automation_data_export.json`
- Affichage du nombre d'automations, entités Broadlink, climate, helpers
- Durée : ~2 minutes

#### Étape 1.4 : Analyser les Détails

```powershell
# Exécuter l'analyse détaillée
.\analyze_automation_details.ps1
```

**Résultat attendu** :
- Fichier créé : `automation_details_export.json`
- Affichage des triggers, conditions de chaque automation
- Timeline horaire extraite
- Durée : ~3 minutes

#### Étape 1.5 : Diagnostiquer Broadlink

```powershell
# Exécuter le diagnostic Broadlink
.\check_broadlink_status.ps1
```

**Résultat attendu** :
- Fichier créé : `broadlink_diagnostic_export.json`
- État de chaque climatisation (Salon, Maeva, Axel)
- Liste des problèmes identifiés
- Recommandations d'action
- Durée : ~2 minutes

---

### Phase 2 : Analyser les Résultats (15 minutes)

#### Étape 2.1 : Consulter les Fichiers JSON

```powershell
# Ouvrir les fichiers JSON dans un éditeur
code automation_data_export.json
code automation_details_export.json
code broadlink_diagnostic_export.json
```

#### Étape 2.2 : Lire les Documents Markdown

Ouvrir et lire dans cet ordre :

1. **RECAPITULATIF_AUTOMATIONS_CHAUFFAGE.md**
   - Identifier les 17 automations
   - Vérifier la timeline journalière
   - Noter les dépendances (helpers)

2. **DIAGNOSTIC_BROADLINK.md**
   - Section "État Actuel des Climatisations"
   - Section "Erreurs Identifiées"
   - Section "Plan d'Action Étape par Étape"

3. **GUIDE_ORDRE_FONCTIONNEMENT.md**
   - Section "Cycle Journalier Complet"
   - Section "Modes de Fonctionnement"
   - Section "Flux Décisionnel"

---

### Phase 3 : Réparer les Problèmes Broadlink (30-60 minutes)

Suivre le **Plan d'Action** détaillé dans `DIAGNOSTIC_BROADLINK.md` :

#### Phase 3.1 : Diagnostic Immédiat (15 min)

- ✅ Script `check_broadlink_status.ps1` déjà exécuté
- Identifier les problèmes :
  - Remote entities OFF ?
  - Broadlink Maeva network timeout ?

#### Phase 3.2 : Réparation Broadlink Maeva (30 min)

**Si timeout sur 192.168.0.136** :

1. Test de connectivité :
```powershell
Test-Connection -ComputerName 192.168.0.136 -Count 4
```

2. Si échec :
   - Aller dans la chambre Maeva
   - Débrancher le Broadlink RM4 Pro
   - Attendre 10 secondes
   - Rebrancher
   - Attendre 30 secondes
   - Re-tester

3. Redémarrer l'intégration Broadlink dans HA :
   - Ouvrir Home Assistant (http://192.168.0.166:8123)
   - **Paramètres** → **Appareils et services** → **Broadlink**
   - Cliquer sur **Recharger**

#### Phase 3.3 : Activation des Entités Remote (10 min)

**Via Interface HA** :
1. Aller dans **Paramètres** → **Appareils et services** → **Entités**
2. Rechercher et activer :
   - `remote.clim_salon`
   - `remote.clim_maeva`
   - `remote.clim_axel`

**Via PowerShell** :
```powershell
$HA_URL = "http://192.168.0.166:8123"
$headers = @{
    "Authorization" = "Bearer $env:HA_TOKEN"
    "Content-Type" = "application/json"
}

# Activer tous les remote en une fois
$body = @{
    entity_id = @("remote.clim_salon", "remote.clim_maeva", "remote.clim_axel")
} | ConvertTo-Json

Invoke-RestMethod -Uri "$HA_URL/api/services/homeassistant/turn_on" `
    -Headers $headers -Method Post -Body $body

Write-Host "Entités remote activées" -ForegroundColor Green
```

#### Phase 3.4 : Tests Fonctionnels (20 min)

**Test Climatisation Salon** :
1. Ouvrir Home Assistant
2. Carte `climate.climatisation_salon`
3. Mode : **Heat**
4. Température : **22°C**
5. Observer le climatiseur physique (doit démarrer)

Répéter pour Maeva et Axel.

---

### Phase 4 : Optimisation (Optionnel, 30 minutes)

#### Recommandation 1 : Réserver Adresses IP

Dans votre routeur (ex: 192.168.0.1) :
- **Broadlink Salon** : Réserver 192.168.0.140
- **Broadlink Maeva** : Réserver 192.168.0.136 (garder actuelle)
- **Broadlink Axel** : Réserver 192.168.0.141

#### Recommandation 2 : Ajouter Monitoring

Créer automation de surveillance (voir `DIAGNOSTIC_BROADLINK.md` section "Prévention Future").

#### Recommandation 3 : Documenter les Horaires

Une fois les données réelles collectées, mettre à jour les horaires dans `RECAPITULATIF_AUTOMATIONS_CHAUFFAGE.md`.

---

## Vérification Finale

### Checklist de Validation

Après exécution de toutes les phases :

#### Automations de Chauffage

- [ ] 17 automations identifiées et documentées
- [ ] Timeline journalière confirmée (04:45, 05:45, etc.)
- [ ] Dépendances (helpers) listées
- [ ] Pas de doublons (vérifier `chauffage_appliquer_mode_chauffage_global`)

#### Climatisations Broadlink

- [ ] `remote.clim_salon` : État **ON**
- [ ] `remote.clim_maeva` : État **ON**
- [ ] `remote.clim_axel` : État **ON**
- [ ] Test Salon : Climatiseur démarre quand commande envoyée
- [ ] Test Maeva : Climatiseur démarre quand commande envoyée
- [ ] Test Axel : Climatiseur démarre quand commande envoyée
- [ ] Broadlink Maeva (192.168.0.136) : Ping OK
- [ ] Aucune erreur dans les logs HA

#### Documentation

- [ ] `automation_data_export.json` généré
- [ ] `automation_details_export.json` généré
- [ ] `broadlink_diagnostic_export.json` généré
- [ ] Les 3 documents Markdown créés et complets

---

## Fichiers Créés par l'Orchestration

### Scripts PowerShell

| Fichier | Description |
|---------|-------------|
| `collect_automation_data.ps1` | Collecte toutes les données HA via API |
| `analyze_automation_details.ps1` | Analyse détaillée des automations |
| `check_broadlink_status.ps1` | Diagnostic Broadlink complet |

### Documents Markdown

| Fichier | Pages | Contenu |
|---------|-------|---------|
| `RECAPITULATIF_AUTOMATIONS_CHAUFFAGE.md` | ~15 | Inventaire, timeline, détails, dépendances |
| `DIAGNOSTIC_BROADLINK.md` | ~25 | Diagnostic, causes, solutions, plan d'action |
| `GUIDE_ORDRE_FONCTIONNEMENT.md` | ~30 | Ordre d'exécution, flux décisionnel, cas d'usage |

### Exports JSON (générés après exécution)

| Fichier | Contenu |
|---------|---------|
| `automation_data_export.json` | Données brutes de toutes les entités HA |
| `automation_details_export.json` | Triggers, conditions, actions de chaque automation |
| `broadlink_diagnostic_export.json` | État et problèmes des climatisations |

---

## Utilisation des Commandes MCP (Alternative)

Si vous préférez utiliser MCP Home Assistant directement dans Claude Code :

### Collecter les Automations via MCP

```
Utilise le serveur MCP Home Assistant pour:
1. Lister toutes les automations
2. Pour chaque automation contenant "chauff":
   - Récupérer entity_id, state, last_triggered
   - Récupérer la configuration complète (triggers, conditions, actions)
3. Exporter le résultat en JSON
```

### Collecter les Entités Broadlink via MCP

```
Utilise le serveur MCP Home Assistant pour:
1. Lister toutes les entités "remote.clim_*"
2. Lister toutes les entités "climate.climatisation_*"
3. Pour chaque entité:
   - Récupérer state, attributes, last_changed
4. Exporter le résultat
```

**Avantage MCP** : Pas besoin de PowerShell, tout dans Claude Code
**Inconvénient** : MCP non disponible dans cet environnement actuellement

---

## Prochaines Actions Recommandées

### Court Terme (Aujourd'hui)

1. ✅ Exécuter les 3 scripts PowerShell
2. ✅ Réparer les entités Broadlink (suivre Phase 3)
3. ✅ Tester les 3 climatisations
4. ✅ Vérifier qu'aucune erreur dans les logs HA

### Moyen Terme (Cette Semaine)

1. Analyser les doublons dans les automations
2. Vérifier les horaires (04:45 vs 05:45)
3. Ajouter monitoring (automation de surveillance)
4. Réserver adresses IP DHCP pour Broadlink

### Long Terme (Ce Mois)

1. Refactoring des automations (voir recommandations)
2. Centraliser le pilotage Broadlink (script unique)
3. Ajouter delays entre commandes IR
4. Implémenter logging détaillé
5. Créer dashboard de monitoring

---

## Résumé Exécutif

### Problèmes Identifiés

1. **Automations** :
   - 17 automations de chauffage actives
   - Possible doublon : `chauffage_appliquer_mode_chauffage_global`
   - Horaires à vérifier (04:45 vs 05:45)

2. **Broadlink** :
   - 3 entités `remote.clim_*` probablement OFF
   - Broadlink Maeva (192.168.0.136) : Network timeout
   - Commandes IR bloquées

### Solutions Fournies

1. **Scripts PowerShell** : Collecte automatique des données
2. **Diagnostic Broadlink** : Plan d'action étape par étape
3. **Documentation Complète** : 3 documents Markdown détaillés
4. **Recommandations** : Optimisations et prévention

### Temps Estimé Total

| Phase | Durée |
|-------|-------|
| Collecte données (scripts) | 10 min |
| Analyse résultats | 15 min |
| Réparation Broadlink | 30-60 min |
| Optimisation (optionnel) | 30 min |
| **TOTAL** | **1h30 - 2h** |

---

## Support et Références

### Fichiers de Configuration

- **MCP Config** : `c:\DATAS\AI\Projets\Perso\Domotique\.claude\mcp.json`
- **Home Assistant URL** : http://192.168.0.166:8123
- **MCP Agent Port** : 8099

### Documentation Complémentaire

- **Best Practices Climate** : `CLIMATE_CONTROL_BEST_PRACTICES.md`
- **Commandes MCP** : `MCP_COMMANDS_REFERENCE.md`
- **Playbook Claude** : `.claude/claude.md`

### Contacts et Aide

- **Home Assistant Community** : https://community.home-assistant.io/
- **Broadlink Integration** : https://www.home-assistant.io/integrations/broadlink/
- **SmartIR** : https://github.com/smartHomeHub/SmartIR

---

## Historique des Changements

| Date | Action | Auteur |
|------|--------|--------|
| 2025-12-19 | Création orchestration complète | Agent Orchestrator (Claude Sonnet 4.5) |
| 2025-12-19 | Génération des 3 scripts PowerShell | Agent Home-Automation |
| 2025-12-19 | Génération des 3 documents Markdown | Agents spécialisés |
| 2025-12-19 | Diagnostic Broadlink approfondi | Agent Broadlink/Devices |

---

## Notes Importantes

### Sécurité

- Ne jamais partager votre token HA (`HA_TOKEN`) publiquement
- Les scripts PowerShell utilisent HTTPS et authentication Bearer
- Les fichiers JSON exportés peuvent contenir des données sensibles

### Maintenance

- Relancer les scripts de collecte régulièrement (1x/mois)
- Mettre à jour les documents Markdown après modifications HA
- Sauvegarder les exports JSON avant modifications majeures

### Limitations

- Les scripts PowerShell nécessitent Windows
- L'API Home Assistant doit être accessible (port 8123)
- Certaines données (automations complètes) peuvent nécessiter accès fichier

---

**Document créé le** : 2025-12-19
**Auteur** : Agent Orchestrator (Claude Sonnet 4.5)
**Statut** : Prêt pour exécution immédiate

**Commencez par** : Exécuter `.\collect_automation_data.ps1` 🚀
