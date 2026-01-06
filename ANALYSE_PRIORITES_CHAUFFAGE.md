# ANALYSE ORDRE DE PRIORITÉ - MODES CHAUFFAGE

## MODES IDENTIFIÉS DANS TON SYSTÈME

D'après l'analyse des automations (`automations.yaml`), voici les différents modes de chauffage:

### 1. **MODE VACANCES** (Priorité 1 - LA PLUS HAUTE)
**Entité:** `input_boolean.mode_vacance`

**Impact:**
- Bloque TOUTES les automations de planning horaire
- Force la consigne à **16°C** (hors-gel) dans:
  - `Chauffage - Pilotage Chaudière GAZ` (ligne 71-73)
  - `Chauffage - Pilotage Simple Climatisations` (ligne 111-113)

**Condition de blocage:** (ligne 33-35)
```yaml
conditions:
  - condition: state
    entity_id: input_boolean.mode_vacance
    state: 'off'  # Planning horaire ne fonctionne QUE si mode vacances OFF
```

**Priorité:** ABSOLUE - Quand actif, écrase TOUT

---

### 2. **MODE PLANNING HORAIRE** (Priorité 2)
**Automation:** `Chauffage - Planning Automatique Horaire` (ligne 17)

**Déclencheurs:** 4 horaires par jour
- **05:45** → Confort matin (19°C)
- **08:00** → Éco journée (18.5°C)
- **17:00** → Confort soir (19°C)
- **22:30** → Hors-gel nuit (16°C)

**Actions:**
- Désactive le mode nuit
- Définit les consignes des 3 TRV (vannes thermostatiques)
- Allume le thermostat chaudière

**Condition:** Ne fonctionne QUE si `mode_vacance = OFF`

---

### 3. **MODE CHAUFFAGE GLOBAL** (Priorité 3)
**Entité:** `sensor.mode_chauffage_global`

**Utilisé par:**
- `Chauffage - Pilotage Chaudière GAZ` (ligne 72)
- `Chauffage - Pilotage Simple Climatisations` (ligne 112)

**Logique:**
```yaml
consigne: "{% if is_state('input_boolean.mode_vacance','on') %}16 {% else %}
  {{ states('sensor.mode_chauffage_global')
     | regex_findall_index('\\d+\\.?\\d*')
     | float(18.5) }}
{% endif %}"
```

**Signification:**
- Si mode vacances ON → 16°C
- Sinon → Lit la température depuis `sensor.mode_chauffage_global`
- Par défaut si erreur → 18.5°C

**Note:** Ce sensor semble être un agrégat ou calculé. À vérifier dans `configuration.yaml` ou `sensors.yaml`.

---

### 4. **MODES MANUELS PAR PIÈCE**
**Entités présumées:**
- `input_select.mode_chauffage_salon`
- `input_select.mode_chauffage_cuisine`
- `input_select.mode_chauffage_chambre` (?)

**État actuel:** Non trouvés dans `automations.yaml` actuellement ouvert

**À vérifier:**
- Sont-ils utilisés uniquement via le dashboard?
- Y a-t-il des automations qui les lisent?
- Sont-ils prioritaires sur le mode global?

---

### 5. **MODE PRÉSENCE**
**Automation trouvée:** `Chauffage Auto - Présence` (ligne 577)

```yaml
triggers:
  - entity_id: zone.home
    to: '0'  # Quand zone.home passe à 0 (plus personne)
    trigger: state
actions:
  - data:
      entity_id: input_select.mode_chauffage_salon
      option: Eco2(18.5)
    action: input_select.select_option
```

**Logique:**
- Quand tout le monde part (zone.home = 0)
- Passe le salon en mode Éco (18.5°C)

**Priorité:** Semble agir UNIQUEMENT sur le salon

**Question:** Que se passe-t-il au retour? Y a-t-il une automation inverse?

---

### 6. **MODE NUIT**
**Entité:** `input_boolean.mode_nuit`

