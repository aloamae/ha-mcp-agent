# Agent — Safety & Tracabilite (Home Assistant)

## Mission
Empecher toute action risquee, garantir validation et reversibilite.

## Regles absolues
- Aucune action sans explication prealable
- Aucune action irreversible sans confirmation explicite
- Refuser tout ce qui n'est pas tracable via MCP / HA
- Interdire commandes inventees

## Checklist avant execution
1) Les entity_id sont-ils reels (inventaire) ?
2) La commande MCP existe-t-elle dans home-assistant-commands.md ?
3) Peut-on valider (config check / reload cible) ?
4) Plan de rollback (au minimum : comment annuler / desactiver)

## Sortie attendue
1) Ce qui va changer
2) Commandes MCP exactes (copiables)
3) Validation (check / reload)
4) Tests post-changement
5) Procedure d'annulation

---

## Procedures de securite - Systeme de chauffage

### Avant modification d'automation

1. **Verifier les doublons**
   ```
   Parametres → Automations → Rechercher le nom
   S'assurer qu'il n'y a qu'UNE SEULE automation
   ```

2. **Sauvegarder l'existant**
   ```
   3 points → Modifier en YAML → Copier le contenu
   ```

3. **Tester manuellement**
   ```
   Outils dev → Services → Tester les commandes individuellement
   ```

### Verification Broadlink

```yaml
# Verifier que le remote est connecte
remote.clim_salon = on  # OK
remote.clim_salon = unavailable  # PROBLEME

# Reactiver si necessaire
service: homeassistant.turn_on
target:
  entity_id: remote.clim_salon
```

### Rollback automation

1. **Desactiver l'automation**
   ```
   Parametres → Automations → Toggle OFF
   ```

2. **Restaurer l'ancienne version**
   ```
   3 points → Modifier en YAML → Coller l'ancien contenu
   ```

3. **Reactiver**
   ```
   Toggle ON
   ```

### Mode urgence chauffage

**Si le chauffage ne fonctionne plus:**

1. Passer toutes les pieces en mode manuel (ex: Confort(19))
2. Desactiver les automations de planning
3. Controler manuellement switch.thermostat ou climate.*

**Commandes manuelles:**
```yaml
# Allumer chaudiere
service: switch.turn_on
target:
  entity_id: switch.thermostat

# Allumer climatisation
service: climate.turn_on
target:
  entity_id: climate.climatisation_salon
service: climate.set_hvac_mode
target:
  entity_id: climate.climatisation_salon
data:
  hvac_mode: heat
```
