# Domotique — Home Assistant Chauffage Intelligent

Configuration complète d'un système de chauffage intelligent pour Home Assistant avec pilotage automatisé GAZ + Climatisations et agents MCP Claude.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-2024.12-orange)](https://www.home-assistant.io/)

## 🎯 Vue d'ensemble

Ce projet contient la configuration complète d'un système de chauffage intelligent pour une maison avec :
- **3 pièces chauffées au GAZ** (Cuisine, Parents, Loann) via chaudière
- **3 pièces chauffées par Climatisation** (Salon, Axel, Maeva) via Broadlink IR
- **Système de priorités à 6 niveaux** (Vacances → Humidité → Manuel → Planning → Global → Pilotage)
- **Planning horaire automatique** avec 4 créneaux (05:45, 08:00, 17:00, 22:30)
- **Gestion automatique de l'humidité** (+2°C si seuil dépassé)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SYSTÈME DE CHAUFFAGE                      │
├─────────────────────────────────────────────────────────────┤
│  6 PIÈCES                                                   │
│  ├── GAZ: Cuisine, Parents, Loann (switch.thermostat)      │
│  └── CLIM: Salon, Axel, Maeva (climate.*)                  │
├─────────────────────────────────────────────────────────────┤
│  6 NIVEAUX DE PRIORITÉ                                      │
│  1. Mode Vacances → 16°C partout                           │
│  2. Mode Humidité → +2°C automatique                       │
│  3. Mode Manuel → température fixe par pièce              │
│  4. Mode Planning → MODEJOUR avec créneaux                 │
│  5. Mode Global → température de référence                │
│  6. Pilotage → exécution toutes les 3 minutes              │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Structure du projet

```
Domotique/
├── .claude/                    # Agents et prompts MCP
│   ├── agents/                  # 5 agents spécialisés
│   ├── CLAUDE.md                # Playbook + référence
│   ├── tools.md                 # Commandes MCP
│   └── mcp.json                 # Configuration serveur MCP
│
├── docs/                        # Documentation complète
│   ├── SYSTEME_CHAUFFAGE_COMPLET.md
│   ├── INDEX.md
│   └── ROUTAGE_AGENTS_MCP.md
│
├── automation_*.yaml            # Automations chauffage
│   ├── automation_chauffage_GAZ_v4_humidite.yaml
│   ├── automation_climatisation_SALON_v5_corrige.yaml
│   ├── automation_climatisation_AXEL_v4_corrige.yaml
│   ├── automation_climatisation_MAEVA_v4_corrige.yaml
│   └── automation_planning_*.yaml
│
└── dashboard_*.yaml             # Dashboards Lovelace
```

## 🚀 Installation rapide

### Prérequis

- Home Assistant 2024.12+
- Zigbee2MQTT (capteurs température/humidité)
- Broadlink RM4 Pro (climatisations)
- Chaudière GAZ compatible

### 1. Cloner le dépôt

```bash
git clone https://github.com/votre-username/domotique.git
cd domotique
```

### 2. Créer les helpers

Copier les fichiers `input_*.yaml` vers Home Assistant :
- Paramètres → Appareils et services → Entrées → Importer YAML

### 3. Importer les automations

Pour chaque automation `*.yaml` :
1. Paramètres → Automations → Importer
2. Sélectionner le fichier
3. Valider

### 4. Importer les dashboards

1. Paramètres → Tableaux de bord
2. Ajouter un tableau de bord
3. Importer le YAML

### 5. Configurer MCP (optionnel)

Pour utiliser les agents Claude :
- Copier `.claude/mcp.json`
- Configurer `HA_AGENT_URL` et `HA_AGENT_KEY`

Voir [docs/INSTALL.md](docs/INSTALL.md) pour les détails.

## 📋 Entités principales

### Helpers
| Entité | Description |
|--------|-------------|
| `input_boolean.mode_vacance` | Mode vacances global |
| `input_number.mode_chauffage_global` | Temperature globale (16-22°C) |
| `input_select.mode_chauffage_*` | Mode par pièce (6 pièces) |
| `input_boolean.mode_humidite_*` | Boost humidite (6 pièces) |

### Automations
| Automation | Trigger | Description |
|------------|---------|-------------|
| Planning Horaire | 05:45, 08:00, 17:00, 22:30 | Met toutes pièces en MODEJOUR |
| Mode Global | 05:45, 08:00, 17:00, 22:30 | Change temperature globale |
| Planning 08:05 | 08:05 | Optionnel 19°C (toggle) |
| Pilotage GAZ | /3 minutes | Chaudiere |
| Pilotage CLIM | /3 minutes | Salon, Axel, Maeva |

## 🎛️ Utilisation

### Mode automatique (recommandé)
Laissez toutes les pièces en `MODEJOUR`. Le planning gère automatiquement :
- **05:45** → 19°C (réveil)
- **08:00** → 17°C (départ)
- **17:00** → 19°C (retour)
- **22:30** → 17°C (nuit)

### Mode vacances
Activez `input_boolean.mode_vacance` pour passer tout en hors-gel (16°C).

### Modification manuelle
Changez `input_select.mode_chauffage_*` pour une pièce spécifique. Elle reviendra en MODEJOUR au prochain créneau.

## 🐛 Bugs connus et solutions

| Bug | Solution |
|-----|----------|
| Consigne 2°C au lieu de 20°C | Regex `\((\d+\.?\d*)\)` |
| Clim bipe sans agir | Vérifier doublons + condition `!= 'heat'` |
| Clim ne s'arrête pas | Condition `<= -0.5` |
| MODEJOUR ne suit pas global | Utiliser `sensor.mode_chauffage_global_temperature` |

Voir [`.claude/agents/refactor.md`](.claude/agents/refactor.md) pour les détails.

## 📚 Documentation

- [Système complet](docs/SYSTEME_CHAUFFAGE_COMPLET.md) - Documentation complète
- [Index](docs/INDEX.md) - Index de tous les documents
- [Routage agents MCP](docs/ROUTAGE_AGENTS_MCP.md) - Utilisation des agents
- [Guide utilisateur](docs/GUIDE_UTILISATEUR_CHAUFFAGE.md) - Guide d'utilisation

## 🔧 Maintenance

### Modifier le planning
Éditer `automation_planning_horaire_v3_modejour.yaml` et `automation_planning_mise_a_jour_mode_global.yaml`.

### Ajouter une pièce
1. Créer les helpers (input_select, sensor)
2. Copier une automation existante
3. Adapter les entity_id
4. Importer

### Debug
Voir le dashboard `dashboard_debugging_modes_v2.yaml` pour les logs et états.

## 🤝 Contribuer

Les contributions sont les bienvenues ! Voir [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 Licence

MIT License - voir [LICENSE](LICENSE) pour les détails.

## 🙏 Remerciements

- Home Assistant communauté
- Projet [home-assistant-vibecode-agent](https://github.com/)
- [@coolver/home-assistant-mcp](https://github.com/coolver/home-assistant-mcp)

---

**Note:** Ce projet est configuré pour fonctionner avec les agents Claude MCP. Le dossier `.claude/` contient tous les prompts et patterns nécessaires.

**Tags:** `home-assistant` `chauffage` `climatisation` `mqtt` `zigbee` `broadlink` `mcp` `claude`
