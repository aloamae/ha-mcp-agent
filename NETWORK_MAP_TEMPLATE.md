# Carte du Réseau Zigbee - Template à Remplir

**Date de reconstruction** : ____ / ____ / ____
**Coordinateur** : SLZB-MR1-MEZZA (192.168.0.166)

---

## Réseau Cible (après reconstruction)

```
Coordinator: SLZB-MR1-MEZZA
├─ IEEE: ________________
├─ Firmware: ________________
├─ Canal: 11
├─ PAN ID: ________________
└─ Network Key: [CONFIDENTIEL]

Routeurs Mesh (2):
├─ Prise_Mesh_Salon
│  ├─ IEEE: ________________
│  ├─ Type: Router
│  ├─ LQI: ______
│  ├─ Emplacement: Salon
│  ├─ Connecté le: ____ / ____ / ____ à ____:____
│  └─ Capteurs associés:
│     ├─ [ ] th_salon (LQI: ______)
│     ├─ [ ] th_loann (LQI: ______)
│     └─ [ ] th_meva (LQI: ______)
│
└─ Prise_Mesh_Cuisine
   ├─ IEEE: ________________
   ├─ Type: Router
   ├─ LQI: ______
   ├─ Emplacement: Cuisine
   ├─ Connecté le: ____ / ____ / ____ à ____:____
   └─ Capteurs associés:
      ├─ [ ] th_cuisine (LQI: ______)
      ├─ [ ] th_axel (LQI: ______)
      ├─ [ ] th_parents (LQI: ______)
      └─ [ ] th_terrasse (LQI: ______)

Capteurs End Devices (7):
├─ th_cuisine
│  ├─ IEEE: ________________
│  ├─ Type: EndDevice (capteur T/H)
│  ├─ Route via: Prise_Mesh_Cuisine
│  ├─ LQI: ______
│  ├─ Batterie: ______%
│  ├─ Température: ______°C
│  ├─ Humidité: ______%
│  └─ Connecté le: ____ / ____ / ____ à ____:____
│
├─ th_salon
│  ├─ IEEE: ________________
│  ├─ Type: EndDevice (capteur T/H)
│  ├─ Route via: Prise_Mesh_Salon
│  ├─ LQI: ______
│  ├─ Batterie: ______%
│  ├─ Température: ______°C
│  ├─ Humidité: ______%
│  └─ Connecté le: ____ / ____ / ____ à ____:____
│
├─ th_loann
│  ├─ IEEE: ________________
│  ├─ Type: EndDevice (capteur T/H)
│  ├─ Route via: ________________
│  ├─ LQI: ______
│  ├─ Batterie: ______%
│  ├─ Température: ______°C
│  ├─ Humidité: ______%
│  └─ Connecté le: ____ / ____ / ____ à ____:____
│
├─ th_meva
│  ├─ IEEE: ________________
│  ├─ Type: EndDevice (capteur T/H)
│  ├─ Route via: ________________
│  ├─ LQI: ______
│  ├─ Batterie: ______%
│  ├─ Température: ______°C
│  ├─ Humidité: ______%
│  └─ Connecté le: ____ / ____ / ____ à ____:____
│
├─ th_axel
│  ├─ IEEE: ________________
│  ├─ Type: EndDevice (capteur T/H)
│  ├─ Route via: ________________
│  ├─ LQI: ______
│  ├─ Batterie: ______%
│  ├─ Température: ______°C
│  ├─ Humidité: ______%
│  └─ Connecté le: ____ / ____ / ____ à ____:____
│
├─ th_parents
│  ├─ IEEE: ________________
│  ├─ Type: EndDevice (capteur T/H)
│  ├─ Route via: ________________
│  ├─ LQI: ______
│  ├─ Batterie: ______%
│  ├─ Température: ______°C
│  ├─ Humidité: ______%
│  └─ Connecté le: ____ / ____ / ____ à ____:____
│
└─ th_terrasse
   ├─ IEEE: ________________
   ├─ Type: EndDevice (capteur T/H)
   ├─ Route via: ________________
   ├─ LQI: ______
   ├─ Batterie: ______%
   ├─ Température: ______°C
   ├─ Humidité: ______%
   └─ Connecté le: ____ / ____ / ____ à ____:____
```

