# Arbre de Décision - Optimisation Reporting Capteurs Zigbee

**Date**: 2025-12-18
**Objectif**: Vous guider vers la meilleure solution pour votre situation

---

## DIAGRAMME DE DÉCISION

```
┌─────────────────────────────────────────────────────────────┐
│  PROBLÈME: Capteurs température/humidité lents à se mettre  │
│  à jour (> 10 minutes)                                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
          ┌───────────────────────┐
          │  ÉTAPE 1: DIAGNOSTIC  │
          └───────────┬───────────┘
                      │
      ┌───────────────┴───────────────┐
      │                               │
      ▼                               ▼
┌─────────────┐               ┌─────────────┐
│ Batterie OK │               │ Batterie    │
│   (> 20%)   │               │   Faible    │
│     ✅      │               │   (< 20%)   │
└──────┬──────┘               └──────┬──────┘
       │                             │
       │                             ▼
       │                      ┌──────────────┐
       │                      │   REMPLACER  │
       │                      │    LA PILE   │
       │                      └──────┬───────┘
       │                             │
       │                             │
       └─────────────┬───────────────┘
                     │
                     ▼
              ┌─────────────┐
              │  LQI Check  │
              └──────┬──────┘
                     │
      ┌──────────────┴──────────────┐
      │                             │
      ▼                             ▼
┌─────────────┐               ┌─────────────┐
│   LQI OK    │               │  LQI Faible │
│  (> 50)     │               │   (< 50)    │
│     ✅      │               │             │
└──────┬──────┘               └──────┬──────┘
       │                             │
       │                             ▼
       │                      ┌──────────────┐
       │                      │  RAPPROCHER  │
       │                      │   ROUTEUR    │
       │                      │   ou AJOUTER │
       │                      │  PRISE MESH  │
       │                      └──────┬───────┘
       │                             │
       └─────────────┬───────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 2: IDENTIFIER LE MODÈLE DE CAPTEUR                  │
└─────────────────────┬──────────────────────────────────────┘
                      │
      ┌───────────────┼───────────────┐
      │               │               │
      ▼               ▼               ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│    Tuya     │ │   Sonoff    │ │ Xiaomi /    │
│   TS0201    │ │  SNZB-02    │ │   Aqara     │
│             │ │             │ │             │
│  Support:   │ │  Support:   │ │  Support:   │
│     ✅      │ │     ⚠️      │ │     ❌      │
└──────┬──────┘ └──────┬──────┘ └──────┬──────┘
       │               │               │
       │               │               │
       │               │               │
       ▼               ▼               ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  MÉTHODE 1  │ │  TESTER     │ │  MÉTHODE 2  │
│  Reconfigu- │ │  MÉTHODE 1  │ │   Polling   │
│   ration    │ │             │ │    Actif    │
│   Zigbee    │ │   Si échec  │ │             │
│             │ │      ↓      │ │   (DIRECT)  │
│             │ │  MÉTHODE 2  │ │             │
└──────┬──────┘ └──────┬──────┘ └──────┬──────┘
       │               │               │
       └───────────────┴───────────────┘
                       │
                       ▼
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 3: APPLICATION                                       │
└─────────────────────┬──────────────────────────────────────┘
                      │
      ┌───────────────┴───────────────┐
      │                               │
      ▼                               ▼
┌─────────────────────────┐   ┌─────────────────────────┐
│     MÉTHODE 1           │   │     MÉTHODE 2           │
│  Reconfiguration Zigbee │   │    Polling Actif        │
├─────────────────────────┤   ├─────────────────────────┤
│ 1. Récupérer IEEE addr  │   │ 1. Créer automation     │
│ 2. Éditer config YAML   │   │ 2. Time pattern: /3     │
│ 3. Copier device_options│   │ 3. MQTT publish x7      │
│ 4. Redémarrer Z2M       │   │ 4. Recharger automations│
│ 5. Vérifier logs        │   │ 5. Activer automation   │
└──────────┬──────────────┘   └──────────┬──────────────┘
           │                             │
           │    ┌────────────────┐       │
           └───►│  VÉRIFICATION  │◄──────┘
                └────────┬───────┘
                         │
          ┌──────────────┴──────────────┐
          │                             │
          ▼                             ▼
    ┌──────────┐                  ┌──────────┐
    │  SUCCÈS  │                  │  ÉCHEC   │
    │  "Success│                  │ "Device  │
    │   fully  │                  │  does not│
    │  config" │                  │  support"│
    └────┬─────┘                  └────┬─────┘
         │                             │
         │                             ▼
         │                      ┌──────────────┐
         │                      │ PASSER À     │
         │                      │  MÉTHODE 2   │
         │                      └──────┬───────┘
         │                             │
         └─────────────┬───────────────┘
                       │
                       ▼
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 4: VALIDATION                                        │
├─────────────────────────────────────────────────────────────┤
│  • Test rapide (30s): Forcer update → Vérifier             │
│  • Test complet (30min): Script validation automatique     │
│  • Critères: Intervalle ≤ 3 min, LQI OK, Batterie OK       │
└─────────────────────┬──────────────────────────────────────┘
                      │
      ┌───────────────┴───────────────┐
      │                               │
      ▼                               ▼
┌─────────────┐               ┌─────────────┐
│  VALIDATION │               │  VALIDATION │
│    RÉUSSIE  │               │   ÉCHOUÉE   │
│             │               │             │
│ Intervalle  │               │ Intervalle  │
│   ≤ 3 min   │               │   > 3 min   │
│     ✅      │               │     ❌      │
└──────┬──────┘               └──────┬──────┘
       │                             │
       ▼                             ▼
┌──────────────┐             ┌──────────────────┐
│   TERMINÉ    │             │   DÉPANNAGE      │
│              │             │                  │
│  Surveiller  │             │ • Vérifier LQI   │
│  batterie    │             │ • Vérifier logs  │
│  1 semaine   │             │ • Ajuster config │
└──────────────┘             └──────────────────┘
```

