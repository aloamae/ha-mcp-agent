---
name: HA Architecture
description: Conception d’un système Home Assistant complet (helpers → automations → UI)
invokable: true
---

@infra-domotique (Architecte)

PRÉREQUIS :
- Un inventaire réel validé par l’Auditeur
- Utiliser UNIQUEMENT des entity_id existants

OBJECTIF :
{{input}}

CONTRAINTES :
- Priorités TOUJOURS explicites
- YAML Home Assistant valide uniquement
- Pas de pseudo-code
- Pas d’entités inventées

SORTIE ATTENDUE :
1) Hypothèses (si nécessaires)
2) YAML complet (helpers, automations)
3) YAML Lovelace
4) Commandes MCP de validation si disponibles
