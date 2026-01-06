# SYSTÈME HUMIDITÉ COMPLET - INSTALLÉ

**Date d'installation:** 21 décembre 2025
**Statut:** ✅ OPÉRATIONNEL

---

## 🎯 RÉSUMÉ EXÉCUTIF

**SYSTÈME COMPLET INSTALLÉ:**
- ✅ 12 automations humidité (2 par pièce × 6 pièces)
- ✅ 4 automations pilotage mises à jour (GAZ + 3 Clims)
- ✅ 6 helpers input_boolean (flags boost)
- ✅ 1 helper input_number (seuil global)
- ✅ Boost +2°C automatique si humidité > seuil

---

## 📋 AUTOMATIONS HUMIDITÉ INSTALLÉES (12)

### GAZ - 3 pièces × 2 automations = 6 automations

**Cuisine:**
1. ✅ Humidité > Seuil - Cuisine - On
2. ✅ Humidité < Seuil - Cuisine - Off

**Parents:**
3. ✅ Humidité > Seuil - Parents - On
4. ✅ Humidité < Seuil - Parents - Off

**Loann:**
5. ✅ Humidité > Seuil - Loann - On
6. ✅ Humidité < Seuil - Loann - Off

### CLIMATISATIONS - 3 pièces × 2 automations = 6 automations

**Salon:**
7. ✅ Humidité > Seuil - Salon - On
8. ✅ Humidité < Seuil - Salon - Off

**Axel:**
9. ✅ Humidité > Seuil - Axel - On
10. ✅ Humidité < Seuil - Axel - Off

**Maeva:**
11. ✅ Humidité > Seuil - Maeva - On
12. ✅ Humidité < Seuil - Maeva - Off

---

## 🔧 AUTOMATIONS PILOTAGE MISES À JOUR (4)

**1. Chauffage - Pilotage Chaudiere GAZ**
- Version: v5 (avec boost humidité 3 pièces)
- Boost si: `mode_humidite_cuisine` OR `mode_humidite_parents` OR `mode_humidite_loann` = ON
- Logique: Si au moins 1 pièce GAZ a boost → +2°C consigne globale

**2. Climatisation - Pilotage Salon**
- Version: v4 (avec boost humidité)
- Boost si: `mode_humidite_salon` = ON

**3. Climatisation - Pilotage Axel**
- Version: v4 (avec boost humidité)
- Boost si: `mode_humidite_axel` = ON

**4. Climatisation - Pilotage Maeva**
- Version: v4 (avec boost humidité)
- Boost si: `mode_humidite_maeva` = ON

---

## 🎛️ HELPERS CONFIGURÉS

### Input Boolean (Flags Boost) - 6 pièces
- ✅ `input_boolean.mode_humidite_cuisine`
- ✅ `input_boolean.mode_humidite_parents`
- ✅ `input_boolean.mode_humidite_loann`
- ✅ `input_boolean.mode_humidite_salon`
- ✅ `input_boolean.mode_humidite_axel`
- ✅ `input_boolean.mode_humidite_maeva`

### Input Number (Seuil Global)
- ✅ `input_number.seuil_humidite_chauffage` = 61%

---

## 📡 CAPTEURS HUMIDITÉ UTILISÉS

- ✅ `sensor.th_cuisine_humidity`
- ✅ `sensor.th_parents_humidity`
- ✅ `sensor.th_loann_humidity`
- ✅ `sensor.th_salon_humidity`
- ✅ `sensor.th_axel_humidity`
- ✅ `sensor.th_maeva_humidity`

---

## 🔄 LOGIQUE DU SYSTÈME (6 NIVEAUX)

