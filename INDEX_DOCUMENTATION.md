# Index de la Documentation Zigbee2MQTT

**Créée le** : 2025-12-18
**Total des fichiers** : 11
**Taille totale** : ~100 KB

---

## Fichiers Créés

**Note importante**: Le 2025-12-18, le port Zigbee2MQTT a été changé de 8099 à 8100 pour éviter un conflit avec HA Vibecode Agent. Voir `CORRECTION_PORT_8099_RAPPORT.md` pour les détails.

### 1. Documentation Principale (3 fichiers)

| Fichier | Taille | Description | Utilisation |
|---------|--------|-------------|-------------|
| **README_ZIGBEE_RECONSTRUCTION.md** | 14 KB | Index général de toute la documentation | Point d'entrée principal |
| **ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md** | 17 KB | Guide complet étape par étape | Suivre pour reconstruction complète |
| **QUICK_START.md** | 4.4 KB | Version condensée du guide | Pour les utilisateurs expérimentés |

**Recommandation** :
- Débutants → Commencer par `README_ZIGBEE_RECONSTRUCTION.md`
- Expérimentés → Aller directement à `QUICK_START.md`
- Besoin de détails → Consulter `ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md`

---

### 2. Checklists et Templates (2 fichiers)

| Fichier | Taille | Description | Utilisation |
|---------|--------|-------------|-------------|
| **CHECKLIST_REASSOCIATION.md** | 9.3 KB | Checklist détaillée avec cases à cocher | Imprimer ou afficher pour suivre la progression |
| **NETWORK_MAP_TEMPLATE.md** | 12 KB | Template pour documenter le réseau | Remplir après reconstruction pour archivage |
| **PORTS_CONFIGURATION.md** | 10 KB | Configuration complète des ports utilisés | Consulter avant d'ajouter un service |

**Recommandation** :
- Imprimer `CHECKLIST_REASSOCIATION.md` avant de commencer
- Remplir `NETWORK_MAP_TEMPLATE.md` après reconstruction

---

### 3. Références Techniques (2 fichiers)

| Fichier | Taille | Description | Utilisation |
|---------|--------|-------------|-------------|
| **RESET_PROCEDURES.md** | 12 KB | Procédures de reset par marque d'appareil | Consulter lors de l'appairage |
| **MCP_COMMANDS_REFERENCE.md** | 15 KB | Commandes MCP Home Assistant | Si serveur MCP configuré |

**Recommandation** :
- Garder `RESET_PROCEDURES.md` ouvert pendant la réassociation
- `MCP_COMMANDS_REFERENCE.md` pour automatisation avancée

---

### 4. Configuration (2 fichiers)

| Fichier | Taille | Description | Utilisation |
|---------|--------|-------------|-------------|
| **zigbee2mqtt_configuration.yaml** | 2.7 KB | Configuration complète Zigbee2MQTT | Copier dans l'add-on Z2M |
| **secrets_template.yaml** | 661 B | Template pour secrets | Adapter et copier dans /config/secrets.yaml |

**Recommandation** :
- Copier `zigbee2mqtt_configuration.yaml` tel quel dans Z2M
- Adapter `secrets_template.yaml` avec vos mots de passe

---

### 5. Scripts de Diagnostic (2 fichiers)

| Fichier | Taille | Description | Utilisation |
|---------|--------|-------------|-------------|
| **diagnostic_zigbee2mqtt.sh** | 6.9 KB | Script diagnostic Bash (Linux/macOS) | Exécuter avant de commencer |
| **diagnostic_zigbee2mqtt.ps1** | 7.6 KB | Script diagnostic PowerShell (Windows) | Exécuter avant de commencer |

**Recommandation** :
- Exécuter le script approprié pour diagnostiquer l'état initial
- Réexécuter après reconstruction pour validation

---

## Arborescence de la Documentation