---

## GUIDE DE DÉCISION RAPIDE

### Question 1: Quel est le modèle de vos capteurs ?

| Modèle | Fabricant | Méthode Recommandée |
|--------|-----------|---------------------|
| TS0201 | Tuya | ✅ Méthode 1 (Reconfiguration) |
| SNZB-02 / SNZB-02P | Sonoff | ⚠️ Tester Méthode 1 → Méthode 2 si échec |
| WSDCGQ11LM | Aqara | ❌ Méthode 2 (Polling) uniquement |
| WSDCGQ01LM | Xiaomi | ❌ Méthode 2 (Polling) uniquement |
| STS-IRM-250 | SmartThings | ✅ Méthode 1 (Reconfiguration) |
| Autre / Inconnu | - | ⚠️ Tester Méthode 1 → Méthode 2 si échec |

### Question 2: Quel est votre niveau technique ?

| Niveau | Méthode Recommandée | Temps |
|--------|---------------------|-------|
| 🟢 Débutant | Méthode 2 (Polling) | 15 min |
| 🟡 Intermédiaire | Méthode 1, sinon Méthode 2 | 30 min |
| 🔴 Avancé | Méthode 1 + personnalisation | 60 min |

### Question 3: Quelle est votre priorité ?

| Priorité | Méthode | Résultat |
|----------|---------|----------|
| Réactivité maximale | Méthode 1 | 1-3 min |
| Facilité de mise en œuvre | Méthode 2 | 3-5 min |
| Économie de batterie | Méthode 2 (intervalle 5 min) | 8-10 mois autonomie |
| Équilibre | Méthode 1 (intervalle 3 min) | 6-8 mois autonomie |

---

## SCÉNARIOS D'UTILISATION

### Scénario A: Maison avec 7 Capteurs Tuya

**Contexte**:
- 7 capteurs TS0201 (Tuya)
- Batterie > 30%
- LQI > 100
- Niveau technique: Intermédiaire

**Recommandation**:
1. ✅ Utiliser Méthode 1 (Reconfiguration Zigbee)
2. Configuration `max_interval: 180` (3 minutes)
3. Impact batterie acceptable (6-8 mois)

**Fichiers à consulter**:
- `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` (Méthode 1)
- `zigbee2mqtt_reporting_optimization.yaml`

**Temps de mise en œuvre**: 30 minutes

---

### Scénario B: Maison avec Capteurs Xiaomi/Aqara

**Contexte**:
- 7 capteurs WSDCGQ11LM (Aqara)
- Batterie > 25%
- LQI variable (50-150)
- Niveau technique: Débutant

**Recommandation**:
1. ✅ Utiliser Méthode 2 (Polling Actif)
2. Automation avec intervalle `/3` (toutes les 3 minutes)
3. Impact batterie minimal

**Fichiers à consulter**:
- `QUICK_REFERENCE_OPTIMISATION_ZIGBEE.md`
- `EXEMPLES_MCP_OPTIMISATION.md` (Scénario 4)

**Temps de mise en œuvre**: 15 minutes

---

### Scénario C: Mix de Capteurs (Tuya + Xiaomi)

**Contexte**:
- 3 capteurs Tuya TS0201
- 4 capteurs Xiaomi WSDCGQ01LM
- Batterie > 20%
- LQI > 80
- Niveau technique: Avancé

**Recommandation**:
1. Méthode 1 pour les Tuya uniquement
2. Méthode 2 pour tous les capteurs (dont Xiaomi)
3. Double approche pour redondance

**Fichiers à consulter**:
- `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` (Les 2 méthodes)
- `zigbee2mqtt_reporting_optimization.yaml`

**Temps de mise en œuvre**: 45 minutes

---

### Scénario D: Capteurs avec Batterie Faible

**Contexte**:
- 7 capteurs Sonoff SNZB-02
- Batterie < 15% (plusieurs capteurs)
- LQI > 100
- Niveau technique: Intermédiaire

**Recommandation**:
1. ⚠️ REMPLACER LES PILES EN PRIORITÉ
2. Puis appliquer Méthode 1 ou 2
3. Ajuster intervalles pour économie: `max_interval: 300` (5 min)

**Fichiers à consulter**:
- `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` (Section Dépannage)

