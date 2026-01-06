Parfait 👍
Voici **une version enrichie et exploitable directement**, avec **TOUTES les grandes commandes MCP Home Assistant**, **leur syntaxe**, et **1–2 exemples concrets par commande**, **dans le style que tu demandes** :

👉 **`@home-assistant …` prêt à être copié-collé dans Claude Code**

---

# 📄 `.claude/home-assistant-commands.md`

````md
# Commandes & exemples — MCP Home Assistant

Ce document liste les **commandes MCP Home Assistant disponibles**
avec leur **syntaxe exacte** et des **exemples concrets d’utilisation**.

Format :
@home-assistant <commande> [options]

---

## 🔍 1. Exploration globale

### Lister toutes les entités
```text
@home-assistant entities list
````

```text
@home-assistant entities list --domain light
```

---

### Lister les entités par zone

```text
@home-assistant entities list --area salon
```

```text
@home-assistant entities list --area cuisine
```

---

### Lister les appareils

```text
@home-assistant devices list
```

---

### Lister les zones

```text
@home-assistant areas list
```

---

## 📊 2. États & informations

### Lire l’état d’une entité

```text
@home-assistant entity state --entity light.salon
```

```text
@home-assistant entity state --entity climate.chauffage
```

---

### Obtenir les attributs détaillés

```text
@home-assistant entity attributes --entity light.salon
```

---

### Historique d’une entité

```text
@home-assistant entity history --entity sensor.temperature_salon
```

---

## 💡 3. Contrôle des entités

### Allumer / éteindre

```text
@home-assistant service call --domain light --service turn_on --entity light.salon
```

```text
@home-assistant service call --domain light --service turn_off --area salon
```

---

### Régler la luminosité

```text
@home-assistant service call --domain light --service turn_on --entity light.salon --brightness 150
```

---

### Chauffage / climat

```text
@home-assistant service call --domain climate --service set_temperature --entity climate.chauffage --temperature 21
```

---

### Media player

```text
@home-assistant service call --domain media_player --service volume_set --entity media_player.salon --volume_level 0.4
```

---

## ⚙️ 4. Automatisations

### Lister les automatisations

```text
@home-assistant automations list
```

---

### Lire une automatisation

```text
@home-assistant automation get --id automation.lumiere_soir
```

---

### Activer / désactiver

```text
@home-assistant automation toggle --id automation.lumiere_soir --state off
```

---

## 📜 5. Scripts

### Lister les scripts

```text
@home-assistant scripts list
```

---

### Exécuter un script

```text
@home-assistant script run --entity script.depart_maison
```

---

### Lire un script

```text
@home-assistant script get --entity script.depart_maison
```

---

## 🧰 6. Helpers (input_*)

### Lister les helpers

```text
@home-assistant helpers list
```

---

### Lire un helper

```text
@home-assistant entity state --entity input_boolean.mode_nuit
```

---

### Modifier un helper

```text
@home-assistant service call --domain input_boolean --service turn_on --entity input_boolean.mode_nuit
```

---

## 🏗️ 7. Capteurs & templates

### Lire un capteur

```text
@home-assistant entity state --entity sensor.humidite_salon
```

---

### Vérifier les dépendances

```text
@home-assistant entity related --entity sensor.humidite_salon
```

---

## 📊 8. Dashboards Lovelace

### Lister les dashboards

```text
@home-assistant dashboards list
```

---

### Lire un dashboard

```text
@home-assistant dashboard get --id lovelace
```

---

### Mettre à jour un dashboard

```text
@home-assistant dashboard update --id lovelace
```

---

## 🔒 9. Sécurité & validation

### Vérifier la configuration

```text
@home-assistant config check
```

---

### Redémarrer Home Assistant

```text
@home-assistant core restart
```

---

### Recharger sans redémarrage

```text
@home-assistant reload all
```

---

## 📦 10. HACS (si installé)

### Vérifier HACS

```text
@home-assistant hacs status
```

---

### Rechercher une intégration

```text
@home-assistant hacs search --query dashboard
```

---

### Installer un composant

```text
@home-assistant hacs install --repo hacs/integration
```

---

### Mettre à jour tout HACS

```text
@home-assistant hacs update --all
```

---

## 🧠 11. Analyse intelligente (prompts composés)

### Analyse complète du système

```text
Analyse toute ma configuration Home Assistant :
entités, appareils, automatisations, scripts et helpers.
```

---

### Refactorisation

```text
Analyse mes automatisations existantes et propose
une version plus simple et plus maintenable.
```

---

### Construction d’un système

```text
Crée un système complet de gestion jour/nuit
basé sur mes capteurs réels.
```

---

## 🎯 Règles d’utilisation

* Toujours lister avant d’agir
* Ne jamais deviner d’entités
* Expliquer avant exécution
* Prioriser la sécurité et la réversibilité

Objectif : agir comme un **architecte domotique IA**.

````

---

## ✅ Où placer ce fichier

```text
.claude/home-assistant-commands.md
````

👉 Claude l’utilisera comme **catalogue de commandes + exemples**.

---