```
c:\DATAS\AI\Projets\Perso\Domotique\
│
├── INDEX_DOCUMENTATION.md (ce fichier)
│
├── Documentation Principale
│   ├── README_ZIGBEE_RECONSTRUCTION.md (COMMENCER ICI)
│   ├── ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md (guide complet)
│   └── QUICK_START.md (version rapide)
│
├── Checklists et Templates
│   ├── CHECKLIST_REASSOCIATION.md (à imprimer)
│   ├── NETWORK_MAP_TEMPLATE.md (à remplir)
│   └── PORTS_CONFIGURATION.md (référence des ports)
│
├── Références Techniques
│   ├── RESET_PROCEDURES.md (procédures appairage)
│   └── MCP_COMMANDS_REFERENCE.md (commandes MCP)
│
├── Configuration
│   ├── zigbee2mqtt_configuration.yaml (config Z2M)
│   └── secrets_template.yaml (template secrets)
│
├── Scripts de Diagnostic
│   ├── diagnostic_zigbee2mqtt.sh (Bash)
│   └── diagnostic_zigbee2mqtt.ps1 (PowerShell)
│
└── Rapports de Maintenance
    └── CORRECTION_PORT_8099_RAPPORT.md (correction 2025-12-18)
```

---

## Flux de Travail Recommandé

### Préparation (15 minutes)

1. **Lire** : `README_ZIGBEE_RECONSTRUCTION.md`
2. **Imprimer** : `CHECKLIST_REASSOCIATION.md`
3. **Avoir accessible** : `RESET_PROCEDURES.md`

### Diagnostic Initial (5 minutes)

4. **Exécuter** :
   - Windows : `diagnostic_zigbee2mqtt.ps1`
   - Linux/macOS : `diagnostic_zigbee2mqtt.sh`

5. **Corriger** les problèmes détectés avant de continuer

### Configuration (10 minutes)

6. **Copier** : `zigbee2mqtt_configuration.yaml` → Add-on Zigbee2MQTT
7. **Adapter** : `secrets_template.yaml` → `/config/secrets.yaml`
8. **Démarrer** : Add-on Zigbee2MQTT
9. **Valider** : Logs sans erreurs

### Réassociation (45 minutes)

10. **Suivre** : `CHECKLIST_REASSOCIATION.md` (cocher au fur et à mesure)
11. **Référer** : `RESET_PROCEDURES.md` (procédures par marque)
12. **Phase 1** : Routeurs mesh (PRIORITÉ)
13. **Attendre** : 5-10 minutes (stabilisation mesh)
14. **Phase 2** : Capteurs (un par un)

### Validation (10 minutes)

15. **Désactiver** : Mode appairage
16. **Nettoyer** : Entités orphelines
17. **Vérifier** : Carte réseau (Map)
18. **Tester** : Tous les appareils

### Documentation (10 minutes)

19. **Remplir** : `NETWORK_MAP_TEMPLATE.md`
20. **Sauvegarder** : Home Assistant (snapshot complet)
21. **Archiver** : Toute la documentation

---

## Commandes Rapides

### Accès aux Interfaces Web

```bash
# Coordinateur
http://192.168.0.166

# Home Assistant
http://homeassistant.local:8123

# Zigbee2MQTT (Port 8100 - le 8099 est utilisé par HA Vibecode Agent)
http://homeassistant.local:8100
```

### Diagnostic (CLI Home Assistant)

```bash
# État de Zigbee2MQTT
ha addons info core_zigbee2mqtt

# Logs de Zigbee2MQTT
ha addons logs core_zigbee2mqtt

# Redémarrer Zigbee2MQTT
ha addons restart core_zigbee2mqtt
```

### Activer le Mode Appairage

**Interface Web** : http://homeassistant.local:8100 → "Permit Join (All)"

**MQTT** :
```bash
mosquitto_pub -h localhost -t 'zigbee2mqtt/bridge/request/permit_join' \
  -m '{"value": true}' -u homeassistant -P VOTRE_MOT_DE_PASSE
```

---

## Résumé par Type d'Utilisateur

### Utilisateur Débutant

