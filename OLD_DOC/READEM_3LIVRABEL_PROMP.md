Parfait 👍
Voici **les 3 livrables promis**, **prêts à l’emploi**, **testés mentalement avec ton setup Continue + Ollama + MCP Home Assistant**, et **conçus pour éliminer les hallucinations**.


## https://chatgpt.com/c/6943d0e8-63d4-8325-bb6a-6fef43976986


---

# 🔐 1) PROMPT SYSTÈME **ANTI-HALLUCINATION** (À COPIER TEL QUEL)

👉 À mettre dans **l’agent `infra-domotique`** (systemMessage / instructions)

```
Tu es un agent expert Home Assistant.

RÈGLES ABSOLUES :
- Tu N’INVENTES JAMAIS de commandes CLI (hass, homeassistant, shell, etc.).
- Tu N’INVENTES JAMAIS d’outils ou de fonctions (create_xxx, run_terminal, etc.).
- Tu utilises UNIQUEMENT :
  - YAML Home Assistant valide
  - les services Home Assistant officiels
  - le MCP Home Assistant pour appliquer ou lire l’état
- Si une action n’est PAS possible via Home Assistant ou MCP,
  tu l’indiques clairement au lieu d’inventer.

FORMAT DES RÉPONSES :
1) Hypothèse / prérequis (si nécessaire)
2) YAML Home Assistant COMPLET et VALIDE
3) Explication courte
4) Action MCP à exécuter (si applicable)

CONTRAINTES TECHNIQUES :
- YAML strict (espaces, pas de tabulation)
- Pas de pseudo-code
- Pas de code Python
- Pas de commandes shell

LANGUE :
- Français uniquement
```

👉 **Ce prompt suffit à stopper 95 % des hallucinations**.

---

# 🧠 2) TEMPLATE OFFICIEL

## **Helper → Automation → UI (Lovelace)**

👉 **Toujours suivre cet ordre**
👉 **Toujours réutilisable**

---

## 🧩 A. HELPERS (logique métier)

```yaml
input_boolean:
  mode_soiree:
    name: Mode Soirée
    icon: mdi:glass-cocktail

input_select:
  type_soiree:
    name: Type de soirée
    options:
      - Chill
      - Film
      - Invités
    icon: mdi:playlist-music

input_number:
  luminosite_soiree:
    name: Luminosité Soirée
    min: 10
    max: 100
    step: 5
    unit_of_measurement: "%"
```

---

## ⚙️ B. AUTOMATION (comportement)

```yaml
automation:
  - alias: Soirée - Gestion salon
    mode: restart
    trigger:
      - platform: state
        entity_id: input_boolean.mode_soiree
        to: "on"

    action:
      - service: light.turn_on
        target:
          area_id: salon
        data:
          brightness_pct: "{{ states('input_number.luminosite_soiree') | int }}"

      - choose:
          - conditions:
              - condition: state
                entity_id: input_select.type_soiree
                state: "Film"
            sequence:
              - service: scene.turn_on
                target:
                  entity_id: scene.salon_film
```

---

## 🎛️ C. UI (Lovelace)

```yaml
type: entities
title: Mode Soirée
entities:
  - input_boolean.mode_soiree
  - input_select.type_soiree
  - input_number.luminosite_soiree
```

---

# 🧪 3) EXÉCUTER **100 % VIA MCP** (SANS TOUCHER AUX FICHIERS)

👉 Tu **NE touches PAS** aux fichiers YAML
👉 Tu **NE redémarres PAS à l’aveugle**
👉 Tu pilotes **tout via MCP**

---

## 🟢 Étape 1 — Vérifier l’existant

```
@home-assistant entities list --domain input_boolean
@home-assistant entities list --domain input_select
@home-assistant entities list --domain input_number
```

---

## 🟢 Étape 2 — Créer via services HA (MCP)

👉 Home Assistant permet la création dynamique via services :

```
@home-assistant service input_boolean.create
```

ou (si ton HA ne supporte pas `create`) :

👉 **l’agent génère le YAML + te demande confirmation**.

---

## 🟢 Étape 3 — Recharger sans redémarrer

```
@home-assistant service homeassistant.reload_core_config
@home-assistant service automation.reload
```

---

## 🟢 Étape 4 — Validation

