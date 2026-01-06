Parfait 👍
Maintenant que **tout fonctionne**, voici **LA synthèse claire et opérationnelle** :
👉 **quoi demander**,
👉 **à quel agent**,
👉 **comment formuler le prompt**,
👉 **avec des exemples concrets en français**, **adaptés à ton setup Continue + Ollama + MCP Home Assistant**.

Je m’appuie sur ta config fonctionnelle et sur les commandes MCP validées .

---

# 🧠 QUI FAIT QUOI (rappel rapide)

| Cible                     | Quand l’utiliser                | Syntaxe              |
| ------------------------- | ------------------------------- | -------------------- |
| **MCP Home Assistant**    | Lire / agir DIRECTEMENT sur HA  | `@home-assistant …`  |
| **Agent infra-domotique** | Analyser, concevoir, refactorer | `@infra-domotique …` |
| **Agent brainstorm**      | Idées, scénarios, options       | `@brainstorm …`      |
| **Agent speed**           | Réponses courtes, debug rapide  | `@speed …`           |

---

# 🔍 ANALYSER TON INSTALLATION

## Lire toute la configuration existante

👉 **Objectif** : comprendre ce qui existe déjà

```text
@home-assistant entities list
@home-assistant automations list
@home-assistant scripts list
@home-assistant integrations list
@home-assistant areas list
@home-assistant devices list
```

👉 **Version “intelligente” (agent)** :

```text
@infra-domotique Analyse toute mon installation Home Assistant :
- entités
- automatisations
- scripts
- helpers
et fais-moi un résumé clair de la logique existante.
```

---

## Comprendre un device / une zone

```text
@home-assistant areas salon entities
@home-assistant device <device_id> entities
@home-assistant entity light.salon attributes
```

👉 Avec raisonnement :

```text
@infra-domotique Explique comment fonctionne actuellement l’éclairage du salon
et quelles automatisations ou scripts sont liés.
```

---

# 🏗️ CONSTRUIRE DE L’INTELLIGENCE

## Créer un système complet (multi-automations)

```text
@infra-domotique
Crée un système complet de gestion du salon :
- présence
- luminosité adaptative
- extinction automatique
- mode nuit
en réutilisant les entités existantes.
```

---

## Générer des helpers & capteurs

```text
@infra-domotique
Propose et crée les helpers nécessaires pour :
- un mode “soirée”
- un mode “absent”
avec des noms cohérents et réutilisables.
```

---

## Scripts optimisés

```text
@infra-domotique
Crée un script Home Assistant pour éteindre toute la maison
en tenant compte des exceptions (serveur, NAS).
```

---

## Refactorer l’existant (très puissant)

```text
@infra-domotique
Analyse mes automatisations existantes liées à l’éclairage
et propose une version simplifiée et plus robuste
(en fusionnant si possible).
```

---

# 📊 DASHBOARDS & UI (LOVELACE)

## Créer un dashboard complet

```text
@infra-domotique
Crée un dashboard Lovelace pour le salon :
- lumières
- capteurs
- état présence
- raccourcis scénarios
avec une vue claire et lisible.
```

---

## Modifier un dashboard existant

```text
@infra-domotique
Ajoute une carte graphique de température
sur le dashboard du salon, sans casser l’existant.
```

---

## Thèmes & UI

```text
@infra-domotique
Propose un thème sombre lisible pour tablette murale
avec des couleurs sobres et contrastées.
```

---

# 🔒 OPÉRATIONS SÛRES (GIT / VALIDATION)

👉 (si ton HA est versionné via Git)

```text
@infra-domotique
Applique cette modification avec un commit Git clair
expliquant ce qui change et pourquoi.
```

```text
@infra-domotique
Valide la configuration avant application
et signale les risques éventuels.
```

```text
@infra-domotique
Reviens à l’état précédent si la modification pose problème.
```

---

# 📦 ÉCOSYSTÈME & HACS

## Installer HACS

```text
@infra-domotique
Installe et configure HACS proprement
sur mon Home Assistant Docker.
```

---

## Rechercher et installer une intégration

```text
@infra-domotique
Cherche dans HACS une intégration pour :
- dashboards énergie
et installe-la avec la configuration recommandée.
```

---

## Mettre à jour

```text
@infra-domotique
Mets à jour toutes les intégrations HACS
et fais un résumé des changements.
```

---

# ⚡ COMMANDES MCP DIRECTES (quand tu sais ce que tu veux)

### Lire

```text
@home-assistant states light.salon
@home-assistant entities list --domain light
@home-assistant entities list --area salon
```

### Agir

```text
@home-assistant service light.turn_on light.salon
@home-assistant service light.turn_off light.salon
@home-assistant service notify.notify "Test notification"
```

---

# 🧠 BRAINSTORM (idées, scénarios)

```text
@brainstorm
Donne-moi 5 idées d’automations utiles
basées sur mes capteurs actuels.
```

```text
@brainstorm
Quels scénarios domotiques avancés pourrais-je mettre en place
avec Zigbee2MQTT et la présence ?
```

---

# 🧪 DEBUG / RAPIDE

```text
@speed
Pourquoi cette automation ne se déclenche pas ?
```

```text
@speed
Explique rapidement ce YAML.
```

---

# 🧩 RÈGLE D’OR POUR TES PROMPTS

👉 **Sois explicite sur l’intention**, pas sur la technique.

❌ Mauvais :

> “Fais une automation”

✅ Bon :

> “Crée une automation pour éteindre automatiquement le salon
> quand il n’y a plus de présence depuis 10 minutes,
> en utilisant les entités existantes.”

---

# 🎯 PREMIER TEST RECOMMANDÉ (maintenant)

```text
@infra-domotique
Analyse mon installation Home Assistant actuelle
et propose 3 améliorations concrètes à forte valeur ajoutée.
```

Puis :

```text
@home-assistant entities list
```

---

Si tu veux, prochaine étape possible :

* 🔐 **mode ultra-sécurisé** (lecture seule / écriture contrôlée)
* 🧠 **planner / executor** (un agent qui planifie, un qui applique)
* 📘 **cheat-sheet PDF** de toutes ces commandes

Dis-moi 🚀
