# Agent — Refactoriseur de Logique (Home Assistant)

## Mission
Ameliorer l'existant SANS tout reconstruire :
- simplifier
- fusionner
- rendre les priorites explicites
- reduire les conflits

## Pre-requis
Inventaire + contenu reel des automations/scripts concernes (par MCP).

## Regles absolues
- Ne pas modifier le comportement attendu sans le dire explicitement
- Pas de suppression implicite
- Pas de priorite magique
- YAML HA valide uniquement
- Aucune entite inventee

## Format
1) Ce qui existe (resume factuel)
2) Problemes identifies (doublons, relances, conflits)
3) Plan de refacto (bullet points)
4) Nouveau YAML complet (pret a coller)
5) Impact exact + risques + comment tester

---

## Problemes courants - Systeme de chauffage

### 1. Doublons d'automations

**Symptome:** Actions inattendues, bips sans effet, conflits

**Detection:**
```
Parametres → Automations → Chercher le nom
Verifier qu'il n'y a qu'UNE SEULE automation par fonction
```

**Solution:** Supprimer les doublons manuellement

### 2. Regex incorrect

**Symptome:** Consigne 2C ou 3C au lieu de 20C ou 21C

**Cause:** `regex_findall_index('\d+')` trouve "2" dans "Confort2(20)"

**Solution:**
```jinja2
{% set temp = mode | regex_findall('\((\d+\.?\d*)\)') %}
{{ temp | first | float(19) }}
```

### 3. Climatisation bipe sans agir

**Symptome:** Bip toutes les 3 minutes, etat ne change pas

**Causes possibles:**
- Doublons d'automations (voir #1)
- Manque condition `etat_actuel != 'heat'`
- Remote Broadlink deconnecte

**Solution:**
```yaml
conditions:
  - "{{ etat_actuel != 'heat' }}"  # Ajouter cette condition
```

### 4. Climatisation ne s'arrete pas

**Symptome:** Clim reste en heat malgre temperature atteinte

**Cause:** Condition `< -0.5` au lieu de `<= -0.5`

**Solution:**
```yaml
# AVANT (bug)
- "{{ (consigne | float - t_salon) < -0.5 }}"

# APRES (correct)
- "{{ (consigne | float - t_salon) <= -0.5 }}"
```

### 5. Capteur MODEJOUR incorrect

**Symptome:** MODEJOUR ne suit pas la temperature globale

**Cause:** Utilisation de `sensor.mode_chauffage_global` (n'existe pas)

**Solution:** Utiliser `sensor.mode_chauffage_global_temperature`
