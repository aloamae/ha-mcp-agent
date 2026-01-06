# Capacités & commandes — MCP Home Assistant

Ce document sert de **référentiel d’interrogation et d’action** pour un agent IA connecté à Home Assistant via MCP.

Il décrit :
- les capacités disponibles
- les types de commandes possibles
- des exemples de prompts naturels
- les usages avancés (analyse, refactorisation, UI, sécurité, HACS)

---

## 🔍 1. Analyse complète du système (READ-ONLY)

### 📌 Capacités
- Lire toute la configuration Home Assistant
- Comprendre les entités, appareils, zones et relations
- Analyser les automatisations, scripts et helpers existants
- Comprendre la logique actuelle (conditions, déclencheurs, actions)

### 🧠 Exemples de prompts
- « Analyse toute ma configuration Home Assistant »
- « Liste toutes les entités par zone »
- « Quels appareils sont liés au salon ? »
- « Explique le fonctionnement de cette automatisation »
- « Quelles automatisations utilisent ce capteur ? »
- « Résume la logique actuelle de mon système domotique »

---

## 🧩 2. Entités & appareils

### 📌 Capacités
- Lister toutes les entités
- Lire l’état d’une entité
- Identifier les capacités (on/off, luminosité, température, modes)
- Comprendre les relations entité ↔ appareil ↔ zone

### 🧠 Exemples
- « Liste toutes les lumières »
- « Quel est l’état de la lumière du salon ? »
- « Quelles entités contrôlent le chauffage ? »
- « Montre-moi les capteurs liés à la porte d’entrée »

---

## ⚙️ 3. Automatisations

### 📌 Capacités
- Lire et analyser les automatisations existantes
- Comprendre déclencheurs, conditions et actions
- Proposer des améliorations ou refactorisations
- Fusionner plusieurs automatisations
- Créer de nouvelles automatisations cohérentes avec l’existant

### 🧠 Exemples
- « Analyse toutes mes automatisations »
- « Cette automatisation est-elle optimisable ? »
- « Fusionne ces deux automatisations en une seule plus propre »
- « Crée une automatisation basée sur ma configuration réelle »
- « Quelles automatisations se déclenchent la nuit ? »

---

## 📜 4. Scripts

### 📌 Capacités
- Lire les scripts existants
- Expliquer leur logique
- Les optimiser ou les simplifier
- Créer de nouveaux scripts basés sur de vraies entités

### 🧠 Exemples
- « Explique ce script »
- « Optimise ce script »
- « Crée un script “Départ de la maison” »
- « Quels scripts contrôlent les lumières ? »

---

## 🧰 5. Helpers & capteurs

### 📌 Capacités
- Identifier les helpers existants (input_boolean, input_number, etc.)
- Créer de nouveaux helpers adaptés au besoin
- Générer des capteurs ou capteurs templates
- Refactoriser la logique basée sur helpers

### 🧠 Exemples
- « Liste tous mes helpers »
- « Crée un helper pour le mode nuit »
- « Génère un capteur basé sur plusieurs entités »
- « Remplace cette logique par un helper plus propre »

---

## 🏗️ 6. Construction de systèmes intelligents

### 📌 Capacités
- Concevoir des systèmes complets (pas juste une automation)
- Créer des logiques interconnectées (helpers + scripts + automations)
- Adapter la solution à la configuration réelle

### 🧠 Exemples
- « Crée un système de gestion intelligente du chauffage »
- « Mets en place un mode absence complet »
- « Conçois un système jour / nuit basé sur mes capteurs »
- « Améliore mon système existant sans tout recréer »

---

## 📊 7. Dashboards & interface (Lovelace)

### 📌 Capacités
- Lire les dashboards existants
- Créer ou modifier des dashboards Lovelace
- Ajouter / supprimer / réorganiser des cartes
- Gérer vues, zones et scénarios
- Personnaliser thèmes et styles

### 🧠 Exemples
- « Crée un dashboard pour le salon »
- « Ajoute une carte historique pour la température »
- « Réorganise ce dashboard par pièces »
- « Améliore la lisibilité de mon interface »
- « Crée un thème sombre personnalisé »

---

## 🔒 8. Opérations sûres & gouvernance

### 📌 Capacités
- Versionner les changements (Git)
- Expliquer chaque modification (humainement)
- Valider la configuration avant application
- Revenir à un état précédent
- Tenir un journal d’activité

### 🧠 Exemples
- « Explique ce qui va changer avant d’appliquer »
- « Vérifie que cette configuration est valide »
- « Reviens à la version précédente »
- « Montre l’historique des modifications »
- « Résume les actions effectuées aujourd’hui »

---

## 📦 9. Extension via la communauté (HACS)

### 📌 Capacités
- Installer et configurer HACS
- Rechercher des intégrations communautaires
- Installer des thèmes, plugins et composants
- Mettre à jour toutes les intégrations HACS

### 🧠 Exemples
- « Installe HACS »
- « Cherche un thème moderne pour Home Assistant »
- « Installe une intégration météo avancée »
- « Mets à jour tous les composants HACS »
- « Propose des intégrations utiles pour mon setup »

---

## 🧭 10. Règles de fonctionnement de l’agent

- Toujours analyser avant d’agir
- Ne jamais inventer d’entités
- S’appuyer uniquement sur la configuration réelle
- Expliquer les changements avant application
- Prioriser la sécurité et la réversibilité

---

## 🎯 Objectif global

Cet agent doit être capable de :
- Comprendre entièrement le système Home Assistant existant
- L’améliorer intelligemment sans le casser
- Construire des solutions complètes et maintenables
- Agir comme un **architecte domotique IA**
