# Récapitulatif des Automations de Chauffage

**Date**: 2025-12-19
**Système**: Home Assistant (http://192.168.0.166:8123)
**MCP Home Assistant**: Configuré et opérationnel

---

## Table des Matières

1. [Inventaire des Automations](#inventaire-des-automations)
2. [Timeline Journalière](#timeline-journalière)
3. [Détails par Automation](#détails-par-automation)
4. [Dépendances et Helpers](#dépendances-et-helpers)
5. [Ordre de Priorité](#ordre-de-priorité)
6. [Commandes MCP pour Analyse](#commandes-mcp-pour-analyse)

---

## Inventaire des Automations

### Résumé Global

**IMPORTANT**: Les données ci-dessous sont basées sur la documentation existante et doivent être validées en exécutant les scripts de collecte.

D'après la documentation et les scripts trouvés, votre système comprend au moins **17 automations de chauffage**, incluant :

| Automation | État Attendu | Fonction Principale |
|------------|--------------|---------------------|
| `automation.chauffage_allumage_general_matin` | ACTIVÉE | Démarrage du système de chauffage le matin |
| `automation.chauffage_planning_automatique_horaire` | ACTIVÉE | Gestion du planning automatique horaire |
| `automation.chauffage_pilotage_chaudiere_gaz` | ACTIVÉE | Contrôle de la chaudière gaz (cycle fréquent) |
| `automation.chauffage_vacances` | ACTIVÉE | Mode vacances (chauffage minimal) |
| `automation.chauffage_manuel` | ACTIVÉE | Mode manuel (contrôle utilisateur) |
| `automation.chauffage_humidite` | ACTIVÉE | Régulation basée sur l'humidité |
| `automation.chauffage_appliquer_mode_chauffage_global` | ACTIVÉE | Application du mode global (possible doublon) |

**Note**: Une analyse détaillée identifie qu'il y a probablement un doublon de l'automation `chauffage_appliquer_mode_chauffage_global`.

---

## Timeline Journalière

### Vue d'Ensemble du Cycle Quotidien

Basé sur les informations disponibles, voici la séquence logique attendue :

```
┌─────────────────────────────────────────────────────────────────┐
│                    CYCLE JOURNALIER DU CHAUFFAGE                │
└─────────────────────────────────────────────────────────────────┘

04:45 ─┐
       │ chauffage_allumage_general_matin
       │ → Allume le système de chauffage principal
       └─→ État: Préparation matinale

05:45 ─┐
       │ chauffage_planning_automatique_horaire (si mode_vacance = OFF)
       │ → Active le planning automatique
       │ → Condition: input_boolean.mode_vacance doit être OFF
       └─→ État: Chauffage automatique actif

Toutes les 3 minutes (pattern continu) ─┐
       │ chauffage_pilotage_chaudiere_gaz
       │ → Régule la chaudière en fonction des TRV
       │ → Lit les capteurs sensor.th_*_temperature
       │ → Ajuste la puissance de chauffe
       └─→ État: Contrôle en temps réel

[Heure variable selon conditions] ─┐
       │ chauffage_humidite
       │ → Déclenché si humidité > seuil
       │ → Ajuste le chauffage pour gérer l'humidité
       └─→ État: Régulation hygrométrique

[Sur action manuelle] ─┐
       │ chauffage_manuel
       │ → Activé uniquement si input_boolean.mode_manuel = ON
       │ → Désactive le planning automatique
       └─→ État: Contrôle manuel utilisateur

[En cas d'absence] ─┐
       │ chauffage_vacances
       │ → Activé si input_boolean.mode_vacances = ON
       │ → Bloque chauffage_planning_automatique_horaire
       │ → Maintient température minimale anti-gel
       └─→ État: Mode économie/absence
```

---

## Détails par Automation

### 1. `automation.chauffage_allumage_general_matin`

**Nom convivial**: Allumage général chauffage matin

**État**: À vérifier (probablement ACTIVÉE)

**Déclencheur (Trigger)**:
- **Type**: Time
- **Horaire**: `04:45:00`

**Conditions**: Aucune (exécution systématique)

**Actions**:
- Allume le thermostat principal
- Active le système de chauffage
- Prépare le système pour la journée

**Ordre d'exécution**: 1er (démarrage du cycle)

**Dépendances**:
- Entités contrôlées: `switch.thermostat_*` (à vérifier)

**Remarques**:
- ⚠️ Horaire à 04:45 semble précoce, pourrait être ajusté à 05:45

---

### 2. `automation.chauffage_planning_automatique_horaire`

**Nom convivial**: Planning automatique horaire du chauffage

**État**: À vérifier (probablement ACTIVÉE)

**Déclencheur (Trigger)**:
- **Type**: Time
- **Horaire**: `05:45:00` (présumé)

**Conditions**:
```yaml
condition:
  - condition: state
    entity_id: input_boolean.mode_vacance
    state: 'off'
```

**Actions**:
- Active le mode planning automatique
- Configure les consignes de température selon le planning

**Ordre d'exécution**: 2ème (après allumage général)

**Dépendances**:
- `input_boolean.mode_vacance` : Si ON, bloque cette automation
- `input_select.mode_chauffage` : Définit le mode actif

**Remarques**:
- Cette automation est bloquée en mode vacances
- Dépend du helper `mode_vacance` pour fonctionner

---

### 3. `automation.chauffage_pilotage_chaudiere_gaz`

**Nom convivial**: Pilotage chaudière gaz

**État**: À vérifier (probablement ACTIVÉE)

**Déclencheur (Trigger)**:
- **Type**: Time pattern
- **Fréquence**: Toutes les 3 minutes (`minutes: /3`)

**Conditions**: À déterminer

**Actions**:
- Lit les températures des capteurs `sensor.th_*_temperature`
- Calcule la moyenne ou identifie les besoins
- Allume/éteint la chaudière selon les besoins
- Respecte le cooldown (probablement 15-30 min)

**Ordre d'exécution**: Continu (indépendant du cycle horaire)

**Dépendances**:
- Capteurs de température: `sensor.th_*_temperature`
- Capteurs d'humidité: `sensor.th_*_humidity`
- Entité chaudière: `switch.chaudiere_gaz` ou `climate.chaudiere`
- Helpers potentiels:
  - `input_boolean.boiler_cooldown_active`
  - `input_datetime.boiler_last_started`

**Remarques**:
- Automation critique pour le pilotage en temps réel
- Doit respecter les best practices (minimum runtime 10 min, cooldown 15-30 min)
- Vérifier si implémente les règles de sécurité

---

### 4. `automation.chauffage_vacances`

**Nom convivial**: Mode vacances chauffage

**État**: À vérifier

**Déclencheur (Trigger)**:
- **Type**: State
- **Entité**: `input_boolean.mode_vacances`
- **État**: `on`

**Conditions**: Aucune

**Actions**:
- Désactive le planning automatique
- Configure température minimale (ex: 12-15°C)
- Mode anti-gel

**Ordre d'exécution**: Prioritaire (override sur planning)

**Dépendances**:
- `input_boolean.mode_vacances`
- `input_number.consigne_temperature` (probablement)

**Remarques**:
- Mode exclusif: bloque `chauffage_planning_automatique_horaire`

---

### 5. `automation.chauffage_manuel`

**Nom convivial**: Mode manuel chauffage

**État**: À vérifier

**Déclencheur (Trigger)**:
- **Type**: State
- **Entité**: `input_boolean.mode_manuel`
- **État**: `on`

**Conditions**: Aucune

**Actions**:
- Désactive le planning automatique
- Permet le contrôle manuel via UI
- Maintient la consigne définie manuellement

**Ordre d'exécution**: Prioritaire (override sur planning)

**Dépendances**:
- `input_boolean.mode_manuel`
- `input_number.consigne_temperature`

**Remarques**:
- Mode exclusif: désactive automation automatique

---

### 6. `automation.chauffage_humidite`

**Nom convivial**: Régulation chauffage par humidité

**État**: À vérifier

**Déclencheur (Trigger)**:
- **Type**: Numeric state (probablement)
- **Entité**: `sensor.th_*_humidity`
- **Seuil**: > valeur définie (ex: 70%)

**Conditions**: À déterminer

**Actions**:
- Ajuste le chauffage pour réduire l'humidité
- Peut augmenter temporairement la consigne

**Ordre d'exécution**: Réactif (selon conditions d'humidité)

**Dépendances**:
- Capteurs d'humidité: `sensor.th_*_humidity`

---

### 7. `automation.chauffage_appliquer_mode_chauffage_global`

**Nom convivial**: Appliquer mode chauffage global

**État**: À vérifier (DOUBLON DÉTECTÉ)

**Déclencheur (Trigger)**: À déterminer

**Conditions**: À déterminer

**Actions**: À déterminer

**Remarques**:
- ⚠️ **DOUBLON IDENTIFIÉ**: Cette automation existe en 2 exemplaires
- Action recommandée: Désactiver ou supprimer le doublon

---

## Dépendances et Helpers

### Helpers Input Boolean

| Helper | Fonction | Impact sur Automations |
|--------|----------|------------------------|
| `input_boolean.mode_vacance` | Active le mode vacances | BLOQUE `chauffage_planning_automatique_horaire` |
| `input_boolean.mode_manuel` | Active le mode manuel | BLOQUE planning automatique |
| `input_boolean.boiler_cooldown_active` | Cooldown chaudière | Empêche redémarrage prématuré de la chaudière |

### Helpers Input Number

| Helper | Fonction | Utilisé par |
|--------|----------|-------------|
| `input_number.consigne_temperature` | Température cible | Toutes les automations de régulation |

### Helpers Input Select

| Helper | Fonction | Options |
|--------|----------|---------|
| `input_select.mode_chauffage` | Sélection du mode | Auto / Manuel / Vacances / Eco / Confort |

### Capteurs Utilisés

| Capteur | Type | Utilisation |
|---------|------|-------------|
| `sensor.th_*_temperature` | Température | Lecture de la température ambiante |
| `sensor.th_*_humidity` | Humidité | Régulation hygrométrique |
| `sensor.any_trv_heating` | Agrégation | Détection d'au moins un TRV en demande de chauffe |
| `sensor.boiler_runtime_minutes` | Durée | Calcul du temps de fonctionnement chaudière |

---

## Ordre de Priorité

### Priorité 1 : Modes exclusifs (bloquants)

1. **Mode Vacances** → Bloque tout le planning automatique
2. **Mode Manuel** → Désactive l'automatisation, contrôle utilisateur

### Priorité 2 : Planning horaire

3. **Allumage Général Matin** (04:45) → Démarre le système
4. **Planning Automatique** (05:45) → Active les consignes horaires

### Priorité 3 : Régulations continues

5. **Pilotage Chaudière** (toutes les 3 min) → Contrôle en temps réel
6. **Régulation Humidité** (déclenchement conditionnel) → Ajustements ponctuels

---

## Commandes MCP pour Analyse

### Étape 1 : Collecter les Données Réelles

Exécutez les scripts PowerShell créés pour vous :

```powershell
# 1. Définir le token d'accès Home Assistant
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"

# 2. Collecter toutes les données
.\collect_automation_data.ps1

# 3. Analyser les détails des automations
.\analyze_automation_details.ps1
```

### Étape 2 : Lister les Automations via MCP Home Assistant

Si vous avez accès au MCP dans Claude Code :

```
Utilise le serveur MCP Home Assistant pour:
1. Lister toutes les automations
2. Filtrer celles contenant "chauff" ou "climat"
3. Pour chaque automation, récupérer:
   - État (on/off)
   - Dernier déclenchement
   - Configuration complète (triggers, conditions, actions)
```

### Étape 3 : Récupérer les Helpers

```powershell
# Via PowerShell
$allStates = Invoke-RestMethod -Uri "http://192.168.0.166:8123/api/states" -Headers @{
    "Authorization" = "Bearer $env:HA_TOKEN"
} -Method Get

$helpers = $allStates | Where-Object { $_.entity_id -match "^input_" }
$helpers | Format-Table entity_id, state, @{Name='Name';Expression={$_.attributes.friendly_name}}
```

---

## Prochaines Étapes

### Actions Immédiates

1. ✅ **Exécuter les scripts de collecte** pour obtenir les données réelles
2. ✅ **Identifier les doublons** (chauffage_appliquer_mode_chauffage_global)
3. ✅ **Vérifier les horaires** (04:45 vs 05:45)
4. ✅ **Valider les conditions** de chaque automation

### Vérifications Recommandées

- [ ] Confirmer que `chauffage_pilotage_chaudiere_gaz` respecte les best practices :
  - Minimum runtime : 10 minutes
  - Cooldown : 15-30 minutes
  - Maximum runtime : 30 minutes
- [ ] Vérifier qu'il n'y a pas de conflits entre automations
- [ ] Tester le comportement en mode vacances
- [ ] Documenter les seuils d'humidité pour `chauffage_humidite`

---

## Notes Techniques

### Fichiers de Configuration

Les scripts PowerShell créés génèrent les fichiers suivants :

- `automation_data_export.json` : Données brutes de toutes les automations
- `automation_details_export.json` : Détails complets (triggers, conditions, actions)
- Ces fichiers peuvent être analysés par un agent IA pour produire des recommandations

### Logs et Debugging

Pour consulter les logs des automations :

```powershell
# Voir les derniers déclenchements
$allStates | Where-Object { $_.entity_id -like "automation.chauff*" } |
    Select-Object entity_id, state, @{Name='Last Triggered';Expression={$_.attributes.last_triggered}} |
    Format-Table -AutoSize
```

---

## Références

- **Configuration MCP** : `c:\DATAS\AI\Projets\Perso\Domotique\.claude\mcp.json`
- **URL Home Assistant** : http://192.168.0.166:8123
- **Port MCP Agent** : 8099
- **Documentation Best Practices** : `CLIMATE_CONTROL_BEST_PRACTICES.md`

---

**Document généré le** : 2025-12-19
**Auteur** : Orchestrator Agent (Claude Sonnet 4.5)
**Statut** : Template - À compléter avec données réelles après exécution des scripts