```
1️⃣ MODE VACANCES
   → Force 16°C GAZ + OFF Clims
   → BLOQUE TOUT
   → input_boolean.mode_vacance

2️⃣ MODE HUMIDITÉ PAR PIÈCE ⭐ INSTALLÉ
   → SI humidité > seuil pendant 2 min
   → Active input_boolean.mode_humidite_*
   → Boost consigne +2°C
   → Désactive si humidité < seuil pendant 5 min

3️⃣ MODE MANUEL PAR PIÈCE
   → Contrôle utilisateur direct
   → GAZ: MIN(Cuisine, Parents, Loann)
   → Clims: Individuelles (Salon, Axel, Maeva)
   → input_select.mode_chauffage_*

4️⃣ MODE PLANNING HORAIRE
   → Non implémenté actuellement
   → Actif si modes = MODEJOUR

5️⃣ MODE CHAUFFAGE GLOBAL
   → Fallback: 18.5°C
   → sensor.mode_chauffage_global

6️⃣ PILOTAGE (Exécution)
   → Cycle: 3 min
   → Seuils: ±0.5°C
   → Zone morte = OFF
```

---

## 💡 EXEMPLES CONCRETS

### Exemple 1: Cuisson vapeur Cuisine

```
ÉTAT INITIAL:
- Mode manuel Cuisine: Eco (18°C)
- Humidité Cuisine: 45%
- Seuil: 61%
- mode_humidite_cuisine: OFF
- Chaudière: selon température

PENDANT CUISSON (vapeur):
T+0 min:  Humidité monte à 70%
T+2 min:  Automation "Humidité > Seuil - Cuisine - On" déclenche
          → mode_humidite_cuisine = ON ✅

T+3 min:  Automation pilotage GAZ s'exécute
          → consigne_base = 18°C (Eco)
          → boost_humidite = ON (cuisine OR parents OR loann)
          → consigne_finale = 18 + 2 = 20°C
          → Si delta >= 0.5°C → ALLUME chaudière

APRÈS CUISSON:
T+15 min: Humidité descend à 55%
T+20 min: Automation "Humidité < Seuil - Cuisine - Off" déclenche
          → mode_humidite_cuisine = OFF
T+23 min: Automation pilotage GAZ s'exécute
          → consigne_finale = 18°C (retour normal)
```

### Exemple 2: Douche Parents (propagation humidité)

```
ÉTAT INITIAL:
- Mode manuel Parents: Confort (19°C)
- Humidité Parents: 50%
- Seuil: 61%
- mode_humidite_parents: OFF

APRÈS DOUCHE:
T+0 min:  Humidité monte à 75%
T+2 min:  Automation "Humidité > Seuil - Parents - On" déclenche
          → mode_humidite_parents = ON ✅

T+3 min:  Automation pilotage GAZ s'exécute
          → consigne_base = MIN(Cuisine, Parents, Loann) = 19°C
          → boost_humidite = ON (parents actif)
          → consigne_finale = 19 + 2 = 21°C
          → Chaudière chauffe à 21°C

T+15 min: Humidité descend à 55%
T+20 min: Automation "Humidité < Seuil - Parents - Off" déclenche
          → mode_humidite_parents = OFF
          → Retour consigne normale 19°C
```

### Exemple 3: Climatisation Salon après douche

```
ÉTAT INITIAL:
- Mode manuel Salon: Confort3 (21°C)
- Humidité Salon: 50%
- mode_humidite_salon: OFF

SI HUMIDITÉ MONTE:
T+0 min:  Humidité monte à 70% (propagation)
T+2 min:  Automation "Humidité > Seuil - Salon - On" déclenche
          → mode_humidite_salon = ON ✅

T+3 min:  Automation pilotage Salon s'exécute
          → consigne_base = 21°C (Confort3)
          → boost_humidite = ON
          → consigne_finale = 21 + 2 = 23°C
          → Climatisation chauffe à 23°C

RETOUR NORMAL:
T+15 min: Humidité < 61%
T+20 min: mode_humidite_salon = OFF
          → Retour à 21°C
```

---

## 🧪 TESTS DE VALIDATION