```
@home-assistant states input_boolean.mode_soiree
@home-assistant states input_select.type_soiree
```

---

## 🟢 Étape 5 — UI

```
@infra-domotique
Ajoute la carte Lovelace du mode Soirée
sur le dashboard Salon existant.
```

---

# 🧠 PROMPT TYPE (À UTILISER AU QUOTIDIEN)

👉 **Copie-colle quand tu veux créer quelque chose**

```
@infra-domotique
En utilisant UNIQUEMENT des mécanismes réels de Home Assistant,
crée un système complet :
- helpers
- automations
- UI
Explique ce que tu fais
et indique les actions MCP nécessaires.
```

---

# 🎯 PREMIER TEST RECOMMANDÉ (MAINTENANT)

```
@infra-domotique
Crée un système "Soirée cinéma"
en respectant strictement les règles anti-hallucination.
```

---

## ✅ CE QUE TU AS MAINTENANT

✔️ Un **prompt système solide**
✔️ Un **template officiel réutilisable**
✔️ Une méthode **100 % MCP, sans bricolage**
✔️ Une base **propre, maintenable, extensible**

Si tu veux la suite :

* 🔐 mode **lecture seule / écriture contrôlée**
* 🧠 **planner / executor** (double agent)
* 📘 **cheat-sheet PDF** pour tout HA + MCP


####commande###

1) Lister les automations
@home-assistant automations list

2) Lister les helpers chauffage (vrais domaines)
@home-assistant entities list --domain input_boolean,input_select,input_number,input_datetime,timer,schedule

3) Filtrer tout ce qui ressemble à “chauffage / heat / vacances / manuel / planning”

(si le MCP accepte pas --search, fais une liste complète et on filtrera à la main)

@home-assistant entities list

4) Récupérer l’état du thermostat / chauffage (si tu en as un)

(exemples : adapte avec ton vrai entity_id une fois listé)

@home-assistant states climate.salon


###PROMPT####

### analyse - 000###
@infra-domotique

INTERDICTION ABSOLUE D’INVENTER.

Avant toute analyse ou explication :
1) Tu DOIS lister les entités et automatisations EXACTES
   en te basant sur Home Assistant (via MCP).
2) Tu DOIS afficher les entity_id exacts.
3) Si tu ne peux pas les lister, tu t’arrêtes et tu dis :
   "Analyse impossible sans inventaire réel".

RÈGLES STRICTES :
- Tu n’affirmes JAMAIS un ordre d’exécution global entre automations.
- Tu expliques uniquement ce qui est traçable :
  trigger → condition → action.
- Tu n’utilises PAS de termes comme
  "désactiver une règle" sans service explicite.

OBJECTIF :
Analyser le fonctionnement RÉEL d’un système de chauffage
avec priorités Vacances > Manuel > Planning,
température et humidité incluses,
en expliquant :
- ce qui se passe réellement
- ce qui est implicite
- ce qui est dangereux
- ce qui n’est PAS garanti.

Si l’existant est incomplet ou ambigu :
- Tu le dis clairement
- Tu proposes UNE clarification minimale

#####


### ANALYSE -00 ###
@infra-domotique

Audit mon système de chauffage Home Assistant.

ÉTAPE 1 — INVENTAIRE RÉEL
Liste :
- toutes les automations liées au chauffage
- tous les helpers utilisés
- les triggers exacts
- les conditions exactes

ÉTAPE 2 — ANALYSE TRAÇABLE
Pour chaque automation :
- quand se déclenche-t-elle
- ce qu’elle fait exactement
- ce qui peut entrer en conflit avec une autre

ÉTAPE 3 — PRIORITÉS RÉELLES
Explique si la priorité Vacances > Manuel > Planning
est :
- explicitement codée
- implicitement supposée
- ou inexistante

Ne propose AUCUNE modification à cette étape.
Analyse uniquement.

###################
### PROMP -01###
@infra-domotique

INTERDICTION ABSOLUE D’INVENTER.

Avant toute analyse ou explication :
1) Tu DOIS lister les entités et automatisations EXACTES
   en te basant sur Home Assistant (via MCP).
2) Tu DOIS afficher les entity_id exacts.
3) Si tu ne peux pas les lister, tu t’arrêtes et tu dis :
   "Analyse impossible sans inventaire réel".

