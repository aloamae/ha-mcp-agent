# EXPLICATION - ERREUR SCÈNE

## ❌ CE QUE TU AS FAIT (FAUX)

Tu as essayé de créer une **SCÈNE** au lieu d'une **AUTOMATION**.

```
Scènes → + Créer une scène
→ Nom: avant_depart
→ Tu as copié du YAML d'automation
→ ERREUR: "duplicated mapping key"
```

**Pourquoi ça plante:**
- Une scène attend un format différent
- Tu as mélangé automation et scène
- Le YAML contenait des instructions UI en texte

---

## ✅ CE QU'IL FAUT FAIRE

### NE PAS créer de scène manuellement!

La scène est créée **AUTOMATIQUEMENT** par l'automation de départ.

---

## 📊 SCHÉMA DU FONCTIONNEMENT

```
1. TU PARS DE LA MAISON
   └─> zone.home passe à 0
       └─> AUTOMATION DÉPART se déclenche
           ├─> Action 1: scene.create crée "avant_depart"
           │   (sauvegarde les états actuels)
           ├─> Action 2: Mode Salon → Hors-Gel
           └─> Action 3: Mode Cuisine → Hors-Gel

2. TU RENTRES À LA MAISON
   └─> zone.home passe à 1+
       └─> AUTOMATION RETOUR se déclenche
           └─> Action: scene.turn_on "avant_depart"
               (restaure les états sauvegardés)
```

---

## 🎯 DONC L'ORDRE EST

### 1. Créer AUTOMATION DÉPART

**PAS une scène!** Une **AUTOMATION**!

```
Automations → + CRÉER UNE AUTOMATION
```

**Cette automation va:**
- Détecter quand tu pars (zone.home = 0)
- Créer automatiquement la scène "avant_depart"
- Passer les modes en Hors-Gel

### 2. Créer AUTOMATION RETOUR

```
Automations → + CRÉER UNE AUTOMATION
```

**Cette automation va:**
- Détecter quand tu rentres (zone.home change de 0)
- Restaurer la scène "avant_depart"

---

## 🔍 VÉRIFICATION

### Après avoir créé l'automation DÉPART

**Test:**
```
1. Outils dev → États → zone.home
2. Changer à: 0
3. Attendre 5 secondes
4. Outils dev → États → Chercher "scene"
5. Tu DOIS voir: scene.avant_depart ✅
```

**Si la scène n'apparaît PAS:**
- L'automation départ n'a pas fonctionné
- Vérifier: Automations → Depart maison → Historique
- Vérifier: Logs pour erreurs

---

## 💡 FORMAT CORRECT DE LA SCÈNE

**Quand scene.create fonctionne, voici à quoi ressemble la scène:**

```yaml
id: "1766318059842"
name: avant_depart
entities:
  input_select.mode_chauffage_salon:
    state: Confort2(19.5)
  input_select.mode_chauffage_cuisine:
    state: Confort2(19.5)
```

**C'est généré AUTOMATIQUEMENT**, tu ne dois PAS le créer manuellement!

---

## 📋 RÉSUMÉ

| ❌ FAUX | ✅ CORRECT |
|---------|-----------|
| Créer scène "avant_depart" | Créer automation DÉPART |
| Copier YAML dans scène | L'automation crée la scène |
| Format scène invalide | Format automation valide |

---

## 🚀 SOLUTION FINALE

**Suis EXACTEMENT ce guide:**

[GUIDE_UI_SIMPLE_ETAPE_PAR_ETAPE.md](GUIDE_UI_SIMPLE_ETAPE_PAR_ETAPE.md)

**Sections importantes:**
- Section "Automation 1: DÉPART" → Crée l'automation (PAS la scène)
- Section "Ne pas créer de scène manuellement" → Explication

**Temps:** 2 minutes pour automation départ

---

**La scène sera créée automatiquement au premier départ!** ✅