---

## Statistiques du Réseau

### Qualité des liaisons (LQI)

| Appareil | Type | LQI | Qualité | Route |
|----------|------|-----|---------|-------|
| Prise_Mesh_Salon | Router | ____ | ________ | Direct au coordinateur |
| Prise_Mesh_Cuisine | Router | ____ | ________ | Direct au coordinateur |
| th_cuisine | EndDevice | ____ | ________ | Via ________________ |
| th_salon | EndDevice | ____ | ________ | Via ________________ |
| th_loann | EndDevice | ____ | ________ | Via ________________ |
| th_meva | EndDevice | ____ | ________ | Via ________________ |
| th_axel | EndDevice | ____ | ________ | Via ________________ |
| th_parents | EndDevice | ____ | ________ | Via ________________ |
| th_terrasse | EndDevice | ____ | ________ | Via ________________ |

**Légende qualité** :
- Excellente : LQI > 200
- Bonne : LQI 100-200
- Moyenne : LQI 50-100
- Faible : LQI 20-50
- Critique : LQI < 20

---

### Répartition des appareils par routeur

| Routeur | Nombre de capteurs | Capteurs |
|---------|-------------------|----------|
| Prise_Mesh_Salon | ____ | ________________ |
| Prise_Mesh_Cuisine | ____ | ________________ |
| Direct au coordinateur | ____ | ________________ |

**Note** : Idéalement, aucun capteur ne doit être directement connecté au coordinateur (utiliser les routeurs).

---

### État des batteries

| Capteur | Niveau batterie | État | Action requise |
|---------|-----------------|------|----------------|
| th_cuisine | ______% | [ ] OK [ ] Faible [ ] Critique | ________________ |
| th_salon | ______% | [ ] OK [ ] Faible [ ] Critique | ________________ |
| th_loann | ______% | [ ] OK [ ] Faible [ ] Critique | ________________ |
| th_meva | ______% | [ ] OK [ ] Faible [ ] Critique | ________________ |
| th_axel | ______% | [ ] OK [ ] Faible [ ] Critique | ________________ |
| th_parents | ______% | [ ] OK [ ] Faible [ ] Critique | ________________ |
| th_terrasse | ______% | [ ] OK [ ] Faible [ ] Critique | ________________ |

**Seuils** :
- OK : > 50%
- Faible : 20-50% (surveiller)
- Critique : < 20% (remplacer)

---

## Carte Visuelle Simplifiée

```
                    [COORDINATOR]
                    SLZB-MR1-MEZZA
                    192.168.0.166
                          |
         +----------------+----------------+
         |                                 |
   [ROUTEUR 1]                      [ROUTEUR 2]
Prise_Mesh_Salon                Prise_Mesh_Cuisine
  LQI: ____                       LQI: ____
         |                                 |
    +----+----+----+              +----+----+----+----+
    |    |    |    |              |    |    |    |    |
  [th_] [th_] [th_]            [th_] [th_] [th_] [th_]
  ____  ____  ____             ____  ____  ____  ____
```

**À remplir avec les noms des capteurs selon leur route réelle**

---

## Plan du Logement (à annoter)

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Terrasse                                               │
│  [ th_terrasse ]                                        │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                        │                                │
│      Salon             │    Cuisine                     │
│  [Prise_Mesh_Salon]    │  [Prise_Mesh_Cuisine]          │
│  [ th_salon ]          │  [ th_cuisine ]                │
│                        │                                │
│                        │                                │
├────────────────────────┴─────────────────────────────────┤
│                                                         │
│  Chambre Parents         Chambre Axel                  │
│  [ th_parents ]          [ th_axel ]                    │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Chambre Loann           Chambre Meva                  │
│  [ th_loann ]            [ th_meva ]                    │
│                                                         │
└─────────────────────────────────────────────────────────┘

