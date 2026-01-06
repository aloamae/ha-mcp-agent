# Audit du Système de Chauffage

*Audit basé sur les fichiers de configuration locaux.*

## 1. Inventaire

### Entités
- **Helpers**: 14 entités identifiées (input_boolean, input_number, input_select).
- **Automations**: 18+ automations couvrant le planning, le pilotage et la gestion de l'humidité.
- **Zones**: 6 pièces gérées (3 zones Chaudière GAZ, 3 zones Climatisation IR).

### Structure
- **Chauffage Central**: Pilotage chaudière gaz via relais.
- **Climatisation**: Pilotage IR via Broadlink (Salon, Maeva, Axel).

## 2. Logique de Priorité (6 Niveaux)

1. **Mode Vacances**: Priorité absolue (Force 16°C / OFF).
2. **Mode Humidité**: Boost temporaire si humidité > seuil.
3. **Mode Manuel**: Consigne forcée par l'utilisateur par pièce.
4. **Mode Planning**: Programmation horaire (05:45, 08:00, 17:00, 22:30).
5. **Mode Global**: Consigne par défaut (fallback).
6. **Pilotage**: Boucle de régulation (Toutes les 3 min, seuils ±0.5°C).

## 3. Points d'Attention

- **Trigger 05:45**: À vérifier lors du prochain cycle matinal pour confirmer le déclenchement correct du planning.
- **Accès MCP**: L'audit temps réel nécessite les variables d'environnement `HA_AGENT_URL` et `HA_AGENT_KEY`.