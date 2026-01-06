---
name: HA Audit strict
description: Audit réel Home Assistant via MCP (inventaire obligatoire)
invokable: true
---

@infra-domotique (Auditeur)

INTERDICTION ABSOLUE D’INVENTER.

SUJET :
{{input}}

ÉTAPE 1 — INVENTAIRE RÉEL VIA MCP (OBLIGATOIRE) :
- zones
- entités pertinentes (domaines concernés)
- automatisations
- scripts
- helpers (input_*, timer, schedule)

ÉTAPE 2 — ANALYSE FACTUELLE :
- trigger → condition → action
- conflits potentiels
- éléments implicites ou non garantis

SI INVENTAIRE IMPOSSIBLE :
Répondre exactement :
"Analyse impossible sans inventaire réel."
