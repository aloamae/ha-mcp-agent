# Outils MCP — Home Assistant

## Serveurs MCP disponibles
- home-assistant (via @coolver/home-assistant-mcp)

## Capacites principales
- Lister toutes les entites
- Lire l'etat d'une entite
- Allumer / eteindre une entite
- Ajuster luminosite, temperature, mode
- Executer une scene ou un script
- Lister et modifier les automations
- Gerer les helpers (input_*)

## Bonnes pratiques
- Toujours verifier l'existence d'une entite avant action
- Eviter les commandes groupees sans demande explicite
- Preferer les actions reversibles
- Verifier les doublons d'automations avant modification
- Tester manuellement dans Outils dev avant automatisation

## Logique recommandee
1. Identifier l'intention utilisateur
2. Verifier les entites concernees (audit)
3. Expliquer l'action proposee
4. Demander confirmation si action critique
5. Executer
6. Verifier le resultat

---

## Commandes MCP frequentes

### Exploration
```
@home-assistant entities list
@home-assistant entities list --domain climate
@home-assistant automations list
@home-assistant helpers list
```

### Etats
```
@home-assistant entity state --entity input_boolean.mode_vacance
@home-assistant entity state --entity climate.climatisation_salon
```

### Actions
```
@home-assistant service call --domain climate --service turn_on --entity climate.climatisation_salon
@home-assistant service call --domain input_boolean --service turn_on --entity input_boolean.mode_vacance
@home-assistant service call --domain input_number --service set_value --entity input_number.mode_chauffage_global --value 19
```

### Validation
```
@home-assistant config check
@home-assistant reload all
```

---

## Systeme de chauffage - Commandes utiles

### Controler le mode global
```
@home-assistant service call --domain input_number --service set_value --entity input_number.mode_chauffage_global --value 19
```

### Activer mode vacances
```
@home-assistant service call --domain input_boolean --service turn_on --entity input_boolean.mode_vacance
```

### Changer mode d'une piece
```
@home-assistant service call --domain input_select --service select_option --entity input_select.mode_chauffage_salon --option "Confort(19)"
```

### Verifier etat climatisation
```
@home-assistant entity state --entity climate.climatisation_salon
@home-assistant entity state --entity remote.clim_salon
```
