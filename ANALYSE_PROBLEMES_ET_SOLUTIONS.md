# ANALYSE PROBLÈMES ET SOLUTIONS

**Date:** 20 décembre 2025

---

## ✅ CE QUI FONCTIONNE

### 1. Automation chaudière
- ✅ Seuils ±0.5°C actifs
- ✅ Zone morte maintient l'état
- ✅ Logs détaillés toutes les 3 min
- ✅ **PARFAIT!**

### 2. Mode Présence (partiellement)
- ✅ Départ: Scène créée + Hors-Gel activé
- ✅ Retour: Scène restaurée
- ✅ **FONCTIONNE!**

### 3. Remotes Broadlink
- ✅ Automations de réactivation créées
- ⏳ À tester (pas encore testées)

---

## ❌ PROBLÈMES IDENTIFIÉS

### PROBLÈME 1: Climatisations ne se déclenchent pas

**Observation:**
- Clim Maeva et Salon testées
- Aucune réaction physique
- Broadlink ne répond pas

**Causes possibles:**

| Cause | Vérification | Solution |
|-------|--------------|----------|
| Remotes OFF | États remotes | Activer via automations |
| SmartIR mal configuré | Logs SmartIR | Vérifier device_code |
| Codes IR invalides | Test manuel | Reconfigurer SmartIR |
| Broadlink déconnecté | Intégrations | Vérifier connexion WiFi |

**À FAIRE:**
1. Vérifier états: `remote.clim_salon`, `remote.clim_maeva`, `remote.clim_axel`
2. Si OFF → Exécuter automation "Activer remotes demarrage"
3. Test manuel: `climate.turn_on` → Observer LED Broadlink
4. Vérifier logs: Chercher "smartir" ou "broadlink"

---

### PROBLÈME 2: Mode Manuel ne prend pas en compte la consigne

**Observation:**
```
Mode Manuel activé via curseur
→ NE prend PAS la température de la liste déroulante
→ NE respecte PAS les autres modes
```

**Explication:**

Le mode Manuel n'est **pas connecté** au pilotage chaudière actuellement.

**Analyse du système actuel:**

```yaml
# Dans automation_chauffage_pilotage_chaudiere_corrigee.yaml
consigne: >
  {% if is_state('input_boolean.mode_vacance','on') %}
    16
  {% else %}
    {{ states('sensor.mode_chauffage_global')
       | regex_findall_index('\\d+\\.?\\d*')
       | float(18.5) }}
  {% endif %}
```

**Problème:**
- La consigne vient de `sensor.mode_chauffage_global`
- Ce sensor ne lit PAS les modes manuels par pièce
- Il agrège probablement planning + global, SANS les modes manuels

**SOLUTION 1: Modifier le calcul de consigne**

Ajouter une vérification des modes manuels AVANT sensor.mode_chauffage_global:

```yaml
consigne: >
  {% if is_state('input_boolean.mode_vacance','on') %}
    16
  {% elif states('input_select.mode_chauffage_salon') not in ['STOP', 'MODEJOUR'] %}
    {# Extraire température du mode manuel Salon #}
    {{ states('input_select.mode_chauffage_salon')
       | regex_findall_index('\\d+\\.?\\d*')
       | float(19) }}
  {% else %}
    {# Fallback sur mode global #}
    {{ states('sensor.mode_chauffage_global')
       | regex_findall_index('\\d+\\.?\\d*')
       | float(18.5) }}
  {% endif %}
```

**PROBLÈME avec cette approche:**
- Gère seulement Salon
- Comment gérer 3 pièces avec consignes différentes?

**SOLUTION 2: Consigne par pièce (COMPLEXE)**

Calculer une consigne moyenne pondérée:

```yaml
consigne: >
  {% set t_salon = states('input_select.mode_chauffage_salon')
     | regex_findall_index('\\d+\\.?\\d*') | float(19) %}
  {% set t_cuisine = states('input_select.mode_chauffage_cuisine')
     | regex_findall_index('\\d+\\.?\\d*') | float(19) %}
  {% set t_parents = states('input_select.mode_chauffage_parents')
     | regex_findall_index('\\d+\\.?\\d*') | float(19) %}

  {# Consigne = minimum des 3 pièces #}
  {{ [t_salon, t_cuisine, t_parents] | min }}
```

**PROBLÈME:** Trop complexe, nécessite refonte complète.

---

### PROBLÈME 3: Mode Présence incomplet

**État actuel:**
- ✅ Automation DÉPART fonctionne
- ✅ Automation RETOUR fonctionne
- ❌ Mais pas de logique de modification de consigne

**Ce qui manque:**

L'analyse `ANALYSE_MODE_PRESENCE.md` dit:
> Mode Présence = MODIFIER (pas DÉCIDER)
> Devrait ajuster la consigne selon présence

**Actuellement:**
- Départ → Passe en Hors-Gel (OK)
- Retour → Restaure (OK)
- **Mais ne modifie PAS la consigne pendant l'absence**

**Exemple attendu:**
```
Présent: Consigne 19°C
Absent 2h: Consigne 17°C (économie)
Absent >4h: Consigne 16°C (hors-gel)
Retour: Consigne 19°C
```

**Ce n'est PAS implémenté!**

---

## 🎯 PROPOSITION: SIMPLIFIER LE SYSTÈME

### Option A: Mode Manuel = Priorité 2 (RECOMMANDÉ)

**Ordre de priorité simplifié:**

