# Playbook — Utilisation des agents Home Assistant (MCP)

## Regle d'or
Toujours commencer par l'Auditeur (inventaire reel) avant :
- analyse avancee
- refactor
- architecture
- UI
- execution

---

## Prompts prets a l'emploi

### 1) Audit strict (obligatoire)
@infra-domotique (Auditeur)

INTERDICTION ABSOLUE D'INVENTER.

ETAPE 1 — INVENTAIRE REEL via MCP :
- zones
- entites (domaines: climate, sensor, light, switch + helpers)
- automations
- scripts

ETAPE 2 — FILTRE :
Ne garde que ce qui concerne : <SUJET>

Si inventaire impossible :
"Analyse impossible sans inventaire reel".

---

### 2) Architecture (helpers → automations → UI)
@infra-domotique (Architecte)

A partir de l'inventaire reel fourni, concois un systeme complet :
- helpers
- automations
- UI Lovelace

Priorites EXPLICITES. YAML valide uniquement.
Liste les commandes MCP de validation (reload/check) si disponibles.

---

### 3) Refactor
@infra-domotique (Refactoriseur)

A partir des automations reelles listees, propose une refactorisation :
- reduire conflits
- rendre priorites explicites
- ameliorer maintenabilite

YAML complet + plan de tests.

---

### 4) UI Lovelace
@infra-domotique (UI)

A partir des entites reelles, propose un dashboard Lovelace :
- vue par piece
- cartes pertinentes
- lisibilite + pilotage

YAML Lovelace uniquement.

---

### 5) Safety / Apply
@infra-domotique (Safety)

Avant toute action :
- explique precisement ce qui change
- donne les commandes MCP exactes
- inclut validation + tests + annulation
Refuse si non tracable.

---

## Systeme de chauffage - Reference rapide

### Entites cles

| Type | Entites |
|------|---------|
| Vacances | input_boolean.mode_vacance |
| Global | input_number.mode_chauffage_global, sensor.mode_chauffage_global_temperature |
| Modes pieces | input_select.mode_chauffage_* (6 pieces) |
| Humidite | input_boolean.mode_humidite_* (6 pieces) |
| Capteurs | sensor.th_*_temperature, sensor.th_*_humidity |
| GAZ | switch.thermostat |
| CLIM | climate.climatisation_salon/axel/maeva |

### Priorites (ordre decroissant)
1. Mode Vacances → 16C partout
2. Mode Humidite → +2C
3. Mode Manuel → temperature fixe
4. Mode Planning → MODEJOUR
5. Mode Global → temperature globale
6. Pilotage → execution

### Planning horaire
| Heure | Temperature |
|-------|-------------|
| 05:45 | 19C |
| 08:00 | 17C |
| 08:05 | 19C (optionnel) |
| 17:00 | 19C |
| 22:30 | 17C |

### Bugs connus et solutions

| Bug | Solution |
|-----|----------|
| Consigne 2C/3C | Regex `\((\d+\.?\d*)\)` |
| Clim bipe sans agir | Verifier doublons, ajouter `!= 'heat'` |
| Clim ne s'arrete pas | Condition `<= -0.5` (pas `<`) |
| MODEJOUR ne marche pas | Utiliser `sensor.mode_chauffage_global_temperature` |

### Fichiers YAML principaux
- automation_chauffage_GAZ_v4_humidite.yaml
- automation_climatisation_SALON_v5_corrige.yaml
- automation_climatisation_AXEL_v4_corrige.yaml
- automation_climatisation_MAEVA_v4_corrige.yaml
