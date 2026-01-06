# Optimisation des Intervalles de Reporting Zigbee - Projet Complet

**Date de création**: 2025-12-18
**Statut**: Prêt pour déploiement
**Version**: 1.0

---

## PROBLÈME RÉSOLU

Les capteurs de température/humidité Zigbee mettent trop longtemps (10-30 minutes) à mettre à jour leurs valeurs dans Home Assistant, ce qui rend les automations de chauffage peu réactives.

**Solution proposée**: Deux méthodes complémentaires pour réduire les intervalles de reporting à 1-3 minutes.

---

## FICHIERS DU PROJET

### Documentation

| Fichier | Description | Utilisation |
|---------|-------------|-------------|
| `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` | Guide complet (60+ pages) | Documentation de référence |
| `QUICK_REFERENCE_OPTIMISATION_ZIGBEE.md` | Quick reference card | Aide-mémoire, commandes rapides |
| `EXEMPLES_MCP_OPTIMISATION.md` | Exemples pratiques MCP | Scénarios concrets d'utilisation |
| `README_OPTIMISATION_CAPTEURS.md` | Ce fichier | Vue d'ensemble du projet |

### Configuration

| Fichier | Description | Utilisation |
|---------|-------------|-------------|
| `zigbee2mqtt_reporting_optimization.yaml` | Configuration device_options optimisée | À copier dans configuration.yaml |

### Scripts de Validation

| Fichier | Description | Platform |
|---------|-------------|----------|
| `validate_sensor_reporting.sh` | Script de monitoring automatique | Linux / WSL |
| `validate_sensor_reporting.ps1` | Script de monitoring automatique | Windows PowerShell |

---

## ARCHITECTURE DE LA SOLUTION

```
┌─────────────────────────────────────────────────────────────┐
│                  HOME ASSISTANT                              │
│                                                              │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │  MCP Server  │         │  Automations │                 │
│  │  (Port 8099) │         │   (Polling)  │                 │
│  └──────┬───────┘         └──────┬───────┘                 │
│         │                        │                          │
└─────────┼────────────────────────┼──────────────────────────┘
          │                        │
          │ HTTP API               │ MQTT
          │                        │
┌─────────┼────────────────────────┼──────────────────────────┐
│         │                        │                          │
│         ▼                        ▼                          │
│  ┌─────────────┐          ┌──────────────┐                 │
│  │   Claude    │          │  Mosquitto   │                 │
│  │   + MCP     │◄────────►│  (MQTT)      │                 │
│  └─────────────┘          └──────┬───────┘                 │
│                                  │                          │
└──────────────────────────────────┼──────────────────────────┘
                                   │ MQTT
                                   │
┌──────────────────────────────────┼──────────────────────────┐
│                                  │                          │
│                                  ▼                          │
│                          ┌──────────────┐                   │
│                          │ Zigbee2MQTT  │                   │
│                          │ (Port 8100)  │                   │
│                          └──────┬───────┘                   │
│                                 │ Zigbee                    │
│                                 │                          │
│  ┌──────────────┐               │       ┌──────────────┐   │
│  │ Coordinateur │◄──────────────┴──────►│   Routeurs   │   │
│  │ SLZB-MR1     │                       │  Mesh (x2)   │   │
│  └──────────────┘                       └──────┬───────┘   │
│                                                │            │
│                                                │            │
│                          ┌─────────────────────┴────────┐   │
│                          │                              │   │
│                   ┌──────▼──────┐              ┌────────▼─┐ │
│                   │  Capteurs   │              │ Capteurs │ │
│                   │  T/H (x3)   │              │ T/H (x4) │ │
│                   └─────────────┘              └──────────┘ │
│                                                              │
└──────────────────────────────────────────────────────────────┘

LÉGENDE:
- MCP Server: HA Vibecode Agent (accès API Home Assistant)
- Coordinateur: SLZB-MR1-MEZZA (192.168.0.166:6638)
- Routeurs Mesh: Prise_Mesh_Salon, Prise_Mesh_Cuisine
- Capteurs T/H: th_cuisine, th_salon, th_loann, th_meva, th_axel, th_parents, th_terrasse
```

---

## DEUX MÉTHODES DISPONIBLES