```
1. MODE VACANCES → 16°C (bloque tout)
2. MODE MANUEL PAR PIÈCE → Température du curseur
3. MODE PLANNING HORAIRE → 4 créneaux/jour
4. MODE CHAUFFAGE GLOBAL → Défaut 18.5°C
5. PILOTAGE CHAUDIÈRE → Exécution
```

**Implémentation:**

Modifier l'automation chaudière pour lire les modes manuels:

```yaml
consigne: >
  {% if is_state('input_boolean.mode_vacance','on') %}
    16
  {% else %}
    {# Prendre le MINIMUM des 3 pièces #}
    {% set modes = [
      states('input_select.mode_chauffage_salon'),
      states('input_select.mode_chauffage_cuisine'),
      states('input_select.mode_chauffage_parents')
    ] %}

    {# Extraire températures et prendre le min #}
    {% set temperatures = [] %}
    {% for mode in modes %}
      {% set temp = mode | regex_findall_index('\\d+\\.?\\d*') | float(19) %}
      {% set temperatures = temperatures + [temp] %}
    {% endfor %}

    {{ temperatures | min }}
  {% endif %}
```

**Avantage:**
- ✅ Simple
- ✅ Mode Manuel fonctionne
- ✅ Respecte consignes par pièce

**Inconvénient:**
- ❌ Pièce la plus froide dicte pour toutes
- ❌ Pas de gestion individuelle TRV

---

### Option B: Mode Présence = Modificateur de consigne

**Logique:**

```
SI Présent (zone.home > 0):
  → Appliquer consigne normale (Manuel/Planning/Global)

SI Absent < 2h:
  → Consigne - 1°C (économie légère)

SI Absent 2-4h:
  → Consigne - 2°C (économie)

SI Absent > 4h:
  → 16°C (hors-gel)
```

**Implémentation:**

```yaml
consigne: >
  {# Calculer consigne de base #}
  {% set base_consigne = ... %}

  {# Modifier selon présence #}
  {% if states('zone.home') | int > 0 %}
    {{ base_consigne }}
  {% else %}
    {# Calculer durée absence #}
    {% set last_changed = states.zone.home.last_changed %}
    {% set duree = (now() - last_changed).total_seconds() / 3600 %}

    {% if duree < 2 %}
      {{ base_consigne - 1 }}
    {% elif duree < 4 %}
      {{ base_consigne - 2 }}
    {% else %}
      16
    {% endif %}
  {% endif %}
```

**Avantage:**
- ✅ Mode Présence complet
- ✅ Économie automatique
- ✅ Pas de conflit avec autres modes

**Inconvénient:**
- ❌ Complexe
- ❌ Nécessite refonte automation chaudière

---

### Option C: Supprimer Mode Présence, garder seulement Départ/Retour

**Logique:**

```
Mode Présence actuel = Seulement sauvegarde/restauration
→ PAS de modification de consigne
→ Renommer: "Automation Départ/Retour"
```

**Avantage:**
- ✅ Simple
- ✅ Fonctionne déjà
- ✅ Pas de confusion

**Inconvénient:**
- ❌ Pas d'économie automatique selon présence

---

## 🎯 MA RECOMMANDATION

### Phase 1: CORRIGER MODE MANUEL (PRIORITAIRE)

**Fichier à modifier:** `automation_chauffage_pilotage_chaudiere_corrigee.yaml`

**Changement:**

```yaml
consigne: >
  {% if is_state('input_boolean.mode_vacance','on') %}
    16
  {% else %}
    {# Prendre minimum des modes manuels #}
    {% set modes = [
      states('input_select.mode_chauffage_salon')
        | regex_findall_index('\\d+\\.?\\d*') | float(19),
      states('input_select.mode_chauffage_cuisine')
        | regex_findall_index('\\d+\\.?\\d*') | float(19)
    ] %}
    {{ modes | min }}
  {% endif %}
```

**Résultat:**
- Mode Manuel fonctionne
- Température = minimum des pièces
- Simple et efficace

### Phase 2: DOCUMENTER Mode Présence (actuel)

**Renommer:**
- "Mode Présence" → "Automation Départ/Retour"
- Clarifier: Sauvegarde/restauration uniquement
- PAS de modification de consigne

### Phase 3: CORRIGER Climatisations (si nécessaire)

**Vérifier:**
1. États remotes
2. Logs SmartIR
3. Reconfigurer si nécessaire

---

## 📋 PLAN D'ACTION

### Immédiat (aujourd'hui)

1. ✅ Modifier automation chaudière (consigne modes manuels)
2. ✅ Tester modes manuels fonctionnent
3. ✅ Vérifier états remotes Broadlink
4. ✅ Tester climatisations manuellement

### Court terme (cette semaine)

5. ✅ Documenter système final
6. ✅ Créer dashboard monitoring
7. ✅ Tests complets 24h

### Moyen terme (optionnel)

8. ⏳ Implémenter Mode Présence modificateur (si souhaité)
9. ⏳ Gestion TRV individuelle par pièce
10. ⏳ Automations climatisations

---

## ❓ QUESTIONS POUR TOI

### Question 1: Mode Manuel

**Veux-tu:**
- A) Minimum des 3 pièces (simple)
- B) Gestion TRV individuelle (complexe)

### Question 2: Mode Présence

**Veux-tu:**
- A) Garder simple (sauvegarde/restauration)
- B) Ajouter modificateur de consigne (économie)
- C) Supprimer complètement

### Question 3: Climatisations

**Priorité:**
- A) Corriger maintenant (urgent)
- B) Plus tard (pas urgent)

---

**Réponds à ces 3 questions pour que je crée les fichiers adaptés!** ✅
