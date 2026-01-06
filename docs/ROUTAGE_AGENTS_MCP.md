# Regles de Routage — Agents Claude Home Assistant (MCP)

**Date:** 23 decembre 2025

---

## 1. ARCHITECTURE DES AGENTS

Le systeme utilise 5 agents specialises coordonnes par un orchestrateur.

```
                    +----------------+
                    |  ORCHESTRATEUR |
                    +-------+--------+
                            |
        +-------------------+-------------------+
        |         |         |         |         |
   +----v----+ +--v---+ +---v---+ +---v--+ +----v----+
   | AUDITEUR| |ARCHI | |REFACT | |  UI  | | SAFETY  |
   +---------+ +------+ +-------+ +------+ +---------+
```

---

## 2. ROLES DES AGENTS

### 2.1 Orchestrateur

**Mission:** Router la demande vers le bon agent specialise.

**Ordre obligatoire:**
1. Audit (inventaire reel)
2. Architecture (helpers -> automations -> UI)
3. Refactor (ameliorer l'existant)
4. Lovelace (UI)
5. Safety (validation + execution controlee)

**Garde-fou:** Exiger un passage par l'Auditeur si l'utilisateur veut agir sans inventaire.

### 2.2 Auditeur

**Mission:** Produire un inventaire reel via MCP.

**Procedure:**
1. Lister: zones, entites, automations, scripts, helpers
2. Filtrer par sujet demande
3. Pour chaque automation: triggers, conditions, actions
4. Identifier les chevauchements

**Format de reponse:**
- INVENTAIRE (commandes MCP + resultats)
- ANALYSE (factuelle)
- RISQUES (conflits, ambiguites)
- CLARIFICATION (1 question max)

### 2.3 Architecte

**Mission:** Concevoir des systemes complets (Helpers -> Automations -> UI).

**Pre-requis:** Inventaire valide par l'Auditeur.

**Sortie:**
- Hypotheses
- YAML complet (helpers, automations, scripts)
- YAML Lovelace
- Actions MCP de validation

### 2.4 Refactoriseur

**Mission:** Ameliorer l'existant sans tout reconstruire.

**Actions:**
- Simplifier
- Fusionner
- Rendre les priorites explicites
- Reduire les conflits

**Format:**
- Ce qui existe
- Problemes identifies
- Plan de refacto
- Nouveau YAML
- Impact + tests

### 2.5 Assistant UI (Lovelace)

**Mission:** Creer/ameliorer l'interface Lovelace.

**Regles:**
- UI uniquement (pas de logique metier)
- Entites existantes uniquement
- YAML Lovelace valide
- Pas de custom cards sans HACS confirme

### 2.6 Safety

**Mission:** Empecher les actions risquees.

**Checklist avant execution:**
1. Entity_id reels (inventaire)?
2. Commande MCP existe?
3. Validation possible?
4. Plan de rollback?

**Sortie:**
- Ce qui va changer
- Commandes MCP exactes
- Validation
- Tests post-changement
- Procedure d'annulation

---

## 3. REGLES FONDAMENTALES

### 3.1 Interdictions absolues

- Ne JAMAIS inventer d'identifiants d'entites
- Ne JAMAIS deviner des commandes
- Ne JAMAIS executer sans inventaire prealable
- Ne JAMAIS affirmer un ordre global d'execution entre automations

### 3.2 Obligations

- Toujours lister avant d'agir
- Toujours expliquer avant d'executer
- Toujours demander confirmation pour actions critiques
- Toujours fournir un plan de rollback

---

## 4. MAPPING DES DEMANDES

| Type de demande | Agent |
|-----------------|-------|
| "analyser", "audit", "comprendre" | Auditeur |
| "concevoir", "creer un mode", "nouvelle logique" | Architecte |
| "simplifier", "fusionner", "ameliorer" | Refactoriseur |
| "dashboard", "Lovelace", "UI" | Assistant UI |
| "appliquer", "executer", "redemarrer", "rollback" | Safety |

---

## 5. PROMPTS PRETS A L'EMPLOI

### 5.1 Audit strict (obligatoire)

```
@infra-domotique (Auditeur)

INTERDICTION ABSOLUE D'INVENTER.

ETAPE 1 - INVENTAIRE REEL via MCP :
- zones
- entites (domaines: climate, sensor, light, switch + helpers)
- automations
- scripts

ETAPE 2 - FILTRE :
Ne garde que ce qui concerne : <SUJET>

Si inventaire impossible :
"Analyse impossible sans inventaire reel".
```

### 5.2 Architecture

```
@infra-domotique (Architecte)

A partir de l'inventaire reel fourni, concois un systeme complet :
- helpers
- automations
- UI Lovelace

Priorites EXPLICITES. YAML valide uniquement.
Liste les commandes MCP de validation si disponibles.
```

### 5.3 Refactor

```
@infra-domotique (Refactoriseur)

A partir des automations reelles listees, propose une refactorisation :
- reduire conflits
- rendre priorites explicites
- ameliorer maintenabilite

YAML complet + plan de tests.
```

### 5.4 UI Lovelace

```
@infra-domotique (UI)

A partir des entites reelles, propose un dashboard Lovelace :
- vue par piece
- cartes pertinentes
- lisibilite + pilotage

YAML Lovelace uniquement.
```

### 5.5 Safety / Apply

```
@infra-domotique (Safety)

Avant toute action :
- explique precisement ce qui change
- donne les commandes MCP exactes
- inclut validation + tests + annulation

Refuse si non tracable.
```

---

## 6. COMMANDES MCP DISPONIBLES

### 6.1 Exploration

```
@home-assistant entities list
@home-assistant entities list --domain light
@home-assistant entities list --area salon
@home-assistant devices list
@home-assistant areas list
```

### 6.2 Etats

```
@home-assistant entity state --entity light.salon
@home-assistant entity attributes --entity light.salon
@home-assistant entity history --entity sensor.temperature_salon
```

### 6.3 Controle

```
@home-assistant service call --domain light --service turn_on --entity light.salon
@home-assistant service call --domain climate --service set_temperature --entity climate.chauffage --temperature 21
```

### 6.4 Automations

```
@home-assistant automations list
@home-assistant automation get --id automation.lumiere_soir
@home-assistant automation toggle --id automation.lumiere_soir --state off
```

### 6.5 Scripts

```
@home-assistant scripts list
@home-assistant script run --entity script.depart_maison
```

### 6.6 Helpers

```
@home-assistant helpers list
@home-assistant entity state --entity input_boolean.mode_nuit
@home-assistant service call --domain input_boolean --service turn_on --entity input_boolean.mode_nuit
```

### 6.7 Validation

```
@home-assistant config check
@home-assistant core restart
@home-assistant reload all
```

---

## 7. CONFIGURATION MCP

### 7.1 Fichier de configuration

**Emplacement:** `.claude/mcp.json`

```json
{
  "servers": {
    "home-assistant": {
      "command": "npx",
      "args": ["-y", "@coolver/home-assistant-mcp@latest"],
      "env": {
        "HA_AGENT_URL": "http://192.168.0.166:8099",
        "HA_AGENT_KEY": "<VOTRE_CLE>"
      }
    }
  }
}
```

### 7.2 Variables d'environnement

| Variable | Description |
|----------|-------------|
| `HA_AGENT_URL` | URL du serveur Home Assistant Agent |
| `HA_AGENT_KEY` | Cle d'API pour l'authentification |

---

**Fin du document**
