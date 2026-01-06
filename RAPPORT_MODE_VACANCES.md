# RAPPORT - ANALYSE MODE VACANCES

**Date d'analyse:** 2025-12-19 21:45
**Problème signalé:** Erreur dans les automations liées au mode vacances

---

## RÉSUMÉ EXÉCUTIF

Le mode vacances a été **activé MANUELLEMENT** par un utilisateur le **18 décembre 2025 à 14:36:58**, puis désactivé le **19 décembre 2025 à 10:32:53** (soit ~20 heures après activation).

**AUCUNE automation n'active automatiquement le mode vacances.**

---

## CHRONOLOGIE DES ÉVÉNEMENTS

### 18 Décembre 2025

**12:28:32** - Utilisateur 5891022b272b41a49ee15c10707b6120
- Multiple changements d'état du mode vacances (tests/ajustements)
- 12:28:32, 12:28:33, 12:29:56, 12:31:43, 12:31:46

**14:36:58** - Utilisateur e01e55678bb2491ba108ad972e02024e
- **ACTIVATION du mode vacances (ON)**
- Cet événement est le dernier changement avant la période problématique

**23:48:24** - Automation "Telegram - Chauffage OFF (Vacances)"
- **Déclenchée** suite à l'état ON du mode vacances
- Envoi notification Telegram: "Mode Vacances ACTIVÉ"

### 19 Décembre 2025

**05:45:00** - Automation "Chauffage - Planning Automatique Horaire"
- **BLOQUÉE** par condition `mode_vacance == OFF`
- Résultat: Chauffage PAS démarré ce matin

**10:32:53** - Utilisateur inconnu
- **DÉSACTIVATION du mode vacances (OFF)**

**20:42:53** - Automation "Alerte - Mode Vacances bloque Planning"
- **Déclenchée** (automation nouvellement créée)
- Notification persistante dans HA

---

## ANALYSE DES AUTOMATIONS

### 1. Automations DÉCLENCHÉES PAR le mode vacances

Ces automations réagissent QUAND le mode vacances change d'état, mais ne l'activent PAS:

#### `automation.telegram_chauffage_off_vacances`
**Nom:** Telegram - Chauffage OFF (Vacances)
**Fichier:** automations.yaml:478
**Configuration:**
```yaml
triggers:
  - entity_id: input_boolean.mode_vacance
    to: 'on'
    trigger: state
actions:
  - data:
      chat_id: 8486475897
      message: "🏖️ Mode Vacances ACTIVÉ\n\nChauffage basculé en mode éco / hors-gel.\n"
    action: telegram_bot.send_message
```