**Suivre dans l'ordre** :
1. `README_ZIGBEE_RECONSTRUCTION.md` (comprendre la vue d'ensemble)
2. `ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md` (guide détaillé)
3. `CHECKLIST_REASSOCIATION.md` (cocher les étapes)
4. `RESET_PROCEDURES.md` (quand nécessaire)

**Durée** : 1h30 (avec lecture)

### Utilisateur Intermédiaire

**Suivre dans l'ordre** :
1. `QUICK_START.md` (version condensée)
2. `CHECKLIST_REASSOCIATION.md` (suivre la progression)
3. `RESET_PROCEDURES.md` (référence au besoin)

**Durée** : 1h00

### Utilisateur Avancé

**Suivre dans l'ordre** :
1. `diagnostic_zigbee2mqtt.ps1` ou `.sh` (diagnostic)
2. `QUICK_START.md` (rappel des étapes)
3. `MCP_COMMANDS_REFERENCE.md` (automatisation MCP)

**Durée** : 45 minutes (avec automatisation)

---

## Points d'Attention Critiques

### ORDRE D'APPAIRAGE

**TOUJOURS** :
1. Routeurs mesh EN PREMIER
2. Attendre 5-10 minutes
3. Capteurs ENSUITE

**POURQUOI** :
- Les routeurs créent le réseau mesh
- Les capteurs ont besoin du mesh

### SÉCURITÉ

- Désactiver `permit_join` après reconstruction
- Ne jamais partager `secrets.yaml`
- Sauvegarder régulièrement

### VALIDATION

- Vérifier LQI > 50 pour tous les appareils
- Tester ON/OFF des routeurs
- Observer pendant 1 heure (stabilité)

---

## Support

### Problème durant la reconstruction ?

1. **Consulter** : Section "Résolution de problèmes" dans `ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md`
2. **Vérifier** : Logs Zigbee2MQTT (`ha addons logs core_zigbee2mqtt`)
3. **Rechercher** : Forum Zigbee2MQTT (https://github.com/Koenkk/zigbee2mqtt/discussions)

### Questions sur une procédure spécifique ?

- **Appairage** → `RESET_PROCEDURES.md`
- **Configuration** → `ZIGBEE2MQTT_RECONSTRUCTION_GUIDE.md` (Étape 3)
- **MCP** → `MCP_COMMANDS_REFERENCE.md`
- **Validation** → `CHECKLIST_REASSOCIATION.md` (Phase 4)

---

## Maintenance de la Documentation

### Mise à jour recommandée

- **Après chaque reconstruction** : Documenter les procédures qui ont fonctionné
- **Nouveaux appareils** : Ajouter à `RESET_PROCEDURES.md`
- **Changements de config** : Mettre à jour `zigbee2mqtt_configuration.yaml`

### Archivage

Sauvegarder cette documentation avec :
- Snapshots Home Assistant
- Configuration Zigbee2MQTT
- `NETWORK_MAP_TEMPLATE.md` rempli

---

## Statistiques de la Documentation

| Métrique | Valeur |
|----------|--------|
| Nombre de fichiers | 11 |
| Taille totale | ~100 KB |
| Pages estimées (imprimées) | ~80 pages |
| Durée de lecture complète | ~2 heures |
| Durée d'exécution | 1h15 |
| Couverture | Installation, Configuration, Appairage, Validation, Dépannage |

---

## Checklist Avant de Commencer

- [ ] Tous les fichiers téléchargés/accessibles
- [ ] `CHECKLIST_REASSOCIATION.md` imprimée ou affichée
- [ ] `RESET_PROCEDURES.md` ouvert et accessible
- [ ] Interfaces Web accessibles (HA, Z2M, Coordinateur)
- [ ] Scripts de diagnostic exécutés
- [ ] Temps disponible : minimum 1h30
- [ ] Sauvegarde Home Assistant récente
- [ ] Tous les appareils Zigbee physiquement accessibles

---

## Résultat Attendu

Après avoir suivi cette documentation :

- [ ] Réseau Zigbee2MQTT opérationnel
- [ ] 2 routeurs mesh Online
- [ ] 7 capteurs Online et remontant des données
- [ ] Réseau mesh correctement formé
- [ ] Entités MQTT nettoyées
- [ ] Documentation du réseau complétée
- [ ] Sauvegarde effectuée

---

**Version de la documentation** : 1.0
**Créée le** : 2025-12-18
**Dernière mise à jour** : 2025-12-18
**Prochaine révision** : Après reconstruction

---

**Prêt à commencer ? Ouvrez README_ZIGBEE_RECONSTRUCTION.md**
