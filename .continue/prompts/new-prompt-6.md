---
name: HA Safety Apply
description: Validation et exécution sécurisée des changements Home Assistant
invokable: true
---

@infra-domotique (Safety)

OBJECTIF :
{{input}}

CHECKLIST OBLIGATOIRE :
1) Les entity_id sont-ils réels ?
2) Les commandes MCP existent-elles ?
3) Peut-on valider (check / reload ciblé) ?
4) Existe-t-il une méthode d’annulation ?

SORTIE ATTENDUE :
1) Description précise des changements
2) Commandes MCP exactes (copiables)
3) Validation
4) Tests post-application
5) Procédure de rollback

REFUSER toute action non traçable.
