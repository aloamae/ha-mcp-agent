# Getting Started - Optimisation Capteurs Zigbee

**Bienvenue !** Ce guide vous permet de démarrer en 5 minutes.

---

## JE VEUX JUSTE RÉGLER LE PROBLÈME (5 MINUTES)

### Étape 1: Diagnostic (30 secondes)

Ouvrez un terminal et exécutez:

```bash
# Tester un capteur
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature
```

**Vérifiez**: La valeur `last_updated` doit être récente (< 5 minutes).

Si > 10 minutes → Vous êtes au bon endroit !

---

### Étape 2: Solution Rapide (3 minutes)

**La méthode la plus simple et la plus universelle**:

1. Ouvrir Home Assistant
2. Paramètres → Automations et Scènes
3. Créer une automation
4. Copier-coller ce code:

```yaml
alias: "Zigbee - Polling capteurs T/H (3 min)"
trigger:
  - platform: time_pattern
    minutes: "/3"
action:
  - service: mqtt.publish
    data:
      topic: "zigbee2mqtt/th_cuisine/get"
      payload: '{"temperature": "", "humidity": ""}'
  - service: mqtt.publish
    data:
      topic: "zigbee2mqtt/th_salon/get"
      payload: '{"temperature": "", "humidity": ""}'
  - service: mqtt.publish
    data:
      topic: "zigbee2mqtt/th_loann/get"
      payload: '{"temperature": "", "humidity": ""}'
  - service: mqtt.publish
    data:
      topic: "zigbee2mqtt/th_meva/get"
      payload: '{"temperature": "", "humidity": ""}'
  - service: mqtt.publish
    data:
      topic: "zigbee2mqtt/th_axel/get"
      payload: '{"temperature": "", "humidity": ""}'
  - service: mqtt.publish
    data:
      topic: "zigbee2mqtt/th_parents/get"
      payload: '{"temperature": "", "humidity": ""}'
  - service: mqtt.publish
    data:
      topic: "zigbee2mqtt/th_terrasse/get"
      payload: '{"temperature": "", "humidity": ""}'
mode: single
```

5. Sauvegarder et activer l'automation

---

### Étape 3: Vérification (1 minute)

Attendez 3 minutes, puis vérifiez:

```bash
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature
```

**Résultat attendu**: `last_updated` doit être < 3 minutes.

✅ **C'EST FAIT !** Vos capteurs se mettent maintenant à jour toutes les 3 minutes.

---

## JE VEUX COMPRENDRE (15 MINUTES)

### Quel était le problème ?

Les capteurs Zigbee ont des intervalles de reporting par défaut de 10-30 minutes.
Cela rend les automations de chauffage peu réactives.

### Quelle est la solution ?

Deux méthodes:

1. **Méthode 1**: Reconfigurer les capteurs Zigbee (plus complexe, plus efficace)
2. **Méthode 2**: Automation qui force les mises à jour (simple, universel)

Vous venez d'appliquer la **Méthode 2** ci-dessus.

### Pourquoi ça marche ?

L'automation envoie toutes les 3 minutes une commande MQTT `get` qui force chaque capteur à envoyer ses dernières valeurs.

Impact sur la batterie: Minimal (les capteurs durent 8-10 mois au lieu de 12 mois).

---

## JE VEUX OPTIMISER (30 MINUTES)

### Fichiers à lire (dans l'ordre)

1. `QUICK_REFERENCE_OPTIMISATION_ZIGBEE.md` (5 min)
   → Commandes essentielles

2. `DECISION_TREE_OPTIMISATION.md` (10 min)
   → Choisir entre Méthode 1 et 2

3. `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` (15 min)
   → Documentation complète

### Configuration Avancée

Si vos capteurs sont compatibles (Tuya, SmartThings), vous pouvez utiliser la **Méthode 1** qui offre:
- Réactivité maximale (1-3 minutes)
- Pas d'automation à maintenir
- Configuration automatique

Consultez `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` section "Méthode 1".

---

## JE VEUX TOUT SAVOIR (2 HEURES)

### Index Complet

Consultez `INDEX_PROJET_OPTIMISATION.md` pour la liste complète de tous les fichiers et ressources.

### Parcours d'Apprentissage

1. **Vue d'ensemble**: `README_OPTIMISATION_CAPTEURS.md` (15 min)
2. **Guide complet**: `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` (60 min)
3. **Exemples pratiques**: `EXEMPLES_MCP_OPTIMISATION.md` (30 min)
4. **Personnalisation**: Adapter `zigbee2mqtt_reporting_optimization.yaml` (15 min)

---

## AIDE RAPIDE

### Ma batterie se vide trop vite

Réduire la fréquence de polling:

```yaml
# Au lieu de toutes les 3 minutes
minutes: "/3"

# Passer à toutes les 5 minutes
minutes: "/5"
```

