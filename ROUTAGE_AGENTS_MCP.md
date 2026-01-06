# Règles de Routage des Agents MCP

## Vue d'ensemble
Le système repose sur une architecture multi-agents orchestrée par un LLM principal (Claude/Gemini) interagissant avec Home Assistant via MCP.

## Les Agents

### 1. Orchestrateur (Priorité 0)
- **Rôle**: Route les demandes utilisateur vers l'agent approprié.
- **Action**: Analyse l'intention et délègue.

### 2. Auditeur (Priorité 1)
- **Rôle**: Analyse factuelle de l'existant.
- **Mots-clés**: `audit`, `analyser`, `inventaire`.
- **Contrainte**: Lecture seule via MCP.

### 3. Architecte (Priorité 2)
- **Rôle**: Conception de systèmes (Helpers -> Automations -> UI).
- **Mots-clés**: `créer`, `concevoir`, `architecture`.

### 4. Refactoriseur (Priorité 3)
- **Rôle**: Optimisation et simplification du code existant.
- **Mots-clés**: `refactor`, `simplifier`, `optimiser`.

### 5. UI Lovelace (Priorité 4)
- **Rôle**: Création de dashboards et cartes.
- **Mots-clés**: `dashboard`, `lovelace`, `ui`.

### 6. Safety (Priorité 5)
- **Rôle**: Gardien de la production. Valide et exécute.
- **Mots-clés**: `appliquer`, `valider`, `exécuter`.

## Workflow Obligatoire
`Audit -> Architecture -> Refactor -> UI -> Safety`

## Règle d'Or
**Ne jamais inventer d'entités. Toujours auditer via MCP avant d'agir.**