**Usage:**
- Désactivé par l'automation de planning horaire (ligne 38-40)
- Probablement utilisé pour ajuster les consignes la nuit

**À vérifier:**
- Où est-il activé?
- Quelle automation le lit?

---

### 7. **MODE HUMIDITÉ CUISINE**
**Entités:**
- `input_boolean.mode_humidite_cuisine`
- `input_number.seuil_humidite_chauffage`

**Automations:**
- `Humidité > Seuil - Cuisine` (ligne 114)
- `Humidité < Seuil - Cuisine` (ligne 125)

**Logique:**
- Si humidité > seuil pendant 2 min → Active mode humidité
- Si humidité < seuil pendant 5 min → Désactive mode humidité

**Impact:** À déterminer (probablement force ventilation ou ajuste consigne)

---

## ORDRE DE PRIORITÉ ACTUEL (DÉDUCTION)

```
1. MODE VACANCES (input_boolean.mode_vacance)
   └─> Si ON: Force 16°C partout, bloque tout le reste

2. MODE PLANNING HORAIRE (si vacances OFF)
   └─> Définit consignes des TRV selon horaire
   └─> Désactive mode nuit

3. MODE CHAUFFAGE GLOBAL (sensor.mode_chauffage_global)
   └─> Utilisé par pilotage chaudière/clims toutes les 3-5 min
   └─> Lu si vacances OFF

4. MODES MANUELS PAR PIÈCE (input_select.mode_chauffage_*)
   └─> Probablement prioritaire sur global pour la pièce concernée
   └─> Modifié par automation présence

5. MODE PRÉSENCE (zone.home)
   └─> Ajuste salon en Éco si absence

6. MODE HUMIDITÉ CUISINE
   └─> Active/désactive selon seuil
```

---

## SEUILS DE TEMPÉRATURE ACTUELS

### Dans `Chauffage - Pilotage Chaudière GAZ` (ligne 77-80)

**Actuellement:**
```yaml
need_heat: "{{ (consigne - t_cuisine) >= 1
   or (consigne - t_parents) >= 1
   or (consigne - t_loann) >= 1 }}"

too_hot: "{{ (consigne - t_cuisine) <= -1
   and (consigne - t_parents) <= -1
   and (consigne - t_loann) <= -1 }}"
```

**Signification:**
- **Allume la chaudière** si AU MOINS UNE pièce est à 1°C ou plus en dessous de la consigne
- **Éteint la chaudière** si TOUTES les pièces sont à 1°C ou plus au-dessus de la consigne
- **Sinon:** Éteint par défaut (ligne 96-101) ← **ATTENTION:** Default = OFF!

**Problème identifié:**
Le `default` éteint la chaudière même si les températures sont proches de la consigne!

**Exemple:**
- Consigne: 19°C
- Cuisine: 18.8°C (delta = +0.2°C)
- Parents: 18.7°C (delta = +0.3°C)
- Loann: 18.6°C (delta = +0.4°C)

Résultat actuel:
- `need_heat = False` (aucune pièce à -1°C)
- `too_hot = False` (aucune pièce à +1°C)
- → **Default = OFF** → Chaudière éteinte!

**Impact:** Températures oscillent autour de la consigne sans chauffage

---

## CORRECTIONS PROPOSÉES

### 1. Ajuster les seuils de ±1°C à ±0.5°C

**Avant:**
```yaml
need_heat: "{{ (consigne - t_cuisine) >= 1
   or (consigne - t_parents) >= 1
   or (consigne - t_loann) >= 1 }}"

too_hot: "{{ (consigne - t_cuisine) <= -1
   and (consigne - t_parents) <= -1
   and (consigne - t_loann) <= -1 }}"
```

**Après:**
```yaml
need_heat: "{{ (consigne - t_cuisine) >= 0.5
   or (consigne - t_parents) >= 0.5
   or (consigne - t_loann) >= 0.5 }}"

too_hot: "{{ (consigne - t_cuisine) <= -0.5
   and (consigne - t_parents) <= -0.5
   and (consigne - t_loann) <= -0.5 }}"
```

