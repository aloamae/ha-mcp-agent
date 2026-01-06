# AUTOMATION DÉPART - CRÉATION VIA UI

**À créer EN PREMIER** (avant l'automation retour)

---

## Créer via l'interface HA

```
Automations → + CRÉER UNE AUTOMATION

NOM: Depart maison

MODE: Single

DÉCLENCHEUR:
→ + Ajouter un déclencheur
→ Type: État
→ Entité: zone.home
→ À: 0

ACTION 1: Créer la scène (sauvegarde)
→ + Ajouter une action
→ Type: Appeler un service
→ Service: scene.create
→ Données du service (cliquer "Basculer vers le mode YAML"):
  scene_id: avant_depart
  snapshot_entities:
    - input_select.mode_chauffage_salon
    - input_select.mode_chauffage_cuisine

ACTION 2: Passer en mode Absent
→ + Ajouter une action
→ Type: Appeler un service
→ Service: input_select.select_option
→ Cible: input_select.mode_chauffage_salon
→ Option: Absent

ACTION 3: Passer cuisine en Absent
→ + Ajouter une action
→ Type: Appeler un service
→ Service: input_select.select_option
→ Cible: input_select.mode_chauffage_cuisine
→ Option: Absent

ENREGISTRER
```

---

## OU Version YAML (si UI timeout)

```yaml
id: depart_presence
alias: Depart maison
mode: single

trigger:
  - platform: state
    entity_id: zone.home
    to: "0"

action:
  - service: scene.create
    data:
      scene_id: avant_depart
      snapshot_entities:
        - input_select.mode_chauffage_salon
        - input_select.mode_chauffage_cuisine

  - service: input_select.select_option
    target:
      entity_id: input_select.mode_chauffage_salon
    data:
      option: Absent

  - service: input_select.select_option
    target:
      entity_id: input_select.mode_chauffage_cuisine
    data:
      option: Absent
```
