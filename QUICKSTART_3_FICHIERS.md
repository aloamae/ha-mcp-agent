# QUICKSTART - 3 FICHIERS À INSTALLER

**Temps total:** 7 minutes

---

## 📥 FICHIER 1: Maintien remotes Broadlink (PRIORITÉ)

**Fichier:** `automation_maintenir_remotes_broadlink.yaml`

**Copier ce YAML dans HA → Automations:**

```yaml
id: maintenir_remotes_broadlink
alias: Maintenir remotes Broadlink actifs
description: Reactive automatiquement les remotes Broadlink toutes les 30 min
mode: restart

trigger:
  - platform: homeassistant
    event: start
  - platform: time_pattern
    minutes: /30

action:
  - delay:
      seconds: 30
  - service: homeassistant.turn_on
    target:
      entity_id:
        - remote.clim_salon
        - remote.clim_maeva
        - remote.clim_axel
```

**Résultat:** Remotes TOUJOURS ON automatiquement ✅

---

## 📥 FICHIER 2: Retour mode présence

**Fichier:** `automation_mode_presence_retour_simple.yaml`

**Copier ce YAML dans HA → Automations:**

```yaml
id: mode_presence_retour
alias: Retour maison
description: Restaure modes chauffage au retour
mode: single

trigger:
  - platform: state
    entity_id: zone.home
    from: "0"

action:
  - delay:
      minutes: 1
  - service: scene.turn_on
    target:
      entity_id: scene.avant_depart
  - service: persistent_notification.create
    data:
      title: Retour maison
      message: Modes restaures
```

**Résultat:** Modes restaurés automatiquement au retour ✅

---

## 📥 FICHIER 3: Dashboard debugging

**Fichier:** `dashboard_debugging_final.yaml`

**ATTENTION:** Structure `views:` OBLIGATOIRE

**Installation:**
1. HA → Tableaux de bord → + AJOUTER
2. Nom: "Debugging"
3. CRÉER
4. ... → Édition en mode brut
5. COLLER le fichier complet
6. ENREGISTRER

**Résultat:** Dashboard complet avec 6 sections ✅

---

## ✅ VALIDATION RAPIDE

```bash
# Test 1: Remotes ON
Outils dev → États → remote.clim_salon → Vérifier: ON

# Test 2: Automation retour
Automations → "Retour maison" → EXÉCUTER → Notification visible

# Test 3: Dashboard
Tableaux de bord → "Debugging" → Tout s'affiche
```

---

**C'est tout!** 3 fichiers, 7 minutes, système complet.

**Guide complet:** `INSTALLATION_FINALE_VALIDEE.md`
