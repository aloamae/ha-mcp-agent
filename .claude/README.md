# 🧠 Skill Claude — Home Assistant (MCP)

Ce dossier définit un **skill complet pour Claude** afin de piloter,
analyser et améliorer Home Assistant **exclusivement via MCP**,
sans hallucination, sans commandes inventées, et sans bricolage.

Il transforme Claude en **architecte domotique fiable** :
- analyse réelle de l’existant
- génération de YAML Home Assistant valide
- exécution contrôlée via MCP
- compréhension des priorités et conflits
- UI Lovelace cohérente
- sécurité et traçabilité

---

## 📁 Structure des fichiers

.claude/
├─ README.md                          ← ce fichier (guide maître)
├─ system.md                          ← prompt système anti-hallucination
├─ tools.md                           ← règles et logique d’utilisation MCP
├─ home-assistant-capabilities.md     ← capacités fonctionnelles (quoi faire)
├─ home-assistant-commands.md         ← commandes MCP + exemples concrets
└─ claude.md                          ← skill d’utilisation (comment parler à l’agent)

---

## 🔐 1. system.md — PROMPT SYSTÈME (OBLIGATOIRE)

👉 **Cerveau de l’agent**

Rôle :
- Bloquer toute hallucination
- Interdire toute commande inventée
- Forcer l’usage exclusif de :
  - YAML Home Assistant valide
  - services HA officiels
  - MCP Home Assistant

Contient :
- règles absolues
- format de réponse imposé
- contraintes techniques
- langue (français uniquement)

⚠️ Sans ce fichier, l’agent N’EST PAS FIABLE.

---

## 🧭 2. tools.md — RÈGLES D’USAGE DES OUTILS

👉 **Garde-fou logique**

Définit :
- quand utiliser MCP
- quand s’arrêter
- quand demander confirmation
- comment raisonner avant d’agir

Ce fichier empêche :
- les actions prématurées
- les chaînes d’actions dangereuses
- les suppositions implicites

---

## 🧩 3. home-assistant-capabilities.md — CE QUE L’AGENT SAIT FAIRE

👉 **Référentiel fonctionnel**

Décrit toutes les capacités attendues :

### 🔍 Analyse
- lire toute la configuration
- comprendre entités, appareils, zones
- analyser automatisations, scripts, helpers
- comprendre la logique réelle existante

### 🏗️ Construction intelligente
- créer des systèmes complets (helpers → automations → UI)
- refactoriser l’existant
- améliorer sans casser
- travailler sur des priorités explicites

### 📊 UI / Lovelace
- lire et modifier dashboards
- organiser vues et pièces
- améliorer lisibilité et cohérence

### 🔒 Sécurité
- validation avant application
- rollback conceptuel
- explication humaine de chaque changement

### 📦 Communauté
- HACS
- intégrations
- thèmes
- mises à jour

👉 Ce fichier définit le **périmètre du skill**.

---

## ⌨️ 4. home-assistant-commands.md — COMMANDES MCP

👉 **Cheat-sheet opérationnelle**

Contient :
- toutes les commandes MCP Home Assistant
- leur syntaxe exacte
- 1 à 2 exemples par commande

Exemples :
```text
@home-assistant entities list --area salon
@home-assistant automations list
@home-assistant entity state --entity climate.salon
