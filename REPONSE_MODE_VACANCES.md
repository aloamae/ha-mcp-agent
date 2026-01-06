# RÉPONSE - ANALYSE MODE VACANCES

## TA QUESTION
> "peux tu em trouver a quelle heure et ce qui a lancé le mode Mode Vacances, il y a une erreur dans les automations"

---

## RÉPONSE DIRECTE

### Quand le mode vacances a été activé:
**📅 18 décembre 2025 à 14:36:58**

### Qui l'a activé:
**👤 Utilisateur Home Assistant** (ID: `e01e55678bb2491ba108ad972e02024e`)
- Activation MANUELLE via l'interface HA, l'app mobile, ou un dashboard

### Quand il a été désactivé:
**📅 19 décembre 2025 à 10:32:53** (soit ~20 heures après)

---

## ERREUR DANS LES AUTOMATIONS? ❌ NON

### Résultat de l'analyse complète:

✅ **AUCUNE automation n'active automatiquement le mode vacances**

J'ai vérifié:
- Tous les fichiers YAML (`automations.yaml`, `scripts.yaml`)
- Toutes les actions `input_boolean.turn_on` sur `mode_vacance`
- Toutes les commandes Telegram qui pourraient l'activer
- Tous les triggers et conditions

**Conclusion:** Le système fonctionne CORRECTEMENT. Le mode vacances ne peut être activé que MANUELLEMENT.

---

## AUTOMATIONS LIÉES AU MODE VACANCES