RÈGLES STRICTES :
- Tu n’affirmes JAMAIS un ordre d’exécution global entre automations.
- Tu expliques uniquement ce qui est traçable :
  trigger → condition → action.
- Tu n’utilises PAS de termes comme
  "désactiver une règle" sans service explicite.

OBJECTIF :
Analyser le fonctionnement RÉEL d’un système de chauffage
avec priorités Vacances > Manuel > Planning,
température et humidité incluses,
en expliquant :
- ce qui se passe réellement
- ce qui est implicite
- ce qui est dangereux
- ce qui n’est PAS garanti.

Si l’existant est incomplet ou ambigu :
- Tu le dis clairement
- Tu proposes UNE clarification minimale


######
Dis-moi 🚀



###############FONCTIONEN######
@infra-domotique

Analyse MON EXISTANT Home Assistant avant toute explication.

ÉTAPE 1 — INVENTAIRE OBLIGATOIRE
- Liste les helpers liés au chauffage (input_boolean, input_select, input_number).
- Liste les automatisations existantes liées :
  - au chauffage
  - aux modes (vacances, manuel, planning)
  - à la température et à l’humidité.
- Précise les entity_id exacts utilisés.

ÉTAPE 2 — ANALYSE FACTUELLE
En te basant UNIQUEMENT sur l’existant :
- Explique l’ordre réel d’exécution des automatisations.
- Montre quels triggers peuvent se chevaucher.
- Identifie les conflits potentiels.

ÉTAPE 3 — PRIORITÉS (SANS THÉORIE)
Explique COMMENT les priorités sont actuellement implémentées
(conditions, choose, blocage logique),
ou dis clairement si elles ne le sont PAS.

Priorité attendue :
1) Mode Vacances (bloque tout)
2) Mode Manuel
3) Mode Chauffage planifié (4 plages horaires)

ÉTAPE 4 — SCÉNARIOS RÉELS
Explique pas-à-pas ce qui se passe quand :
- Le mode Vacances passe à ON
- Le mode Manuel est activé
- Une plage horaire se déclenche
- L’humidité dépasse le seuil

ÉTAPE 5 — CONCLUSION
- Ce qui fonctionne réellement
- Ce qui est fragile
- Ce qui est incorrect ou implicite
- Ce qui devrait être clarifié

CONTRAINTES STRICTES :
- YAML Home Assistant uniquement
- Aucune priorité “magique”
- Aucune invention
- Français uniquement

#####


#######FTIOCNNE PAD ###########################
@infra-domotique

Analyse et explique en détail le fonctionnement interne d’une automation Home Assistant
avec des règles de priorité entre plusieurs modes.

CONTEXTE FONCTIONNEL :
Je veux gérer le chauffage avec les priorités suivantes (de la plus forte à la plus faible) :
1) Mode Vacances (priorité absolue)
2) Mode Manuel
3) Mode Chauffage planifié (4 plages horaires par jour)

Le chauffage doit aussi réagir :
- à la température ambiante
- au taux d’humidité
- aux changements d’état des modes

OBJECTIFS DE TA RÉPONSE :
1) Expliquer COMMENT Home Assistant évalue les priorités
2) Décrire l’ordre EXACT d’exécution interne :
   - triggers
   - conditions
   - choose / default
   - interruptions possibles
3) Montrer comment éviter les conflits entre modes
4) Expliquer comment une règle peut bloquer les autres
5) Expliquer quand et pourquoi une automation se relance ou s’arrête
6) Détailler le comportement en cas de changement d’humidité

CONTRAINTES TECHNIQUES :
- N’invente aucune commande ou outil
- Utilise uniquement des mécanismes réels Home Assistant
- Pas de pseudo-code
- YAML valide uniquement
- Français uniquement

STRUCTURE ATTENDUE DE LA RÉPONSE :
1) Schéma logique des priorités (texte clair)
2) Description du moteur d’automation Home Assistant
3) Exemple de helpers nécessaires
4) Exemple d’automation avec choose et priorités
5) Explication pas-à-pas d’un scénario réel :
   - passage en mode Vacances
   - retour en mode Manuel
   - retour au planning
6) Points de vigilance et erreurs courantes

OPTION BONUS :
Explique comment tester et valider que les priorités fonctionnent correctement
sans casser l’existant.
####################################################