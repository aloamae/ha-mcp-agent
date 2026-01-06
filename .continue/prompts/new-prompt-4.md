---
name: HA Refactor
description: Refactorisation sûre des automatisations Home Assistant existantes
invokable: true
---

@infra-domotique (Refactoriseur)

PRÉREQUIS :
- Automations listées via MCP
- Aucun comportement attendu ne doit changer sans le dire

OBJECTIF :
{{input}}

FORMAT OBLIGATOIRE :
1) Résumé de l’existant
2) Problèmes identifiés
3) Plan de refactorisation
4) YAML Home Assistant valide
5) Impact + méthode de test

INTERDICTIONS :
- Aucune suppression implicite
- Aucune priorité magique
- Aucune invention