### 1. `Telegram - Chauffage OFF (Vacances)` ✅ OK
**Ce qu'elle fait:**
- **Déclencheur:** QUAND le mode vacances passe à ON
- **Action:** Envoie une notification Telegram "Mode Vacances ACTIVÉ"
- **Rôle:** Notification UNIQUEMENT (n'active pas le mode)

**Dernier déclenchement:** 18/12/2025 23:48:24 (5h après activation manuelle)

### 2. `Alerte - Mode Vacances bloque Planning` ✅ OK
**Ce qu'elle fait:**
- **Déclencheur:** Tous les jours à 05:45
- **Condition:** SI mode vacances est ON
- **Action:** Affiche notification "Le mode vacances est actif - Planning chauffage bloqué!"

**Dernier déclenchement:** 19/12/2025 20:42:53 (test effectué aujourd'hui)

### 3. `Chauffage - Planning Automatique Horaire` ✅ OK
**Ce qu'elle fait:**
- **Condition:** Ne fonctionne QUE si mode vacances OFF
- **Impact:** Planning chauffage (05:45, 08:00, 17:00, 22:30) BLOQUÉ quand mode vacances ON

**C'est NORMAL et VOULU** - Le mode vacances doit bloquer le chauffage automatique

---

## CHRONOLOGIE DU PROBLÈME (19/12 matin)

```
18/12 14:36:58 → Mode vacances activé MANUELLEMENT
18/12 23:48:24 → Notification Telegram envoyée ✅

19/12 05:45:00 → Planning chauffage BLOQUÉ (mode vacances ON) ❌
19/12 10:32:53 → Mode vacances désactivé MANUELLEMENT
19/12 20:42:53 → Alerte testée (notification créée) ✅
```

**Le chauffage n'a PAS démarré ce matin** car le mode vacances était toujours actif depuis hier 14h36.

---

## D'OÙ VIENT L'ACTIVATION?

### Hypothèses (à vérifier):

1. **Dashboard Lovelace**
   - Clic sur un switch/bouton du mode vacances
   - Dashboard consulté depuis PC/mobile/tablette

2. **Application mobile Home Assistant**
   - Widget ou notification interactive
   - Contrôle rapide de l'entité

3. **Interface web Home Assistant**
   - Vue Lovelace avec carte mode vacances
   - Outils de développement → Services

4. **Script/automation externe** (peu probable)
   - Node-RED, AppDaemon
   - Intégration tierce

### Pour identifier:

1. **Consulter les logs HA:**
   ```
   Paramètres → Système → Logs
   Filtre: "mode_vacance"
   Date: 18/12/2025 14:30-14:40
   ```

2. **Identifier l'utilisateur:**
   ```
   Paramètres → Personnes et Zones → Utilisateurs
   Chercher ID: e01e55678bb2491ba108ad972e02024e
   ```

3. **Vérifier l'historique:**
   ```
   Historique → Sélectionner "Mode Vacances"
   18 décembre 2025, 14h-15h
   ```

---

## SOLUTIONS PROPOSÉES

### Solution 1: Alerte préventive la veille au soir ⭐ RECOMMANDÉ

Ajouter cette automation pour éviter que le mode vacances reste activé par oubli:

```yaml
- alias: Alerte - Mode Vacances actif (Veille)
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
          Désactivez-le si vous n'êtes pas en vacances.
    - service: telegram_bot.send_message
      data:
        chat_id: 8486475897
        message: |
          ⚠️ RAPPEL: Mode Vacances toujours actif

          Demain matin, le chauffage ne démarrera PAS automatiquement.
          Si ce n'était pas prévu, désactivez le mode vacances maintenant.
```

### Solution 2: Désactivation automatique après X jours

```yaml
- alias: Mode Vacances - Auto-désactivation
  trigger:
    - platform: state
      entity_id: input_boolean.mode_vacance
      to: 'on'
      for:
        days: 7
  action:
    - service: input_boolean.turn_off
      target:
        entity_id: input_boolean.mode_vacance
    - service: telegram_bot.send_message
      data:
        chat_id: 8486475897
        message: "🔔 Mode Vacances désactivé automatiquement après 7 jours"
```

### Solution 3: Badge visuel sur le dashboard

Ajouter une carte visible sur le dashboard principal:

```yaml
type: conditional
conditions:
  - entity: input_boolean.mode_vacance
    state: "on"
card:
  type: entities
  title: ⚠️ MODE VACANCES ACTIF
  entities:
    - input_boolean.mode_vacance
  style: |
    ha-card {
      background-color: red;
      color: white;
      border: 3px solid orange;
    }
```

---

## FICHIERS CRÉÉS POUR TOI

1. **[analyse_mode_vacances.ps1](analyse_mode_vacances.ps1)**
   - Analyse l'historique du mode vacances
   - Trouve les automations liées
   - Affiche le logbook

2. **[get_automation_detail.ps1](get_automation_detail.ps1)**
   - Récupère les détails d'une automation
   - Affiche les attributs complets

3. **[RAPPORT_MODE_VACANCES.md](RAPPORT_MODE_VACANCES.md)**
   - Analyse technique complète
   - Chronologie détaillée
   - Hypothèses et vérifications

4. **Ce fichier [REPONSE_MODE_VACANCES.md](REPONSE_MODE_VACANCES.md)**
   - Réponse directe à ta question
   - Solutions proposées

---

## EN RÉSUMÉ

### ❌ PAS D'ERREUR dans les automations
Les automations fonctionnent correctement:
- Elles réagissent au mode vacances (notifications)
- Elles bloquent le chauffage quand mode vacances ON (comme voulu)
- Aucune n'active automatiquement le mode vacances

### ✅ ACTIVATION MANUELLE le 18/12 à 14:36:58
- Par utilisateur ID: e01e55678bb2491ba108ad972e02024e
- Probablement via dashboard ou app mobile
- Oubliée active pendant 20 heures

### 🔧 SOLUTION
Implémenter une des 3 solutions proposées ci-dessus pour éviter ce problème à l'avenir.

**Je recommande la Solution 1** (alerte la veille à 22h) + **Solution 3** (badge visuel sur dashboard)

---

## VEUX-TU QUE JE CRÉE CES AUTOMATIONS?

Dis-moi laquelle(s) tu veux que j'implémente:
1. Alerte à 22h si mode vacances actif
2. Auto-désactivation après 7 jours
3. Badge rouge sur le dashboard
4. Les 3 solutions combinées

Je peux créer les fichiers YAML prêts à copier dans Home Assistant.