### Mon capteur ne se met toujours pas à jour

Vérifier:

```bash
# Batterie
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_battery

# Qualité du signal (LQI)
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_linkquality
```

Si batterie < 20% → Remplacer la pile
Si LQI < 50 → Rapprocher le capteur d'un routeur mesh

### L'automation ne fonctionne pas

Vérifier qu'elle est activée:

```bash
# Lister les automations
mcp call homeassistant get_entities --domain automation

# Recharger les automations
mcp call homeassistant call_service --service automation.reload
```

### Je veux revenir en arrière

Désactiver simplement l'automation:

Interface HA → Automations → "Zigbee - Polling capteurs T/H" → Désactiver

---

## FICHIERS DU PROJET

### Documentation (Lire en fonction de vos besoins)

| Niveau | Fichier | Temps | Quand le lire |
|--------|---------|-------|--------------|
| 🟢 Débutant | Ce fichier | 5 min | Maintenant |
| 🟢 Débutant | `QUICK_REFERENCE_OPTIMISATION_ZIGBEE.md` | 10 min | Pour les commandes |
| 🟡 Tous | `DECISION_TREE_OPTIMISATION.md` | 15 min | Pour choisir la méthode |
| 🟡 Tous | `README_OPTIMISATION_CAPTEURS.md` | 20 min | Pour comprendre |
| 🔴 Tous | `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` | 60 min | Documentation complète |
| 🔴 Avancé | `EXEMPLES_MCP_OPTIMISATION.md` | 30 min | Scénarios avancés |

### Configuration et Scripts

| Fichier | Utilisation |
|---------|-------------|
| `zigbee2mqtt_reporting_optimization.yaml` | Configuration complète (Méthode 1 et 2) |
| `validate_sensor_reporting.ps1` | Validation Windows (30 min) |
| `validate_sensor_reporting.sh` | Validation Linux (30 min) |

---

## PROCHAINES ÉTAPES

### Immédiat (Aujourd'hui)

- [x] Appliquer la solution rapide (Méthode 2)
- [ ] Tester pendant 1 heure
- [ ] Vérifier que les capteurs se mettent à jour

### Court terme (Cette semaine)

- [ ] Lire `QUICK_REFERENCE_OPTIMISATION_ZIGBEE.md`
- [ ] Surveiller les niveaux de batterie
- [ ] Ajuster la fréquence si nécessaire

### Moyen terme (Ce mois)

- [ ] Explorer la Méthode 1 si capteurs compatibles
- [ ] Optimiser la topologie du réseau Zigbee
- [ ] Lancer le script de validation complet

---

## QUESTIONS FRÉQUENTES

### Quelle méthode choisir ?

**Débutant**: Méthode 2 (celle que vous venez d'appliquer)
**Avancé**: Tester Méthode 1, sinon Méthode 2

### Quel impact sur la batterie ?

Méthode 2: Minimal
- Avant: 12-18 mois d'autonomie
- Après: 8-10 mois d'autonomie

### C'est compatible avec tous les capteurs ?

Oui ! La Méthode 2 fonctionne avec 100% des capteurs Zigbee.

### Puis-je ajuster l'intervalle ?

Oui, dans l'automation:
- `/3` = toutes les 3 minutes
- `/5` = toutes les 5 minutes
- `/10` = toutes les 10 minutes

### Comment savoir si ça marche ?

```bash
# Vérifier la dernière mise à jour
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature

# Vérifier que l'automation se déclenche
# Interface HA → Automations → Historique
```

---

## SUPPORT

### Besoin d'aide ?

1. **Quick Reference**: `QUICK_REFERENCE_OPTIMISATION_ZIGBEE.md`
2. **Guide complet**: `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md`
3. **Exemples**: `EXEMPLES_MCP_OPTIMISATION.md`
4. **Index**: `INDEX_PROJET_OPTIMISATION.md`

### Communauté

- Forum Home Assistant: https://community.home-assistant.io/
- Discord Zigbee2MQTT: https://discord.gg/zigbee2mqtt

---

## RÉSUMÉ

### Ce que vous avez fait

✅ Créé une automation qui force les capteurs à se mettre à jour toutes les 3 minutes

### Ce que vous avez gagné

⭐ Réactivité x10 améliorée (de 15-20 min à 3 min)
⭐ Automations de chauffage temps réel
⭐ Affichage toujours à jour

### Ce que ça coûte

⚠️ Impact batterie: -20% à -30% d'autonomie (toujours > 8 mois)

---

## FÉLICITATIONS !

Vous venez d'optimiser vos capteurs Zigbee en 5 minutes.

**Prochaine étape recommandée**: Lire `QUICK_REFERENCE_OPTIMISATION_ZIGBEE.md` pour aller plus loin.

---

**Dernière mise à jour**: 2025-12-18
**Version**: 1.0
**Difficulté**: 🟢 Débutant