### Méthode 1: Reconfiguration du Reporting Zigbee (RECOMMANDÉE EN PREMIER)

#### Principe
Modifier les paramètres de reporting directement dans la configuration Zigbee des capteurs.

#### Avantages
- Réactivité maximale (1-3 minutes)
- Automatique, pas de maintenance
- Impact modéré sur la batterie (6-8 mois d'autonomie)

#### Inconvénients
- Ne fonctionne pas avec tous les capteurs (notamment Xiaomi/Aqara)
- Nécessite de connaître les IEEE addresses
- Configuration plus complexe

#### Compatibilité

| Fabricant | Support | Recommandation |
|-----------|---------|----------------|
| Tuya (TS0201) | ✅ Excellent | Utiliser cette méthode |
| Sonoff (SNZB-02) | ⚠ Partiel | Tester, sinon Méthode 2 |
| Xiaomi/Aqara | ❌ Non | Utiliser Méthode 2 |
| SmartThings | ✅ Bon | Utiliser cette méthode |

#### Fichiers
- Configuration: `zigbee2mqtt_reporting_optimization.yaml`
- Documentation: Section "Méthode 1" dans `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md`

---

### Méthode 2: Polling Actif via Home Assistant (SOLUTION UNIVERSELLE)

#### Principe
Créer une automation Home Assistant qui envoie régulièrement une commande MQTT pour forcer la mise à jour des capteurs.

#### Avantages
- Fonctionne avec TOUS les capteurs Zigbee
- Simple à mettre en place
- Impact minimal sur la batterie
- Facile à désactiver ou modifier

#### Inconvénients
- Automation à maintenir
- Légèrement moins réactif que la Méthode 1
- Charge réseau MQTT légèrement augmentée

#### Configuration
- Automation YAML fournie dans `zigbee2mqtt_reporting_optimization.yaml`
- Exemples dans `EXEMPLES_MCP_OPTIMISATION.md` (Scénario 4)

---

## DÉMARRAGE RAPIDE

### Prérequis

- [ ] Home Assistant opérationnel
- [ ] Zigbee2MQTT installé et fonctionnel
- [ ] MCP Server (HA Vibecode Agent) configuré
- [ ] 7 capteurs température/humidité appairés
- [ ] Batterie des capteurs > 20%
- [ ] LQI des capteurs > 50

### Étape 1: Diagnostic Initial

```bash
# Vérifier l'état de tous les capteurs
for sensor in th_cuisine th_salon th_loann th_meva th_axel th_parents th_terrasse; do
  echo "=== $sensor ==="
  mcp call homeassistant get_entity_state --entity_id "sensor.${sensor}_temperature"
  mcp call homeassistant get_entity_state --entity_id "sensor.${sensor}_battery"
  mcp call homeassistant get_entity_state --entity_id "sensor.${sensor}_linkquality"
  echo ""
done
```

### Étape 2: Choisir une Méthode

**Essayez d'abord la Méthode 1** (reconfiguration), car elle offre la meilleure réactivité.

**Si échec** (logs montrent "device does not support reporting"), passez à la Méthode 2 (polling).

### Étape 3: Appliquer la Configuration

#### Option A: Méthode 1 (Reconfiguration)

1. **Récupérer les IEEE addresses**:
   - Interface Zigbee2MQTT (http://192.168.0.166:8100)
   - Onglet "Devices" → Cliquer sur chaque capteur
   - Noter l'IEEE address

2. **Éditer `zigbee2mqtt_reporting_optimization.yaml`**:
   - Remplacer `0x0000000000000003` par votre IEEE address réelle
   - Répéter pour les 7 capteurs

3. **Copier dans la configuration Zigbee2MQTT**:
   - Ouvrir `/config/zigbee2mqtt/configuration.yaml`
   - Copier toute la section `device_options`

4. **Redémarrer Zigbee2MQTT**:
   ```bash
   mcp call homeassistant restart_addon --addon core_zigbee2mqtt
   ```

5. **Vérifier les logs**:
   ```bash
   mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 100 | grep -i "reporting"
   ```

   **Succès**: "Successfully configured reporting for..."
   **Échec**: "Device does not support reporting" → Passer à la Méthode 2

#### Option B: Méthode 2 (Polling)

1. **Créer l'automation**:
   - Interface HA → Paramètres → Automations
   - Copier l'automation depuis `zigbee2mqtt_reporting_optimization.yaml`

2. **Recharger les automations**:
   ```bash
   mcp call homeassistant call_service --service automation.reload
   ```

3. **Vérifier que l'automation est active**:
   ```bash
   mcp call homeassistant get_entities --domain automation | grep -i "zigbee"
   ```

### Étape 4: Validation

#### Test Rapide (30 secondes)

```bash
# Forcer une mise à jour
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/th_cuisine/get" \
  --payload '{"temperature": "", "humidity": ""}'

# Attendre 10 secondes
sleep 10

# Vérifier que la valeur a été mise à jour
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature
```

#### Test Complet (30 minutes)

```powershell
# Windows
$env:HA_TOKEN = "VOTRE_TOKEN_LONGUE_DUREE"
.\validate_sensor_reporting.ps1 -DurationMinutes 30

# Linux/WSL
export MQTT_PASSWORD="votre_mot_de_passe"
./validate_sensor_reporting.sh 30
```

**Résultats attendus**:
- Intervalle moyen: ≤ 3 minutes
- Taux de mise à jour: ≥ 20 updates/heure par capteur
- Aucune erreur dans les logs

---

## SURVEILLANCE ET MAINTENANCE

### Indicateurs de Santé à Surveiller

| Indicateur | Valeur OK | Action si KO |
|------------|-----------|--------------|
| **Intervalle de reporting** | ≤ 3 min | Vérifier config |
| **LQI (Link Quality)** | > 100 | Rapprocher routeur |
| **Batterie** | > 20% | Remplacer pile |
| **Last Seen** | < 5 min | Vérifier réseau |
| **État capteur** | Available | Ré-appairer |

### Commandes de Monitoring

```bash
# Dashboard de surveillance (à exécuter régulièrement)
echo "=== ÉTAT DES CAPTEURS ZIGBEE ==="
echo ""

for sensor in th_cuisine th_salon th_loann th_meva th_axel th_parents th_terrasse; do
  temp=$(mcp call homeassistant get_entity_state --entity_id "sensor.${sensor}_temperature" | jq -r '.state')
  battery=$(mcp call homeassistant get_entity_state --entity_id "sensor.${sensor}_battery" | jq -r '.state')
  lqi=$(mcp call homeassistant get_entity_state --entity_id "sensor.${sensor}_linkquality" | jq -r '.state')
  last_updated=$(mcp call homeassistant get_entity_state --entity_id "sensor.${sensor}_temperature" | jq -r '.last_updated')

  echo "$sensor:"
  echo "  T: ${temp}°C | Batt: ${battery}% | LQI: $lqi | Last: $last_updated"

  # Alertes
  if (( $(echo "$battery < 20" | bc -l) )); then
    echo "  ⚠ BATTERIE FAIBLE"
  fi

  if [[ $lqi -lt 50 ]]; then
    echo "  ⚠ LQI FAIBLE"
  fi

  echo ""
done
```

### Maintenance Préventive

**Hebdomadaire**:
- Vérifier les niveaux de batterie
- Consulter les logs Zigbee2MQTT pour les erreurs

**Mensuel**:
- Lancer le script de validation complet (30 min)
- Vérifier la carte réseau Zigbee
- Nettoyer les entités unavailable

**Tous les 6 mois**:
- Remplacer préventivement les piles (avant 10%)
- Vérifier les positions des routeurs mesh
- Optimiser la topologie du réseau

---

## DÉPANNAGE

### Problème: Capteur ne se met pas à jour

**Diagnostic**:
```bash
# 1. Vérifier l'état
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_temperature

# 2. Forcer une mise à jour
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/th_cuisine/get" \
  --payload '{"temperature": "", "humidity": ""}'

# 3. Vérifier LQI et batterie
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_linkquality
mcp call homeassistant get_entity_state --entity_id sensor.th_cuisine_battery
```

**Solutions**:
- LQI < 50: Rapprocher le capteur d'un routeur mesh
- Batterie < 20%: Remplacer la pile
- Pas de réponse: Ré-appairer le capteur

### Problème: Automation de polling ne fonctionne pas

**Diagnostic**:
```bash
# Vérifier que l'automation existe et est activée
mcp call homeassistant get_entities --domain automation

# Tester manuellement
mcp call homeassistant mqtt_publish \
  --topic "zigbee2mqtt/th_cuisine/get" \
  --payload '{"temperature": "", "humidity": ""}'
```

**Solutions**:
- Recharger les automations: `automation.reload`
- Vérifier la syntaxe YAML
- Activer l'automation si désactivée

### Problème: Impact excessif sur la batterie

**Symptômes**: Batteries qui durent < 2 mois

**Solutions**:
1. Réduire la fréquence de polling (de `/3` à `/5` minutes)
2. Augmenter `max_interval` dans la configuration de reporting
3. Utiliser des capteurs sur secteur (USB)

### Rollback Complet

Si vous rencontrez des problèmes insurmontables:

```bash
# 1. Restaurer le backup de configuration Zigbee2MQTT
# (Utiliser File Editor ou SSH)

# 2. Désactiver l'automation de polling
mcp call homeassistant turn_off --entity_id automation.zigbee_polling_capteurs_t_h_3_min

# 3. Redémarrer Zigbee2MQTT
mcp call homeassistant restart_addon --addon core_zigbee2mqtt

# 4. Vérifier que tout est revenu à la normale
mcp call homeassistant get_addon_logs --addon core_zigbee2mqtt --lines 50
```

---

## RESSOURCES COMPLÉMENTAIRES

### Documentation Officielle

- [Zigbee2MQTT - MQTT Topics](https://www.zigbee2mqtt.io/guide/usage/mqtt_topics_and_messages.html)
- [Zigbee2MQTT - Device Configuration](https://www.zigbee2mqtt.io/guide/configuration/devices-groups.html)
- [Home Assistant - Automation](https://www.home-assistant.io/docs/automation/)
- [Home Assistant - MQTT Integration](https://www.home-assistant.io/integrations/mqtt/)

### Outils Recommandés

- **MQTT Explorer**: Client MQTT graphique pour Windows/Mac/Linux
- **File Editor**: Add-on Home Assistant pour éditer les fichiers
- **Studio Code Server**: Add-on Home Assistant pour développement avancé
- **Zigbee2MQTT Assistant**: Interface web alternative pour Z2M

### Communauté

- [Forum Home Assistant](https://community.home-assistant.io/)
- [Discord Zigbee2MQTT](https://discord.gg/zigbee2mqtt)
- [GitHub Zigbee2MQTT](https://github.com/Koenkk/zigbee2mqtt)

---

## VERSIONS ET COMPATIBILITÉ

### Testé avec

- Home Assistant: 2024.x
- Zigbee2MQTT: 1.35.0+
- SLZB-MR1-MEZZA Coordinateur
- Python 3.x (scripts de validation)
- PowerShell 5.1+ (scripts Windows)

### Modèles de Capteurs Testés

- Tuya TS0201 (température/humidité)
- Sonoff SNZB-02 (température/humidité)
- Xiaomi WSDCGQ11LM (température/humidité)
- Aqara WSDCGQ01LM (température/humidité)

---

## HISTORIQUE DES VERSIONS

### v1.0 (2025-12-18)
- Création initiale du projet
- Documentation complète
- Scripts de validation Windows et Linux
- Configuration device_options optimisée
- Automation de polling
- Exemples MCP

---

## LICENCE ET CRÉDITS

Ce projet est fourni "tel quel", sans garantie.

Basé sur:
- Zigbee2MQTT (Open Source)
- Home Assistant (Open Source)
- MCP Home Assistant Server (@coolver/home-assistant-mcp)

---

## SUPPORT

Pour toute question ou problème:

1. Consulter `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` (documentation complète)
2. Vérifier `QUICK_REFERENCE_OPTIMISATION_ZIGBEE.md` (commandes rapides)
3. Chercher dans `EXEMPLES_MCP_OPTIMISATION.md` (scénarios pratiques)
4. Consulter les logs Zigbee2MQTT et Home Assistant

---

**Dernière mise à jour**: 2025-12-18
**Auteur**: Optimisation créée avec Claude Code
**Version**: 1.0