**Avantages:**
- Réactivité 2x plus rapide
- Températures plus stables
- Moins d'oscillations

### 2. Corriger la logique default

**Problème:** Le `default` éteint la chaudière dans la zone morte (entre -0.5°C et +0.5°C)

**Solution proposée:**

**Option A: Maintenir état actuel**
```yaml
default:
  - action: script.log_chauffage
    data:
      message: "Zone morte - Maintien état chaudière"
  # Ne rien faire, laisse la chaudière dans son état actuel
```

**Option B: Hystérésis intelligente**
```yaml
default:
  - choose:
      - conditions:
          - condition: state
            entity_id: switch.thermostat
            state: 'on'
        sequence:
          - condition: template
            value_template: >
              {{ (consigne - t_cuisine) < -0.2
                 and (consigne - t_parents) < -0.2
                 and (consigne - t_loann) < -0.2 }}
          - action: switch.turn_off
            target:
              entity_id: switch.thermostat
```

**Recommandation:** Option A (plus simple et sûr)

---

## ORDRE DE PRIORITÉ RECOMMANDÉ

### Hiérarchie claire:

```
PRIORITÉ 1 - MODE VACANCES
  ↓ (si OFF)
PRIORITÉ 2 - MODE MANUEL PAR PIÈCE
  ↓ (si non défini)
PRIORITÉ 3 - MODE PRÉSENCE
  ↓ (si présent)
PRIORITÉ 4 - MODE PLANNING HORAIRE
  ↓ (définit consignes par défaut)
PRIORITÉ 5 - MODE CHAUFFAGE GLOBAL
  ↓ (agrège ou calcule consigne finale)
PRIORITÉ 6 - PILOTAGE CHAUDIÈRE/CLIMS
  ↓ (exécute toutes les 3-5 min)
```

### Logique de calcul de consigne:

```python
if mode_vacance == ON:
    consigne = 16

elif mode_manuel_piece existe:
    consigne = mode_manuel_piece

elif presence == absent:
    consigne = 18.5  # Éco

elif planning_horaire_actif:
    consigne = planning_horaire  # 16/18.5/19 selon horaire

else:
    consigne = mode_chauffage_global
```

---

## FICHIERS À CRÉER

Je vais créer:

1. **`automations_chauffage_corriges.yaml`**
   - Seuils ajustés à ±0.5°C
   - Logique default corrigée
   - Commentaires explicatifs

2. **`GUIDE_PRIORITES_CHAUFFAGE.md`**
   - Ordre de priorité détaillé
   - Arbres de décision
   - Exemples concrets

3. **`template_sensor_mode_global.yaml`**
   - Sensor calculé pour mode chauffage global
   - Intègre la logique de priorité

4. **`lovelace_modes_chauffage.yaml`**
   - Dashboard de contrôle des modes
   - Vue d'ensemble priorités
   - Debugging

---

## QUESTIONS À CLARIFIER

1. **Mode manuel par pièce:**
   - Comment sont-ils utilisés actuellement?
   - Sont-ils prioritaires sur le planning horaire?
   - Où sont-ils définis (dashboard uniquement)?

2. **Sensor mode_chauffage_global:**
   - Comment est-il calculé?
   - Existe-t-il dans `configuration.yaml`?
   - Ou est-ce un helper `input_number`?

3. **Mode présence:**
   - Y a-t-il une automation pour le retour?
   - Agit-elle sur toutes les pièces ou juste salon?

4. **Mode nuit:**
   - Où est-il activé?
   - Quelle automation le lit?
   - Quelle est son action?

---

## PROCHAINES ÉTAPES

1. ✅ Créer les fichiers corrigés avec seuils ±0.5°C
2. ✅ Documenter l'ordre de priorité complet
3. ⏳ Vérifier `configuration.yaml` pour `sensor.mode_chauffage_global`
4. ⏳ Tester les automations corrigées
5. ⏳ Créer dashboard de debugging
