# Guide Utilisateur Simplifié - Chauffage

## Modes de Fonctionnement

### 🏖️ Mode Vacances
- **Action**: Activez `input_boolean.mode_vacance`.
- **Effet**: Le chauffage passe en hors-gel (16°C) et les climatisations sont coupées.
- **Priorité**: Maximale. Ignore tous les autres réglages.

### 🖐️ Mode Manuel
- **Action**: Utilisez les sélecteurs par pièce (ex: `input_select.mode_chauffage_salon`).
- **Effet**: La pièce maintient la température demandée indéfiniment.
- **Priorité**: Prend le pas sur le planning automatique.

### 📅 Mode Automatique (Planning)
- **Fonctionnement**: Si aucun mode manuel ou vacances n'est actif, le système suit le planning :
  - **05:45** : Réveil (Confort 19°C)
  - **08:00** : Journée (Éco 18.5°C)
  - **17:00** : Soirée (Confort 19°C)
  - **22:30** : Nuit (Nuit 16°C)

## Gestion de l'Humidité
- Si l'humidité dépasse le seuil défini (ex: 60%), le chauffage de la pièce concernée est temporairement augmenté (+2°C) pour assécher l'air.

## Pilotage Chaudière
- Le système vérifie les températures toutes les **3 minutes**.
- **Allumage**: Si température < Consigne - 0.5°C.
- **Extinction**: Si température > Consigne + 0.5°C.
- **Zone Morte**: Entre les deux, l'état est maintenu pour éviter les cycles courts.

## Dépannage Rapide
- **Il fait froid ?** Vérifiez que le "Mode Vacances" n'est pas actif.
- **Le chauffage ne s'arrête pas ?** Vérifiez si un "Mode Manuel" est activé sur une pièce.