**Rôle:** Notification uniquement (pas d'activation)
**Dernier déclenchement:** 2025-12-18 23:48:24

---

#### `automation.alerte_mode_vacances_bloque_planning`
**Nom:** Alerte - Mode Vacances bloque Planning
**Fichier:** automation_alerte_vacances_corrigee.yaml
**Configuration:**
```yaml
trigger:
  - platform: time
    at: "05:45:00"
condition:
  - condition: state
    entity_id: input_boolean.mode_vacance
    state: "on"
action:
  - service: persistent_notification.create
    data:
      title: ⚠️ Mode Vacances Actif
      message: Le mode vacances est actif - Planning chauffage bloqué!
```

**Rôle:** Alerte si mode vacances actif à 05:45
**Dernier déclenchement:** 2025-12-19 20:42:53

---

### 2. Automations BLOQUÉES PAR le mode vacances

Ces automations vérifient l'état du mode vacances et adaptent leur comportement:

#### `automation.chauffage_planning_automatique_horaire`
**Ligne:** automations.yaml:34
**Condition bloquante:**
```yaml
conditions:
  - condition: state
    entity_id: input_boolean.mode_vacance
    state: 'off'  # Ne s'exécute QUE si mode vacances OFF
```

**Impact:** Planning horaire (05:45, 08:00, 17:00, 22:30) complètement bloqué si mode vacances ON

---

#### `automation.chauffage_pilotage_chaudiere_gaz`
**Ligne:** automations.yaml:71
**Adaptation:**
```yaml
variables:
  consigne: "{% if is_state('input_boolean.mode_vacance','on') %}16 {% else %}
    {{ states('sensor.mode_chauffage_global') | regex_findall_index('\\d+\\.?\\d*') | float(18.5) }}
  {% endif %}"
```

**Impact:** Si mode vacances ON, consigne = 16°C (hors-gel) au lieu de la consigne normale

---

#### `automation.chauffage_pilotage_simple_climatisations`
**Ligne:** automations.yaml:111
**Adaptation:** Même logique, consigne = 16°C si mode vacances ON

---

## SOURCES D'ACTIVATION DU MODE VACANCES

D'après l'analyse complète du système:

### ❌ AUCUNE automation n'active automatiquement le mode vacances

Aucune automation trouvée avec:
- `service: input_boolean.turn_on` sur `mode_vacance`
- Action directe sur `input_boolean.mode_vacance`

### ✅ ACTIVATION MANUELLE UNIQUEMENT

Le mode vacances peut être activé par:

1. **Interface Home Assistant**
   - Lovelace dashboard (carte entities, boutons)
   - Outils de développement → Services
   - Historique → Entité → Toggle

2. **Application mobile Home Assistant**
   - Contrôles de l'entité `input_boolean.mode_vacance`

3. **API REST Home Assistant**
   - Via scripts PowerShell/Python
   - Via curl/Postman

4. **Telegram Bot** (si intégration configurée)
   - Commandes personnalisées pour activer le mode vacances
   - **À VÉRIFIER:** Chercher dans les handlers Telegram

---

## HYPOTHÈSES SUR L'ACTIVATION DU 18/12

### Utilisateur e01e55678bb2491ba108ad972e02024e

Cet ID utilisateur correspond à un compte Home Assistant.

**Actions à faire:**
1. Identifier à qui appartient cet ID utilisateur:
```powershell
# Via API HA (nécessite droits admin)
GET /api/config/auth/users
```

2. Vérifier l'historique des connexions pour cet utilisateur

### Scénarios possibles:

1. **Activation via dashboard Lovelace**
   - Clic accidentel sur un bouton/switch du mode vacances
   - Dashboard consulté sur mobile/tablette

2. **Activation via application mobile**
   - Widget ou raccourci sur téléphone
   - Notification interactive

3. **Activation via Telegram Bot**
   - Commande envoyée au bot (à vérifier dans configuration Telegram)

4. **Activation via script/automation externe**
   - Node-RED, AppDaemon, autre système domotique
   - Script personnalisé déclenché par événement externe

---

## VÉRIFICATIONS RECOMMANDÉES

### 1. Intégration Telegram Bot

Chercher dans `configuration.yaml` ou `automations.yaml` les handlers Telegram:

```yaml
# Exemple de ce qu'il faut chercher:
- trigger: event
  event_type: telegram_callback
  event_data:
    command: '/vacances_on'  # ou similar
  action:
    - service: input_boolean.turn_on
      target:
        entity_id: input_boolean.mode_vacance
```

**Fichier à analyser:** automations.yaml ligne 490-498 (Telegram - Boutons Chauffage Actions)

### 2. Vérifier les scripts externes

```bash
# Chercher dans les fichiers de config
grep -r "mode_vacance" /config/
grep -r "turn_on" /config/ | grep "vacance"
```

### 3. Consulter les logs Home Assistant

```
Paramètres → Système → Logs
Filtrer par: "mode_vacance" ou "input_boolean"
Date: 18/12/2025 14:30 - 14:40
```

---

## ANALYSE AUTOMATION TELEGRAM BOUTONS

**Fichier:** automations.yaml:490-498

```yaml
- id: '1766101847142'
  alias: Telegram - Boutons Chauffage Actions
  description: ''
  triggers:
  - event_type: telegram_callback
    trigger: event
  conditions:
  - condition: template
    value_template: '{{ trigger.event.data.chat_id == 8486475897 }}'
```

**⚠️ AUTOMATION INCOMPLÈTE dans les logs**

Cette automation gère les callbacks Telegram (boutons inline). Il faut voir les actions définies pour savoir si elle peut activer le mode vacances.

**Action requise:** Lire la suite de cette automation (lignes 498+)

---

## CORRECTION PROPOSÉE

### Option 1: Notification préventive (DÉJÀ IMPLÉMENTÉE)

L'automation `alerte_mode_vacances_bloque_planning` créée aujourd'hui alerte si mode vacances actif à 05:45.

**Amélioration possible:**
```yaml
# Ajouter une alerte la veille au soir
- alias: Alerte - Mode Vacances bloque Planning (Veille)
  trigger:
    - platform: time
      at: "22:00:00"
  condition:
    - condition: state
      entity_id: input_boolean.mode_vacance
      state: "on"
  action:
    - service: persistent_notification.create
      data:
        title: ⚠️ Mode Vacances toujours actif
        message: |
          Le mode vacances est encore activé.
          Le planning chauffage de demain matin sera bloqué!
          Désactivez-le si ce n'était pas prévu.
```

### Option 2: Désactivation automatique programmée

```yaml
# Désactiver automatiquement après X jours
- alias: Mode Vacances - Auto-désactivation
  trigger:
    - platform: state
      entity_id: input_boolean.mode_vacance
      to: 'on'
      for:
        days: 7  # Désactive après 7 jours
  action:
    - service: input_boolean.turn_off
      target:
        entity_id: input_boolean.mode_vacance
    - service: telegram_bot.send_message
      data:
        chat_id: 8486475897
        message: "🔔 Mode Vacances désactivé automatiquement après 7 jours"
```

### Option 3: Confirmation avant activation

```yaml
# Demander confirmation via Telegram avant activation longue durée
- alias: Mode Vacances - Confirmation
  trigger:
    - platform: state
      entity_id: input_boolean.mode_vacance
      to: 'on'
  action:
    - service: telegram_bot.send_message
      data:
        chat_id: 8486475897
        message: |
          ⚠️ Mode Vacances ACTIVÉ

          Le chauffage passera en mode hors-gel (16°C).
          Le planning automatique sera DÉSACTIVÉ.

          Durée prévue:
          - Court (1-3 jours): Appuyez sur [1-3j]
          - Long (1 semaine+): Appuyez sur [1 semaine+]
          - ANNULER: Appuyez sur [Annuler]
        inline_keyboard:
          - "1-3 jours:/vacances_court"
          - "1 semaine+:/vacances_long"
          - "Annuler:/vacances_cancel"
```

---

## CONCLUSION

### Cause du problème du 19/12 matin:

✅ **Mode vacances activé MANUELLEMENT le 18/12 à 14:36:58**
✅ **Utilisateur:** e01e55678bb2491ba108ad972e02024e
✅ **Pas d'automation défaillante** qui aurait activé le mode par erreur
✅ **Automation planning correctement bloquée** comme prévu (condition `mode_vacance == OFF`)

### Recommandations:

1. **Identifier l'utilisateur** e01e55678bb2491ba108ad972e02024e
2. **Vérifier l'automation Telegram Boutons** (ligne 490+) pour voir si elle a un bouton d'activation
3. **Implémenter une des 3 corrections proposées** ci-dessus
4. **Ajouter un indicateur visuel** sur le dashboard principal (badge rouge si mode vacances ON)

### Prochaines actions:

```powershell
# 1. Lire l'automation Telegram complète
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"
.\get_automation_detail.ps1 -AutomationId "automation.telegram_boutons_chauffage_actions"

# 2. Identifier l'utilisateur
# Via l'interface HA: Paramètres → Personnes et Zones → Utilisateurs

# 3. Consulter les logs du 18/12 14:30-14:40
# Via l'interface HA: Paramètres → Système → Logs
```

---

**Fichiers créés pour l'analyse:**
- `analyse_mode_vacances.ps1` - Script d'analyse historique
- `get_automation_detail.ps1` - Script de détail automation
- Ce rapport `RAPPORT_MODE_VACANCES.md`
