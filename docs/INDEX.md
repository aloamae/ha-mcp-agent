# INDEX — Documentation Domotique Home Assistant

**Derniere mise a jour:** 6 janvier 2026

---

## Documents disponibles

### Installation et Configuration

| Document | Description |
|----------|-------------|
| [INSTALL.md](INSTALL.md) | Installation du Home Assistant Vibecode Agent |
| [ROUTAGE_AGENTS_MCP.md](ROUTAGE_AGENTS_MCP.md) | Regles de routage des agents Claude MCP |

### Systeme de Chauffage

| Document | Description |
|----------|-------------|
| [SYSTEME_CHAUFFAGE_COMPLET.md](SYSTEME_CHAUFFAGE_COMPLET.md) | Documentation complete et a jour du systeme |
| [AUDIT_SYSTEME_CHAUFFAGE.md](AUDIT_SYSTEME_CHAUFFAGE.md) | Audit complet du systeme (entites, automations, priorites) |
| [GUIDE_UTILISATEUR_CHAUFFAGE.md](GUIDE_UTILISATEUR_CHAUFFAGE.md) | Guide utilisateur pour le chauffage intelligent |

---

## Structure du systeme

```
SYSTEME DE CHAUFFAGE
|
+-- 6 PIECES
|   +-- GAZ: Cuisine, Parents, Loann
|   +-- CLIM: Salon, Axel, Maeva
|
+-- 6 NIVEAUX DE PRIORITE
|   +-- 1. Mode Vacances
|   +-- 2. Mode Humidite
|   +-- 3. Mode Manuel
|   +-- 4. Mode Planning
|   +-- 5. Mode Global
|   +-- 6. Pilotage
|
+-- 19 AUTOMATIONS
|   +-- 3 Planning (05:45, 08:00, 08:05, 17:00, 22:30)
|   +-- 4 Pilotage (GAZ + 3 CLIM)
|   +-- 12 Humidite (6 pieces x 2)
|
+-- DASHBOARDS
    +-- Chauffage complet
    +-- Debugging
```

---

## Acces rapide

### Commandes MCP courantes

```bash
# Lister toutes les entites
@home-assistant entities list

# Etat d'une entite
@home-assistant entity state --entity input_boolean.mode_vacance

# Lister les automations
@home-assistant automations list

# Verification config
@home-assistant config check
```

### Entites principales

| Entite | Role |
|--------|------|
| `input_boolean.mode_vacance` | Mode vacances global |
| `input_number.mode_chauffage_global` | Temperature globale |
| `sensor.mode_chauffage_global_temperature` | Lecture temperature globale |
| `switch.thermostat` | Chaudiere GAZ |
| `climate.climatisation_*` | Climatisations (salon, axel, maeva) |
| `input_boolean.planning_0805_actif` | Toggle planning 08:05 |

---

## Fichiers de configuration (.claude/)

| Fichier | Description |
|---------|-------------|
| `CLAUDE.md` | Playbook prompts + reference rapide |
| `system.md` | Prompt systeme agent HA |
| `tools.md` | Outils et commandes MCP |
| `agents/auditor.md` | Agent Auditeur |
| `agents/architect.md` | Agent Architecte |
| `agents/refactor.md` | Agent Refactoriseur |
| `agents/safety.md` | Agent Safety |
| `agents/lovelace.md` | Agent UI Lovelace |
| `home-assistant-capabilities.md` | Capacites MCP |
| `home-assistant-commands.md` | Commandes MCP |
| `mcp.json` | Configuration serveur MCP |

---

## Fichiers YAML principaux

### Automations Pilotage
| Fichier | Description |
|---------|-------------|
| `automation_chauffage_GAZ_v4_humidite.yaml` | Pilotage chaudiere GAZ |
| `automation_climatisation_SALON_v5_corrige.yaml` | Pilotage clim Salon |
| `automation_climatisation_AXEL_v4_corrige.yaml` | Pilotage clim Axel |
| `automation_climatisation_MAEVA_v4_corrige.yaml` | Pilotage clim Maeva |

### Automations Planning
| Fichier | Description |
|---------|-------------|
| `automation_planning_horaire_v3_modejour.yaml` | Planning automatique |
| `automation_planning_mise_a_jour_mode_global.yaml` | Mise a jour mode global |
| `automation_planning_0805_mode_global.yaml` | Planning optionnel 08:05 |

---

## Historique des corrections

| Date | Correction |
|------|------------|
| 22/12/2025 | Installation systeme MODEJOUR |
| 22/12/2025 | Correction regex consigne 3C -> 21C |
| 22/12/2025 | Correction doublons automations |
| 23/12/2025 | Correction trigger 05:45 |
| 23/12/2025 | Creation documentation docs/ |
| 06/01/2026 | Correction doublons automation Salon (bips) |
| 06/01/2026 | Correction condition arret clim (<= -0.5) |
| 06/01/2026 | Ajout planning optionnel 08:05 |
| 06/01/2026 | Mise a jour complete documentation et agents |

---

## Contacts et support

- **GitHub Issues:** Pour signaler des problemes
- **Documentation officielle HA:** https://www.home-assistant.io/docs/

---

**Fin de l'index**
