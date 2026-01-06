# Guide Utilisateur — Systeme de Chauffage Intelligent

**Date:** 23 decembre 2025

---

## 1. VUE D'ENSEMBLE

Le systeme de chauffage gere automatiquement:
- **3 pieces GAZ:** Cuisine, Parents, Loann (via chaudiere)
- **3 pieces CLIM:** Salon, Axel, Maeva (via climatisations Broadlink)

---

## 2. MODES DISPONIBLES

### 2.1 Par piece

| Mode | Temperature | Description |
|------|-------------|-------------|
| `MODEJOUR` | Variable | Suit le planning automatique |
| `STOP` | OFF | Chauffage coupe |
| `Confort3(21)` | 21C | Tres confort |
| `Confort2(20)` | 20C | Confort+ |
| `Confort(19)` | 19C | Confort standard |
| `Eco(18)` | 18C | Economique |
| `Hors-Gel2(17)` | 17C | Protection |
| `Hors-Gel(16)` | 16C | Minimum |

### 2.2 Globaux

| Mode | Description |
|------|-------------|
| **Mode Vacances** | Force 16C partout, coupe les clims |
| **Mode Global** | Temperature de reference pour MODEJOUR |

---

## 3. SCENARIOS D'UTILISATION

### 3.1 Je suis present (utilisation normale)

**Action:** Laisser les pieces en `MODEJOUR`

**Resultat:** Le planning automatique gere tout:
- 05:45 -> 19C (reveil)
- 08:00 -> 17C (depart)
- 17:00 -> 19C (retour)
- 22:30 -> 17C (nuit)

### 3.2 Je veux plus chaud dans une piece

**Action:**
1. Aller dans l'interface Home Assistant
2. Choisir la piece (ex: Salon)
3. Changer le mode vers `Confort3(21)` ou autre

**Resultat:**
- La piece chauffe a la temperature choisie
- Au prochain creneau horaire, elle reviendra en MODEJOUR

### 3.3 Je pars en vacances

**Action:**
1. Activer le **Mode Vacances**
2. (Optionnel) Desactiver l'interrupteur `mode_vacance`

**Resultat:**
- Toutes les pieces passent a 16C
- Les climatisations sont coupees
- Le planning est desactive

### 3.4 Je veux couper le chauffage d'une piece

**Action:** Mettre la piece en mode `STOP`

**Resultat:** Le chauffage est coupe pour cette piece uniquement.

### 3.5 Humidite elevee

**Action:** Rien a faire, c'est automatique!

**Fonctionnement:**
- Si humidite > 61% pendant 2 minutes
- Le systeme ajoute +2C automatiquement
- Retour a la normale quand humidite < 61% pendant 5 minutes

---

## 4. INTERFACE DE CONTROLE

### 4.1 Dashboard principal

Acces: **Parametres -> Tableaux de bord -> Chauffage**

Cartes disponibles:
- Vue d'ensemble des priorites actives
- Planning de la journee
- Controle mode global
- Etat de chaque piece (temperature, humidite, mode)
- Guide utilisateur

### 4.2 Dashboard debugging

Acces: **Parametres -> Tableaux de bord -> Debugging**

Cartes disponibles:
- Ordre de priorite des modes
- Etat detaille de chaque niveau
- Logs du systeme
- Historiques temperature/humidite

---

## 5. PRIORITES (Important!)

Le systeme respecte un ordre strict:

```
1. MODE VACANCES    -> Bloque tout
2. MODE HUMIDITE    -> Boost +2C si humide
3. MODE MANUEL      -> Choix utilisateur par piece
4. MODE PLANNING    -> Creneaux horaires
5. MODE GLOBAL      -> Temperature de reference
6. PILOTAGE         -> Execution physique
```

**Exemple:**
- Planning dit 17C
- Humidite > seuil dans Cuisine
- -> Cuisine chauffe a 19C (17 + 2)

---

## 6. TEMPERATURES DE REFERENCE

### 6.1 Planning automatique

| Heure | Nom | Temperature |
|-------|-----|-------------|
| 05:45 | Confort Matin | 19C |
| 08:00 | Eco Journee | 17C |
| 17:00 | Confort Soir | 19C |
| 22:30 | Hors-Gel Nuit | 17C |

### 6.2 Seuils techniques

| Parametre | Valeur |
|-----------|--------|
| Seuil humidite | 61% |
| Boost humidite | +2C |
| Zone morte | +/-0.5C |
| Cycle pilotage | 3 minutes |

---

## 7. DEPANNAGE

### 7.1 Le chauffage ne demarre pas

**Verifier:**
1. Mode vacances desactive?
2. Piece pas en STOP?
3. Temperature ambiante < consigne?

### 7.2 Une climatisation ne repond pas

**Cause probable:** Remote Broadlink deconnecte

**Solution:**
1. Outils dev -> Services
2. `homeassistant.turn_on`
3. Entite: `remote.clim_salon` (ou autre)

### 7.3 Boost humidite ne s'active pas

**Verifier:**
1. Capteur humidite fonctionnel?
2. Humidite > 61%?
3. Attendre 2 minutes apres depassement du seuil

### 7.4 Planning ne fonctionne pas

**Verifier:**
1. Automations actives?
   - `chauffage_planning_automatique_horaire`
   - `chauffage_mise_a_jour_mode_global`
2. Mode vacances desactive?

---

## 8. FAQ

### Q: Puis-je modifier les horaires du planning?

**R:** Oui, en editant l'automation `chauffage_planning_automatique_horaire` dans Home Assistant.

### Q: Comment changer le seuil d'humidite?

**R:** Modifier `input_number.seuil_humidite_chauffage` dans les helpers.

### Q: Comment desactiver completement le planning?

**R:** Desactiver les 2 automations:
- `chauffage_planning_automatique_horaire`
- `chauffage_mise_a_jour_mode_global`

### Q: Comment forcer une temperature globale?

**R:** Modifier `input_number.mode_chauffage_global` dans les helpers. Attention: sera ecrase au prochain creneau horaire.

### Q: Pourquoi la chaudiere chauffe plus que prevu?

**R:** Verifiez:
1. Boost humidite actif sur une piece?
2. Une piece en mode manuel avec temperature elevee?
3. Le systeme GAZ prend le MAX des 3 pieces.

---

## 9. ENTITES UTILES

### 9.1 Pour le monitoring

| Entite | Description |
|--------|-------------|
| `input_boolean.mode_vacance` | Etat mode vacances |
| `input_number.mode_chauffage_global` | Temperature globale |
| `input_boolean.mode_humidite_*` | Boost humidite par piece |
| `switch.thermostat` | Etat chaudiere |

### 9.2 Pour le controle

| Entite | Action |
|--------|--------|
| `input_select.mode_chauffage_*` | Changer mode piece |
| `input_boolean.mode_vacance` | Activer/desactiver vacances |
| `input_number.mode_chauffage_global` | Forcer temperature globale |

---

**Fin du guide**