**Temps de mise en œuvre**: 45 minutes (incluant remplacement piles)

---

### Scénario E: LQI Faible (< 50)

**Contexte**:
- 7 capteurs Tuya TS0201
- Batterie > 30%
- LQI < 50 (plusieurs capteurs)
- 2 routeurs mesh installés
- Niveau technique: Intermédiaire

**Recommandation**:
1. ⚠️ AMÉLIORER LE RÉSEAU EN PRIORITÉ
   - Rapprocher les capteurs des routeurs
   - Ajouter des prises mesh intermédiaires
2. Tester LQI après amélioration
3. Puis appliquer Méthode 1

**Fichiers à consulter**:
- `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` (Annexe C: Valeurs LQI)
- `NETWORK_MAP_TEMPLATE.md`

**Temps de mise en œuvre**: 60 minutes (incluant optimisation réseau)

---

## MATRICE DE DÉCISION

### Choisir entre Méthode 1 et Méthode 2

|  | Méthode 1 (Reconfiguration) | Méthode 2 (Polling) |
|---|----------------------------|-------------------|
| **Compatibilité** | ⚠️ Variable | ✅ Universelle |
| **Réactivité** | ⭐⭐⭐⭐⭐ (1-3 min) | ⭐⭐⭐⭐ (3-5 min) |
| **Facilité** | ⭐⭐⭐ (Moyenne) | ⭐⭐⭐⭐⭐ (Facile) |
| **Impact Batterie** | ⭐⭐⭐ (6-8 mois) | ⭐⭐⭐⭐ (8-10 mois) |
| **Maintenance** | ⭐⭐⭐⭐⭐ (Aucune) | ⭐⭐⭐⭐ (Automation) |
| **Fiabilité** | ⭐⭐⭐⭐ (Si supporté) | ⭐⭐⭐⭐⭐ (100%) |

### Score Total par Profil

| Profil | Méthode 1 | Méthode 2 | Recommandation |
|--------|-----------|-----------|----------------|
| Débutant | 15/25 | 22/25 | **Méthode 2** |
| Intermédiaire | 20/25 | 22/25 | Méthode 2 ou 1 si compatible |
| Avancé | 20/25 | 22/25 | Tester 1, sinon 2 |
| Capteurs compatibles | 23/25 | 22/25 | **Méthode 1** |
| Capteurs non compatibles | N/A | 22/25 | **Méthode 2** |

---

## CHECKLIST DE DÉCISION

### Avant de Choisir

Répondez à ces questions:

1. **Modèle de capteur**:
   - [ ] Je connais le modèle exact
   - [ ] C'est un Tuya / SmartThings → Méthode 1
   - [ ] C'est un Xiaomi / Aqara → Méthode 2
   - [ ] C'est un Sonoff → Tester Méthode 1

2. **État des capteurs**:
   - [ ] Batterie > 20% (tous)
   - [ ] LQI > 50 (tous)
   - [ ] État: Available (tous)

3. **Niveau technique**:
   - [ ] Débutant → Méthode 2 recommandée
   - [ ] Intermédiaire → Les 2 méthodes OK
   - [ ] Avancé → Méthode 1 préférée

4. **Temps disponible**:
   - [ ] 15 minutes → Méthode 2
   - [ ] 30-60 minutes → Méthode 1 ou 2
   - [ ] Illimité → Méthode 1 + personnalisation

### Décision Finale

Cochez votre choix:

- [ ] **Méthode 1**: Reconfiguration Zigbee
  - Fichier: `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` (p.20-35)
  - Configuration: `zigbee2mqtt_reporting_optimization.yaml`

- [ ] **Méthode 2**: Polling Actif
  - Fichier: `QUICK_REFERENCE_OPTIMISATION_ZIGBEE.md`
  - Automation: `zigbee2mqtt_reporting_optimization.yaml` (section automation)

- [ ] **Les 2 Méthodes**: Approche combinée
  - Méthode 1 pour capteurs compatibles
  - Méthode 2 pour tous (redondance)

---

## DIAGRAMME DE FLUX SIMPLIFIÉ

```
DÉBUT
  │
  ▼
Capteur compatible ?
  │
  ├─ OUI ──► MÉTHODE 1 ──► Test ──┬─ OK ──► FIN ✅
  │                               │
  │                               └─ KO ──► MÉTHODE 2 ──► FIN ✅
  │
  └─ NON ──► MÉTHODE 2 ───────────────────► FIN ✅
```

---

## SUPPORT

### Besoin d'Aide pour Décider ?

| Question | Ressource |
|----------|-----------|
| Quel modèle est compatible ? | `GUIDE_OPTIMISATION_REPORTING_ZIGBEE.md` (Annexe A) |
| Comment vérifier LQI/Batterie ? | `QUICK_REFERENCE_OPTIMISATION_ZIGBEE.md` |
| Méthode 1 vs Méthode 2 ? | Cette page (Matrice de décision) |
| Quel fichier lire en premier ? | `INDEX_PROJET_OPTIMISATION.md` |

---

**Dernière mise à jour**: 2025-12-18
**Version**: 1.0