### Test 1: Vérifier automations actives

Dans **Automations et scènes**, tu dois voir:

**Pilotage (4):**
- ✅ Chauffage - Pilotage Chaudiere GAZ
- ✅ Climatisation - Pilotage Salon
- ✅ Climatisation - Pilotage Axel
- ✅ Climatisation - Pilotage Maeva

**Humidité (12):**
- ✅ 2 automations Cuisine
- ✅ 2 automations Parents
- ✅ 2 automations Loann
- ✅ 2 automations Salon
- ✅ 2 automations Axel
- ✅ 2 automations Maeva

---

### Test 2: Simulation boost humidité

**Pour tester le système sans attendre:**

1. **Baisser temporairement le seuil:**
   - Aller dans Helpers → `input_number.seuil_humidite_chauffage`
   - Mettre à 50% (au lieu de 61%)
   - Attendre 2 minutes
   - Vérifier que les boosts s'activent automatiquement

2. **Vérifier les flags:**
   - Aller dans États des développeurs
   - Chercher `input_boolean.mode_humidite_*`
   - Vérifier que certains passent à ON

3. **Vérifier consignes:**
   - Si sensor "Consigne GAZ Actuelle" créé → vérifier +2°C
   - Vérifier que chaudière/clims réagissent

4. **Remonter le seuil:**
   - Remettre `seuil_humidite_chauffage` à 61%
   - Attendre 5 minutes
   - Vérifier que les boosts se désactivent

---

## 📊 DASHBOARD RECOMMANDÉ

Pour monitorer le système humidité:

```yaml
type: vertical-stack
cards:
  - type: entities
    title: 🎯 Seuil Humidité
    entities:
      - entity: input_number.seuil_humidite_chauffage
        name: Seuil global

  - type: entities
    title: 💧 Humidité Mesurée
    entities:
      - entity: sensor.th_cuisine_humidity
        name: Cuisine
      - entity: sensor.th_parents_humidity
        name: Parents
      - entity: sensor.th_loann_humidity
        name: Loann
      - entity: sensor.th_salon_humidity
        name: Salon
      - entity: sensor.th_axel_humidity
        name: Axel
      - entity: sensor.th_maeva_humidity
        name: Maeva

  - type: entities
    title: 🚀 Boost Actifs (+2°C)
    entities:
      - entity: input_boolean.mode_humidite_cuisine
        name: Cuisine
      - entity: input_boolean.mode_humidite_parents
        name: Parents
      - entity: input_boolean.mode_humidite_loann
        name: Loann
      - entity: input_boolean.mode_humidite_salon
        name: Salon
      - entity: input_boolean.mode_humidite_axel
        name: Axel
      - entity: input_boolean.mode_humidite_maeva
        name: Maeva
```

---

## ✅ BÉNÉFICES DU SYSTÈME

**Confort:**
- 🌡️ Température optimale dans chaque pièce
- 💧 Humidité contrôlée automatiquement
- 🚀 Boost +2°C intelligent si besoin

**Économies:**
- 💰 Zone morte = OFF (économie)
- ⚡ Chauffage uniquement si nécessaire
- 🎯 Consigne adaptée automatiquement

**Contrôle:**
- 🎛️ Mode manuel prioritaire
- 🏖️ Protection vacances (hors-gel 16°C)
- 🔍 Monitoring complet possible

---

## 🎉 SYSTÈME COMPLET ET OPÉRATIONNEL !

**Le système humidité est maintenant actif sur les 6 pièces.**

Toutes les automations fonctionnent en arrière-plan et s'adapteront automatiquement aux variations d'humidité.

**Prochaines actions recommandées:**
1. Créer le dashboard de monitoring
2. Observer le comportement pendant 1 semaine
3. Ajuster le seuil si besoin (61% actuellement)
4. Considérer des seuils différents par pièce si nécessaire

---

**Installation complétée avec succès !** 🚀
