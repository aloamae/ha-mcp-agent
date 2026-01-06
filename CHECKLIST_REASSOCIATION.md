# Checklist de Réassociation Zigbee2MQTT

**Date**: 2025-12-18
**Coordinateur**: SLZB-MR1-MEZZA (192.168.0.166:6638)

---

## PHASE PRÉPARATOIRE

### Vérifications préalables

- [ ] Home Assistant est opérationnel
- [ ] Mosquitto MQTT broker fonctionne (localhost:1883)
- [ ] SLZB-MR1-MEZZA est accessible (ping 192.168.0.166)
- [ ] Port 6638 est ouvert (nc -zv 192.168.0.166 6638)

### Installation Zigbee2MQTT

- [ ] Add-on Zigbee2MQTT installé
- [ ] Configuration YAML appliquée (zigbee2mqtt_configuration.yaml)
- [ ] Secrets configurés dans /config/secrets.yaml
- [ ] Add-on "Démarrer au boot" activé
- [ ] Add-on démarré avec succès
- [ ] Logs confirment "Zigbee2MQTT started!"
- [ ] Interface Web accessible (http://homeassistant.local:8100 ou http://192.168.0.166:8100)
- [ ] Coordinateur détecté dans les logs

---

## PHASE 1 : ROUTEURS MESH (PRIORITÉ ABSOLUE)

### Routeur 1 : Prise_Mesh_Salon

#### Préparation
- [ ] Mode appairage activé dans Z2M (Permit Join)
- [ ] Interface Web Z2M ouverte (onglet "Appareils")

#### Appairage
- [ ] Prise branchée et sous tension
- [ ] Reset effectué (maintenir bouton 5-10s)
- [ ] LED clignote rapidement (mode appairage)
- [ ] Appareil détecté dans les logs Z2M
- [ ] Interview terminée avec succès
- [ ] Appareil visible dans l'interface Z2M

#### Configuration
- [ ] Friendly Name défini : `Prise_Mesh_Salon`
- [ ] Type confirmé : Router (routeur)
- [ ] État : Online
- [ ] Test ON/OFF depuis Home Assistant : OK

#### Stabilisation
- [ ] Attente de 2 minutes
- [ ] Aucune déconnexion observée
- [ ] LQI (qualité liaison) > 100

**Horodatage : ____:____**

---

### Routeur 2 : Prise_Mesh_Cuisine

#### Préparation
- [ ] Mode appairage toujours actif
- [ ] Routeur 1 toujours Online

#### Appairage
- [ ] Prise branchée et sous tension
- [ ] Reset effectué (maintenir bouton 5-10s)
- [ ] LED clignote rapidement (mode appairage)
- [ ] Appareil détecté dans les logs Z2M
- [ ] Interview terminée avec succès
- [ ] Appareil visible dans l'interface Z2M

#### Configuration
- [ ] Friendly Name défini : `Prise_Mesh_Cuisine`
- [ ] Type confirmé : Router (routeur)
- [ ] État : Online
- [ ] Test ON/OFF depuis Home Assistant : OK

#### Stabilisation du réseau mesh
- [ ] Attente de 5 minutes minimum
- [ ] Les 2 routeurs sont Online
- [ ] Carte réseau (Map) montre les 2 routeurs connectés au coordinateur
- [ ] Aucune déconnexion observée

**Horodatage : ____:____**

---

## PHASE 2 : CAPTEURS TEMPÉRATURE/HUMIDITÉ

### Capteur 1 : th_cuisine

#### Appairage
- [ ] Mode appairage actif
- [ ] Pile retirée
- [ ] Bouton reset/pair maintenu
- [ ] Pile réinsérée (bouton toujours maintenu)
- [ ] Bouton relâché après 5-10s
- [ ] LED d'indication active
- [ ] Appareil détecté dans les logs Z2M
- [ ] Interview terminée avec succès

#### Configuration
- [ ] Friendly Name défini : `th_cuisine`
- [ ] Type confirmé : EndDevice (capteur)
- [ ] État : Online
- [ ] Données de température et humidité reçues
- [ ] Entités créées dans Home Assistant :
  - [ ] sensor.th_cuisine_temperature
  - [ ] sensor.th_cuisine_humidity
  - [ ] sensor.th_cuisine_battery (si applicable)
  - [ ] sensor.th_cuisine_linkquality

#### Validation
- [ ] Valeurs cohérentes (température 15-30°C, humidité 30-70%)
- [ ] Attente de 30 secondes

**Horodatage : ____:____**

---

### Capteur 2 : th_salon

#### Appairage
- [ ] Mode appairage actif
- [ ] Reset effectué (voir procédure ci-dessus)
- [ ] Appareil détecté et interviewé

#### Configuration
- [ ] Friendly Name défini : `th_salon`
- [ ] État : Online
- [ ] Données reçues
- [ ] Entités créées dans Home Assistant

#### Validation
- [ ] Valeurs cohérentes
- [ ] Attente de 30 secondes

**Horodatage : ____:____**

---

### Capteur 3 : th_loann

#### Appairage
- [ ] Mode appairage actif
- [ ] Reset effectué
- [ ] Appareil détecté et interviewé

#### Configuration
- [ ] Friendly Name défini : `th_loann`
- [ ] État : Online
- [ ] Données reçues
- [ ] Entités créées dans Home Assistant

#### Validation
- [ ] Valeurs cohérentes
- [ ] Attente de 30 secondes

**Horodatage : ____:____**

---

### Capteur 4 : th_meva

#### Appairage
- [ ] Mode appairage actif
- [ ] Reset effectué
- [ ] Appareil détecté et interviewé

#### Configuration
- [ ] Friendly Name défini : `th_meva`
- [ ] État : Online
- [ ] Données reçues
- [ ] Entités créées dans Home Assistant

#### Validation
- [ ] Valeurs cohérentes
- [ ] Attente de 30 secondes

**Horodatage : ____:____**

---

### Capteur 5 : th_axel

#### Appairage
- [ ] Mode appairage actif
- [ ] Reset effectué
- [ ] Appareil détecté et interviewé

#### Configuration
- [ ] Friendly Name défini : `th_axel`
- [ ] État : Online
- [ ] Données reçues
- [ ] Entités créées dans Home Assistant

#### Validation
- [ ] Valeurs cohérentes
- [ ] Attente de 30 secondes

**Horodatage : ____:____**

---

### Capteur 6 : th_parents

#### Appairage
- [ ] Mode appairage actif
- [ ] Reset effectué
- [ ] Appareil détecté et interviewé

#### Configuration
- [ ] Friendly Name défini : `th_parents`
- [ ] État : Online
- [ ] Données reçues
- [ ] Entités créées dans Home Assistant

#### Validation
- [ ] Valeurs cohérentes
- [ ] Attente de 30 secondes

**Horodatage : ____:____**

---

### Capteur 7 : th_terrasse

#### Appairage
- [ ] Mode appairage actif
- [ ] Reset effectué
- [ ] Appareil détecté et interviewé

#### Configuration
- [ ] Friendly Name défini : `th_terrasse`
- [ ] État : Online
- [ ] Données reçues
- [ ] Entités créées dans Home Assistant

#### Validation
- [ ] Valeurs cohérentes
- [ ] Appareil le plus éloigné, vérifier LQI > 50

**Horodatage : ____:____**

---

## PHASE 3 : SÉCURISATION ET NETTOYAGE

### Désactivation du mode appairage

- [ ] Mode "Permit Join" désactivé dans Z2M
- [ ] OU configuration modifiée : `permit_join: false`
- [ ] Add-on redémarré (si config modifiée)

### Nettoyage des entités orphelines

#### Via l'interface Home Assistant

- [ ] Paramètres → Appareils et services
- [ ] Onglet "Entités"
- [ ] Filtrer : "mqtt" + "unavailable"

#### Entités à supprimer :

- [ ] `switch.prise_mesh_salon` (ancienne)
- [ ] `switch.prise_mesh_cuisine` (ancienne)
- [ ] Toutes autres entités Zigbee unavailable depuis restauration

#### Pour chaque entité :

- [ ] Cliquer sur l'entité
- [ ] Menu (3 points) → "Supprimer l'entité"
- [ ] Confirmer la suppression

**Nombre d'entités supprimées : ____**

---

## PHASE 4 : VALIDATION FINALE

### Validation du réseau mesh

- [ ] Interface Z2M → Map (carte réseau)
- [ ] 2 routeurs connectés au coordinateur
- [ ] 7 capteurs répartis via les routeurs
- [ ] Tous les appareils : Online

### Tests de connectivité

#### Routeurs
- [ ] `Prise_Mesh_Salon` : ON/OFF réactif (< 1s)
- [ ] `Prise_Mesh_Cuisine` : ON/OFF réactif (< 1s)

#### Capteurs (mise à jour automatique ou manuelle)
- [ ] `th_cuisine` : données à jour
- [ ] `th_salon` : données à jour
- [ ] `th_loann` : données à jour
- [ ] `th_meva` : données à jour
- [ ] `th_axel` : données à jour
- [ ] `th_parents` : données à jour
- [ ] `th_terrasse` : données à jour

### Tests de stabilité (observation 1 heure)

- [ ] Aucune déconnexion observée dans les logs
- [ ] LQI moyen > 100 pour les routeurs
- [ ] LQI moyen > 50 pour les capteurs
- [ ] Délai de mise à jour des capteurs : 5-10 min

### Entités Home Assistant

- [ ] Toutes les nouvelles entités sont disponibles
- [ ] Aucune entité orpheline restante
- [ ] Entités intégrées dans les tableaux de bord existants (si applicable)

---

## PHASE 5 : SAUVEGARDE

### Backup Zigbee2MQTT

- [ ] Configuration YAML exportée : `/config/backups/z2m_config_YYYYMMDD.yaml`
- [ ] Base de données exportée : `/config/backups/z2m_db_YYYYMMDD.db`

### Backup Home Assistant

- [ ] Snapshot complet créé : Paramètres → Système → Sauvegardes
- [ ] Backup téléchargé sur stockage externe
- [ ] Date du backup : ____ / ____ / ____

---

## DOCUMENTATION

### Carte réseau finale (à dessiner ou copier depuis Z2M Map)

```
Coordinator (SLZB-MR1-MEZZA)
  ├── Prise_Mesh_Salon [Router]
  │   ├── [Capteur(s) connecté(s)]
  │   └──
  └── Prise_Mesh_Cuisine [Router]
      ├── [Capteur(s) connecté(s)]
      └──
```

### Informations techniques enregistrées

- [ ] IEEE Address du coordinateur : ________________
- [ ] PAN ID généré : ________________
- [ ] Canal utilisé : ____
- [ ] Firmware coordinateur : ________________

### Notes et observations

```
[Espace pour noter les problèmes rencontrés, solutions appliquées, etc.]




```

---

## RÉSULTAT FINAL

### Statut global

- [ ] Réseau Zigbee2MQTT opérationnel à 100%
- [ ] 2 routeurs mesh Online et stables
- [ ] 7 capteurs Online et remontant des données
- [ ] Home Assistant intégré correctement
- [ ] Anciennes entités nettoyées
- [ ] Sauvegardes effectuées

### Durée totale de la reconstruction

- Début : ____:____
- Fin : ____:____
- Durée : ____ min

### Prochaines étapes (optionnel)

- [ ] Créer des groupes dans Zigbee2MQTT
- [ ] Intégrer dans les automations Home Assistant
- [ ] Créer des dashboards Lovelace personnalisés
- [ ] Documenter les procédures de reset de chaque appareil
- [ ] Planifier des sauvegardes automatiques hebdomadaires

---

**Checklist complétée le : ____ / ____ / ____**
**Par : ________________**
**Statut final : [ ] Succès  [ ] Succès partiel  [ ] Échec**