Coordinateur: [  ] (indiquer l'emplacement)
```

**Légende** :
- [Prise_Mesh_X] = Routeur mesh (prise connectée)
- [th_X] = Capteur température/humidité

---

## Notes et Observations

### Problèmes rencontrés lors de la reconstruction

```
Appareil : ________________
Problème : ________________
Solution appliquée : ________________
Date/heure : ____ / ____ / ____ à ____:____

---

Appareil : ________________
Problème : ________________
Solution appliquée : ________________
Date/heure : ____ / ____ / ____ à ____:____

---

Appareil : ________________
Problème : ________________
Solution appliquée : ________________
Date/heure : ____ / ____ / ____ à ____:____
```

### Améliorations futures

```
[ ] Ajouter un 3ème routeur mesh dans : ________________
[ ] Déplacer le routeur ________________ vers ________________
[ ] Remplacer les piles de : ________________
[ ] Ajouter de nouveaux capteurs : ________________
[ ] Optimiser le canal Zigbee (actuellement 11) vers : ____
[ ] Autre : ________________
```

### Historique des maintenances

| Date | Action | Appareil | Détails |
|------|--------|----------|---------|
| ____ / ____ / ____ | Remplacement pile | ________ | ________ |
| ____ / ____ / ____ | Réappairage | ________ | ________ |
| ____ / ____ / ____ | Ajout appareil | ________ | ________ |
| ____ / ____ / ____ | ________ | ________ | ________ |

---

## Informations Techniques

### Configuration Zigbee2MQTT

- **Version** : ________________
- **Canal Zigbee** : ____
- **PAN ID** : ________________
- **Transmit Power** : ____ dBm
- **Log Level** : ________________
- **MQTT Server** : mqtt://localhost:1883
- **Frontend** : http://homeassistant.local:8100 (Note: Port changé depuis 8099 pour éviter conflit avec HA Vibecode Agent)

### Coordinateur SLZB-MR1-MEZZA

- **Modèle** : SLZB-MR1-MEZZA
- **Firmware** : ________________
- **IP** : 192.168.0.166
- **Port** : 6638
- **MAC Address** : ________________
- **Interface Web** : http://192.168.0.166

### Mosquitto MQTT Broker

- **Version** : ________________
- **Port** : 1883
- **Utilisateur** : homeassistant
- **SSL/TLS** : [ ] Activé [ ] Désactivé

---

## Sauvegarde

### Dernière sauvegarde complète

- **Date** : ____ / ____ / ____ à ____:____
- **Taille** : ________ MB
- **Emplacement** : ________________
- **Testé** : [ ] Oui [ ] Non
- **Date du test** : ____ / ____ / ____

### Fichiers critiques sauvegardés

- [ ] /config/zigbee2mqtt/configuration.yaml
- [ ] /config/zigbee2mqtt/database.db
- [ ] /config/secrets.yaml
- [ ] /config/configuration.yaml
- [ ] /config/automations.yaml
- [ ] Snapshot complet Home Assistant

---

## Validation Finale

### Checklist de validation (cocher si OK)

- [ ] Les 2 routeurs mesh sont Online
- [ ] Les 7 capteurs sont Online
- [ ] Tous les LQI sont > 50
- [ ] Aucune entité orpheline MQTT
- [ ] Mode appairage désactivé (permit_join: false)
- [ ] Carte réseau (Map) montre le mesh correctement formé
- [ ] Tests ON/OFF des routeurs fonctionnent (< 1s)
- [ ] Capteurs remontent des données cohérentes
- [ ] Aucune déconnexion observée pendant 1 heure
- [ ] Sauvegarde complète effectuée
- [ ] Documentation complétée et archivée

### Signatures

**Reconstruction effectuée par** : ________________
**Date** : ____ / ____ / ____
**Durée totale** : ____ h ____ min

**Validée par** : ________________
**Date** : ____ / ____ / ____

---

## Annexe : Export de la Carte Réseau Zigbee2MQTT

**Instructions** :
1. Ouvrir Zigbee2MQTT Frontend : http://homeassistant.local:8100
2. Cliquer sur "Map" dans le menu
3. Faire une capture d'écran
4. Sauvegarder sous : `zigbee_network_map_YYYYMMDD.png`
5. Archiver avec cette documentation

**Fichier de carte** : ________________

---

**Document complété le** : ____ / ____ / ____
**Prochaine révision prévue** : ____ / ____ / ____
