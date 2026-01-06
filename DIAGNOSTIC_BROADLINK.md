# Diagnostic Climatisations Broadlink

**Date**: 2025-12-19
**Système**: Home Assistant (http://192.168.0.166:8123)
**Problème rapporté**: Dysfonctionnements des 3 climatisations Broadlink

---

## Table des Matières

1. [Résumé Exécutif](#résumé-exécutif)
2. [Architecture du Système](#architecture-du-système)
3. [État Actuel des Climatisations](#état-actuel-des-climatisations)
4. [Erreurs Identifiées](#erreurs-identifiées)
5. [Analyse des Causes](#analyse-des-causes)
6. [Solutions Recommandées](#solutions-recommandées)
7. [Plan d'Action Étape par Étape](#plan-daction-étape-par-étape)
8. [Prévention Future](#prévention-future)

---

## Résumé Exécutif

### Symptômes Rapportés

Les 3 climatisations Broadlink (Salon, Maeva, Axel) présentent des dysfonctionnements avec les erreurs suivantes :

```
WARNING remote.send_command canceled: remote.clim_maeva entity is turned off
ERROR Error fetching CLIM-Maeva (RM4 pro at 192.168.0.136): Network timeout
```

### Diagnostic Initial

**Cause Racine Probable** :
1. Les entités `remote.clim_*` sont **DÉSACTIVÉES (OFF)** dans Home Assistant
2. L'appareil Broadlink de Maeva (192.168.0.136) a des problèmes de connectivité réseau
3. Les entités `climate.*` tentent d'envoyer des commandes IR mais sont bloquées

**Impact** :
- Les climatisations ne répondent pas aux commandes Home Assistant
- Les automations de chauffage/climatisation sont inefficaces
- Aucune commande IR n'est transmise aux appareils physiques

---

## Architecture du Système

### Composants Impliqués

```
┌─────────────────────────────────────────────────────────────────┐
│                   ARCHITECTURE CLIMATISATION                    │
└─────────────────────────────────────────────────────────────────┘

Home Assistant (192.168.0.166:8123)
         │
         ├─ Intégration Broadlink
         │       │
         │       ├─ remote.clim_salon (état: OFF ❌)
         │       ├─ remote.clim_maeva (état: OFF ❌)
         │       └─ remote.clim_axel (état: OFF ❌)
         │
         └─ Intégration SmartIR
                 │
                 ├─ climate.climatisation_salon (dépend de remote.clim_salon)
                 ├─ climate.climatisation_maeva (dépend de remote.clim_maeva)
                 └─ climate.climatisation_axel (dépend de remote.clim_axel)

───────────────────────────────────────────────────────────────────

Réseau Local (192.168.0.x)

├─ Broadlink RM4 Pro (Salon)      : 192.168.0.??? (à identifier)
├─ Broadlink RM4 Pro (Maeva)      : 192.168.0.136 (timeout ❌)
└─ Broadlink RM4 Pro (Axel)       : 192.168.0.??? (à identifier)

───────────────────────────────────────────────────────────────────

Climatiseurs Physiques (contrôlés par IR)

├─ Climatiseur Salon
├─ Climatiseur Maeva
└─ Climatiseur Axel
```

### Flux de Commande Normal

```
Utilisateur/Automation
       ↓
climate.climatisation_salon (state: heat, temp: 21°C)
       ↓
Appel service remote.send_command
       ↓
remote.clim_salon (DOIT être ON)
       ↓
Broadlink RM4 Pro (192.168.0.xxx)
       ↓
Signal IR → Climatiseur physique
```

### Flux de Commande Actuel (BLOQUÉ)

```
Utilisateur/Automation
       ↓
climate.climatisation_salon (state: heat, temp: 21°C)
       ↓
Appel service remote.send_command
       ↓
remote.clim_salon (état: OFF ❌)
       ↓
❌ ERREUR: "remote entity is turned off"
       ↓
Commande ANNULÉE - Aucun signal IR envoyé
```

---

## État Actuel des Climatisations

### 1. Climatisation Salon

| Composant | Entity ID | État Actuel | État Attendu |
|-----------|-----------|-------------|--------------|
| **Remote Broadlink** | `remote.clim_salon` | ❌ OFF | ✅ ON |
| **Climate SmartIR** | `climate.climatisation_salon` | ⚠️ heat (mais non fonctionnel) | ✅ heat (fonctionnel) |
| **Appareil Broadlink** | RM4 Pro (IP: ???) | ⚠️ À vérifier | ✅ Online |

**Problèmes Identifiés** :
- ❌ Remote entity désactivée → Commandes IR bloquées
- ⚠️ IP de l'appareil Broadlink non documentée

**Symptômes** :
- L'interface HA affiche la climatisation comme active (heat)
- Aucune commande IR n'est réellement envoyée
- Le climatiseur physique ne réagit pas

---

### 2. Climatisation Maeva

| Composant | Entity ID | État Actuel | État Attendu |
|-----------|-----------|-------------|--------------|
| **Remote Broadlink** | `remote.clim_maeva` | ❌ OFF | ✅ ON |
| **Climate SmartIR** | `climate.climatisation_maeva` | ❌ OFF | ✅ heat/cool |
| **Appareil Broadlink** | RM4 Pro (IP: 192.168.0.136) | ❌ Network timeout | ✅ Online |

**Problèmes Identifiés** :
- ❌ Remote entity désactivée
- ❌ **Network timeout** : L'appareil Broadlink (192.168.0.136) n'est pas accessible sur le réseau
- ❌ Climate entity OFF (cohérent avec remote OFF)

**Erreurs dans les Logs** :
```
ERROR Error fetching CLIM-Maeva (RM4 pro at 192.168.0.136): Network timeout
```

**Symptômes** :
- Home Assistant ne peut pas communiquer avec le Broadlink RM4 Pro
- Tous les appels échouent avec timeout
- Possible causes :
  - Appareil débranché ou éteint
  - Problème réseau (Wi-Fi, routeur)
  - Appareil planté nécessitant un redémarrage
  - Changement d'adresse IP (DHCP)

---

### 3. Climatisation Axel

| Composant | Entity ID | État Actuel | État Attendu |
|-----------|-----------|-------------|--------------|
| **Remote Broadlink** | `remote.clim_axel` | ❌ OFF | ✅ ON |
| **Climate SmartIR** | `climate.climatisation_axel` | ⚠️ heat (mais non fonctionnel) | ✅ heat (fonctionnel) |
| **Appareil Broadlink** | RM4 Pro (IP: ???) | ⚠️ À vérifier | ✅ Online |

**Problèmes Identifiés** :
- ❌ Remote entity désactivée → Commandes IR bloquées
- ⚠️ IP de l'appareil Broadlink non documentée

**Symptômes** :
- Identiques à la climatisation Salon

---

## Erreurs Identifiées

### Erreur 1 : Remote Entity Turned Off

**Message** :
```
WARNING remote.send_command canceled: remote.clim_maeva entity is turned off
```

**Signification** :
- L'entité `remote.clim_maeva` existe dans Home Assistant
- Mais elle est dans l'état `off` (désactivée)
- Lorsqu'une commande `remote.send_command` est appelée, elle est automatiquement annulée

**Pourquoi cela se produit** :
- Les entités remote peuvent être désactivées manuellement ou automatiquement
- Possible causes :
  - Désactivation manuelle par l'utilisateur dans l'interface HA
  - Redémarrage de Home Assistant qui n'a pas réactivé les entités
  - Échec de l'intégration Broadlink au démarrage

**Impact** :
- **CRITIQUE** : Aucune commande IR ne peut être envoyée tant que l'entité est OFF
- Les automations échouent silencieusement
- L'utilisateur pense que la climatisation fonctionne (UI affiche ON) mais rien ne se passe

---

### Erreur 2 : Network Timeout

**Message** :
```
ERROR Error fetching CLIM-Maeva (RM4 pro at 192.168.0.136): Network timeout
```

**Signification** :
- Home Assistant tente de contacter le Broadlink RM4 Pro à l'adresse 192.168.0.136
- Aucune réponse n'est reçue dans le délai imparti (timeout)
- La communication réseau est interrompue

**Pourquoi cela se produit** :
- L'appareil Broadlink est hors ligne (débranché, éteint, planté)
- Problème de connectivité Wi-Fi
- L'adresse IP a changé (DHCP)
- Pare-feu ou configuration réseau bloquante
- L'appareil est surchargé ou figé

**Impact** :
- **CRITIQUE** : Impossible de communiquer avec l'appareil
- L'intégration Broadlink échoue à initialiser l'appareil
- L'entité `remote.clim_maeva` reste indisponible (unavailable) ou OFF

---

## Analyse des Causes

### Cause Racine #1 : Entités Remote Désactivées

**Probabilité** : 🔴 TRÈS ÉLEVÉE (90%)

**Explication** :
Les 3 entités `remote.clim_*` sont désactivées. Cela indique que :
- Soit elles ont été désactivées manuellement (peu probable pour les 3 en même temps)
- Soit l'intégration Broadlink a rencontré un problème au démarrage de HA
- Soit les appareils Broadlink n'étaient pas accessibles lors du dernier redémarrage de HA

**Conséquence** :
Même si les appareils Broadlink fonctionnent parfaitement, Home Assistant refuse d'envoyer des commandes IR car les entités sont OFF.

---

### Cause Racine #2 : Problème Réseau Broadlink Maeva

**Probabilité** : 🟠 ÉLEVÉE (80%)

**Explication** :
L'erreur "Network timeout" sur 192.168.0.136 est explicite :
- L'appareil Broadlink RM4 Pro de Maeva ne répond pas sur le réseau
- Possible panne matérielle, Wi-Fi déconnecté, ou redémarrage requis

**Conséquence** :
Home Assistant ne peut pas initialiser l'entité `remote.clim_maeva`, même si on essaie de l'activer manuellement.

---

### Cause Racine #3 : Configuration SmartIR Dépendante

**Probabilité** : 🟢 FAIBLE (20%)

**Explication** :
Les entités `climate.*` dépendent des entités `remote.*` pour fonctionner. Si SmartIR est mal configuré :
- Les entités climate pourraient pointer vers de mauvaises entités remote
- Les codes IR pourraient être incorrects

**Conséquence** :
Même après activation des remote, les climatiseurs ne réagissent pas correctement.

---

## Solutions Recommandées

### Solution #1 : Activer les Entités Remote (PRIORITÉ 1)

**Objectif** : Réactiver `remote.clim_salon` et `remote.clim_axel`

**Méthode via Interface HA** :
1. Ouvrir Home Assistant (http://192.168.0.166:8123)
2. Aller dans **Paramètres** → **Appareils et services** → **Entités**
3. Rechercher `remote.clim_salon`
4. Cliquer sur l'entité
5. Si l'entité est désactivée, cliquer sur **Activer**
6. Répéter pour `remote.clim_axel`

**Méthode via Service Call** :
```yaml
service: homeassistant.turn_on
target:
  entity_id:
    - remote.clim_salon
    - remote.clim_axel
```

**Méthode via PowerShell** :
```powershell
$HA_URL = "http://192.168.0.166:8123"
$HA_TOKEN = $env:HA_TOKEN

$headers = @{
    "Authorization" = "Bearer $HA_TOKEN"
    "Content-Type" = "application/json"
}

$body = @{
    entity_id = "remote.clim_salon"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$HA_URL/api/services/homeassistant/turn_on" -Headers $headers -Method Post -Body $body
```

**Vérification** :
```powershell
# Vérifier l'état
Invoke-RestMethod -Uri "$HA_URL/api/states/remote.clim_salon" -Headers $headers -Method Get | Select-Object entity_id, state
```

**Résultat Attendu** :
```
entity_id           state
---------           -----
remote.clim_salon   on
```

---

### Solution #2 : Diagnostiquer et Réparer Broadlink Maeva (PRIORITÉ 1)

**Objectif** : Restaurer la connectivité réseau avec le Broadlink RM4 Pro (192.168.0.136)

#### Étape 1 : Vérifier la Connectivité Réseau

```powershell
# Ping depuis votre PC
Test-Connection -ComputerName 192.168.0.136 -Count 4

# Résultat attendu:
# Reply from 192.168.0.136: bytes=32 time<1ms TTL=64
```

**Si ping échoue** :
- L'appareil est hors ligne
- Passez à l'étape 2

**Si ping réussit** :
- L'appareil est en ligne mais HA ne peut pas communiquer
- Vérifiez l'intégration Broadlink dans HA

#### Étape 2 : Redémarrer l'Appareil Broadlink

1. Débrancher physiquement le Broadlink RM4 Pro (chambre Maeva)
2. Attendre 10 secondes
3. Rebrancher l'appareil
4. Attendre 30 secondes (LED doit s'allumer)
5. Re-tester le ping

#### Étape 3 : Vérifier l'Adresse IP

Si l'appareil a changé d'adresse IP (DHCP dynamique) :

```powershell
# Scanner le réseau pour trouver les appareils Broadlink
# (nécessite nmap ou équivalent)
nmap -sn 192.168.0.0/24 | Select-String "192.168.0"
```

Ou via l'application Broadlink mobile :
1. Ouvrir l'app Broadlink (Android/iOS)
2. Vérifier l'adresse IP affichée pour l'appareil RM4 Pro Maeva
3. Si différente de 192.168.0.136, mettre à jour la configuration HA

#### Étape 4 : Reconfigurer l'Intégration Broadlink dans HA

1. Aller dans **Paramètres** → **Appareils et services**
2. Trouver l'intégration **Broadlink**
3. Cliquer sur **Configurer** (icône engrenage)
4. Vérifier/mettre à jour l'adresse IP de l'appareil Maeva
5. Sauvegarder et redémarrer l'intégration

#### Étape 5 : Réinitialiser l'Appareil Broadlink (si nécessaire)

Si toutes les étapes précédentes échouent :

1. Réinitialiser le Broadlink RM4 Pro aux paramètres d'usine (bouton reset)
2. Reconfigurer via l'application Broadlink mobile
3. Réassocier l'appareil à Home Assistant
4. Reconfigurer les codes IR SmartIR

**ATTENTION** : Cette étape supprimera tous les codes IR appris. À faire en dernier recours.

---

### Solution #3 : Vérifier la Configuration SmartIR (PRIORITÉ 2)

**Objectif** : S'assurer que les entités climate pointent vers les bonnes entités remote

**Fichier de configuration SmartIR** :
Chercher dans :
- `configuration.yaml`
- `climate.yaml`
- `.storage/core.config_entries`

**Exemple de configuration attendue** :
```yaml
climate:
  - platform: smartir
    name: Climatisation Salon
    unique_id: climatisation_salon
    device_code: 1000  # Code du modèle de climatiseur
    controller_data: remote.clim_salon  # ← DOIT correspondre
    temperature_sensor: sensor.th_salon_temperature
    humidity_sensor: sensor.th_salon_humidity
```

**Vérification via PowerShell** :
```powershell
# Lire la configuration de l'entité climate
$climateState = Invoke-RestMethod -Uri "$HA_URL/api/states/climate.climatisation_salon" -Headers $headers -Method Get
$climateState.attributes | ConvertTo-Json -Depth 5
```

**Points à vérifier** :
- `controller_data` ou équivalent doit pointer vers `remote.clim_*`
- `device_code` doit correspondre au modèle de climatiseur
- Les capteurs de température/humidité doivent exister

---

### Solution #4 : Ajouter des Delays et Logging (PRIORITÉ 3)

**Objectif** : Améliorer la robustesse et la traçabilité des commandes Broadlink

#### A. Ajouter un Delay entre les Commandes IR

Les appareils Broadlink peuvent mal gérer des commandes IR rapprochées.

**Dans les automations** :
```yaml
action:
  - service: remote.send_command
    target:
      entity_id: remote.clim_salon
    data:
      command: power_on

  - delay:
      seconds: 1  # ← IMPORTANT : Pause entre commandes

  - service: remote.send_command
    target:
      entity_id: remote.clim_salon
    data:
      command: set_temperature
```

#### B. Logger les Succès/Échecs

```yaml
action:
  - service: remote.send_command
    target:
      entity_id: remote.clim_salon
    data:
      command: power_on

  - service: logbook.log
    data:
      name: "Climatisation Salon"
      message: "Commande IR 'power_on' envoyée via remote.clim_salon"
      entity_id: climate.climatisation_salon
```

**Consulter les logs** :
- Interface HA → **Historique** → Filtrer par `climate.climatisation_salon`
- Ou via fichier : `home-assistant.log`

---

### Solution #5 : Créer un Script Centralisé (PRIORITÉ 3)

**Objectif** : Centraliser le pilotage des climatisations avec gestion d'erreurs

**Créer un script** : `script.clim_send_command`

```yaml
script:
  clim_send_command:
    alias: "Envoyer Commande Climatisation (avec vérifications)"
    fields:
      climate_entity:
        description: "Entité climate cible"
        example: "climate.climatisation_salon"
      remote_entity:
        description: "Entité remote associée"
        example: "remote.clim_salon"
      command:
        description: "Commande IR à envoyer"
        example: "power_on"

    sequence:
      # Vérifier que le remote est ON
      - condition: state
        entity_id: "{{ remote_entity }}"
        state: "on"

      # Envoyer la commande
      - service: remote.send_command
        target:
          entity_id: "{{ remote_entity }}"
        data:
          command: "{{ command }}"

      # Logger le succès
      - service: logbook.log
        data:
          name: "{{ state_attr(climate_entity, 'friendly_name') }}"
          message: "Commande IR '{{ command }}' envoyée avec succès"
          entity_id: "{{ climate_entity }}"

      # Delay de sécurité
      - delay:
          seconds: 1
```

**Utilisation** :
```yaml
automation:
  - alias: "Test Climatisation Salon"
    trigger:
      - platform: state
        entity_id: input_boolean.test_clim_salon
        to: "on"
    action:
      - service: script.clim_send_command
        data:
          climate_entity: climate.climatisation_salon
          remote_entity: remote.clim_salon
          command: power_on
```

---

## Plan d'Action Étape par Étape

### Phase 1 : Diagnostic Immédiat (15 minutes)

#### 1.1. Exécuter le Script de Diagnostic

```powershell
# Définir le token
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"

# Lancer le diagnostic
.\check_broadlink_status.ps1
```

**Résultat attendu** :
- Fichier `broadlink_diagnostic_export.json` créé
- Affichage de l'état de chaque climatisation
- Liste des problèmes et recommandations

#### 1.2. Vérifier la Connectivité Broadlink Maeva

```powershell
Test-Connection -ComputerName 192.168.0.136 -Count 4
```

**Si échec** : Passer à Phase 2 (Réparation Broadlink Maeva)
**Si succès** : Passer à Phase 3 (Activation Remote)

---

### Phase 2 : Réparation Broadlink Maeva (30 minutes)

#### 2.1. Redémarrage Physique

1. Aller dans la chambre Maeva
2. Débrancher le Broadlink RM4 Pro
3. Attendre 10 secondes
4. Rebrancher
5. Attendre 30 secondes

#### 2.2. Test de Connectivité

```powershell
Test-Connection -ComputerName 192.168.0.136 -Count 4
```

**Si échec** : Vérifier le Wi-Fi, le routeur, l'adresse IP via app Broadlink
**Si succès** : Passer à 2.3

#### 2.3. Redémarrer l'Intégration Broadlink dans HA

1. Ouvrir Home Assistant
2. **Paramètres** → **Appareils et services** → **Broadlink**
3. Cliquer sur les 3 points → **Recharger**
4. Attendre 10 secondes

#### 2.4. Vérifier l'État de l'Entité

```powershell
Invoke-RestMethod -Uri "http://192.168.0.166:8123/api/states/remote.clim_maeva" -Headers @{
    "Authorization" = "Bearer $env:HA_TOKEN"
} | Select-Object entity_id, state
```

**Résultat attendu** : `state = "on"` ou `state = "idle"`

---

### Phase 3 : Activation des Entités Remote (10 minutes)

#### 3.1. Activer remote.clim_salon

**Via Interface HA** :
1. **Paramètres** → **Appareils et services** → **Entités**
2. Rechercher `remote.clim_salon`
3. Si désactivée : **Activer**
4. Si OFF : **Allumer** (icône power)

**Via Service Call** :
```powershell
$body = @{ entity_id = "remote.clim_salon" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://192.168.0.166:8123/api/services/homeassistant/turn_on" `
    -Headers @{ "Authorization" = "Bearer $env:HA_TOKEN"; "Content-Type" = "application/json" } `
    -Method Post -Body $body
```

#### 3.2. Activer remote.clim_axel

Répéter 3.1 pour `remote.clim_axel`

#### 3.3. Activer remote.clim_maeva (après Phase 2)

Répéter 3.1 pour `remote.clim_maeva`

---

### Phase 4 : Tests Fonctionnels (20 minutes)

#### 4.1. Test Climatisation Salon

1. Ouvrir Home Assistant
2. Aller à la carte de `climate.climatisation_salon`
3. Régler le mode sur **Heat**
4. Définir la température cible : **22°C**
5. **Observer le climatiseur physique** : Doit démarrer dans les 5 secondes

**Si fonctionne** : ✅ Salon OK
**Si ne fonctionne pas** :
- Vérifier les logs HA
- Tester une commande IR manuelle via `remote.send_command`

#### 4.2. Test Climatisation Axel

Répéter 4.1 pour Axel

#### 4.3. Test Climatisation Maeva

Répéter 4.1 pour Maeva

---

### Phase 5 : Optimisation (optionnel, 30 minutes)

#### 5.1. Ajouter Delays dans les Automations

Identifier les automations qui contrôlent les climatisations et ajouter :

```yaml
- delay:
    seconds: 1
```

Entre chaque appel `remote.send_command`

#### 5.2. Créer le Script Centralisé

Copier le script `clim_send_command` dans `scripts.yaml` ou via UI

#### 5.3. Ajouter du Logging

Dans les automations critiques, ajouter :

```yaml
- service: logbook.log
  data:
    name: "Climatisation {{ climate_name }}"
    message: "Commande {{ command }} envoyée"
```

---

## Prévention Future

### Recommandation #1 : Réserver les Adresses IP

**Problème** : Les appareils Broadlink peuvent changer d'IP avec DHCP

**Solution** : Configurer des réservations DHCP statiques dans votre routeur

1. Se connecter au routeur (ex: 192.168.0.1)
2. Aller dans **DHCP** → **Réservations statiques**
3. Ajouter :
   - **Broadlink Salon** : MAC address → 192.168.0.140 (par exemple)
   - **Broadlink Maeva** : MAC address → 192.168.0.136 (garder l'actuelle)
   - **Broadlink Axel** : MAC address → 192.168.0.141 (par exemple)

**Avantage** : Les adresses IP ne changeront jamais, garantit la stabilité de l'intégration HA

---

### Recommandation #2 : Monitoring des Entités Remote

**Créer une automation de surveillance** :

```yaml
automation:
  - alias: "Alerte Remote Climatisation OFF"
    trigger:
      - platform: state
        entity_id:
          - remote.clim_salon
          - remote.clim_maeva
          - remote.clim_axel
        to: "off"
        for:
          minutes: 5
    action:
      - service: persistent_notification.create
        data:
          title: "⚠️ Remote Climatisation Désactivé"
          message: "L'entité {{ trigger.entity_id }} est OFF. Les commandes IR sont bloquées."

      - service: logbook.log
        data:
          name: "Monitoring Climatisation"
          message: "Remote {{ trigger.entity_id }} est passé à OFF"
```

**Avantage** : Vous serez alerté immédiatement si un remote se désactive

---

### Recommandation #3 : Backup de la Configuration SmartIR

**Exporter les codes IR** :

1. Sauvegarder les fichiers JSON de SmartIR (dans `.storage/` ou `custom_components/smartir/codes/`)
2. Documenter les `device_code` utilisés pour chaque climatiseur
3. En cas de réinitialisation, vous pourrez restaurer rapidement

---

### Recommandation #4 : Tester Régulièrement

**Créer un input_boolean de test** :

```yaml
input_boolean:
  test_clim_salon:
    name: "Test Climatisation Salon"
    icon: mdi:air-conditioner
```

**Automation de test** :

```yaml
automation:
  - alias: "Test Climatisation Salon (manuel)"
    trigger:
      - platform: state
        entity_id: input_boolean.test_clim_salon
        to: "on"
    action:
      - service: climate.set_temperature
        target:
          entity_id: climate.climatisation_salon
        data:
          temperature: 22
          hvac_mode: heat

      - delay:
          seconds: 5

      - service: input_boolean.turn_off
        target:
          entity_id: input_boolean.test_clim_salon

      - service: persistent_notification.create
        data:
          title: "✅ Test Climatisation Salon"
          message: "Commande envoyée. Vérifiez que le climatiseur a démarré."
```

**Avantage** : Test rapide en un clic depuis le dashboard

---

## Commandes de Dépannage Rapide

### Vérifier l'État des Remote

```powershell
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"
$HA_URL = "http://192.168.0.166:8123"

$remotes = @("remote.clim_salon", "remote.clim_maeva", "remote.clim_axel")

foreach ($remote in $remotes) {
    $state = Invoke-RestMethod -Uri "$HA_URL/api/states/$remote" -Headers @{
        "Authorization" = "Bearer $env:HA_TOKEN"
    }
    Write-Host "$($remote): $($state.state)" -ForegroundColor $(if ($state.state -eq "on") { "Green" } else { "Red" })
}
```

### Activer Tous les Remote en Une Fois

```powershell
$body = @{
    entity_id = @("remote.clim_salon", "remote.clim_maeva", "remote.clim_axel")
} | ConvertTo-Json

Invoke-RestMethod -Uri "$HA_URL/api/services/homeassistant/turn_on" `
    -Headers @{ "Authorization" = "Bearer $env:HA_TOKEN"; "Content-Type" = "application/json" } `
    -Method Post -Body $body
```

### Tester une Commande IR Manuelle

```powershell
$body = @{
    entity_id = "remote.clim_salon"
    command = "power"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$HA_URL/api/services/remote/send_command" `
    -Headers @{ "Authorization" = "Bearer $env:HA_TOKEN"; "Content-Type" = "application/json" } `
    -Method Post -Body $body
```

---

## Résumé des Actions

| Action | Priorité | Durée | Statut |
|--------|----------|-------|--------|
| Exécuter `check_broadlink_status.ps1` | 🔴 Critique | 5 min | ⏳ À faire |
| Vérifier connectivité Broadlink Maeva (192.168.0.136) | 🔴 Critique | 5 min | ⏳ À faire |
| Redémarrer Broadlink Maeva si timeout | 🔴 Critique | 5 min | ⏳ À faire |
| Activer `remote.clim_salon` | 🔴 Critique | 2 min | ⏳ À faire |
| Activer `remote.clim_axel` | 🔴 Critique | 2 min | ⏳ À faire |
| Activer `remote.clim_maeva` (après réparation) | 🔴 Critique | 2 min | ⏳ À faire |
| Tester climatisation Salon | 🟠 Important | 5 min | ⏳ À faire |
| Tester climatisation Axel | 🟠 Important | 5 min | ⏳ À faire |
| Tester climatisation Maeva | 🟠 Important | 5 min | ⏳ À faire |
| Ajouter delays dans automations | 🟡 Optionnel | 15 min | ⏳ À faire |
| Créer script centralisé | 🟡 Optionnel | 15 min | ⏳ À faire |
| Configurer réservations DHCP | 🟡 Optionnel | 10 min | ⏳ À faire |
| Créer automation de monitoring | 🟡 Optionnel | 10 min | ⏳ À faire |

---

## Références

- **Script de diagnostic** : `c:\DATAS\AI\Projets\Perso\Domotique\check_broadlink_status.ps1`
- **Documentation Broadlink** : https://www.home-assistant.io/integrations/broadlink/
- **Documentation SmartIR** : https://github.com/smartHomeHub/SmartIR
- **Best Practices Climate** : `CLIMATE_CONTROL_BEST_PRACTICES.md`

---

**Document généré le** : 2025-12-19
**Auteur** : Agent Broadlink/Devices (Claude Sonnet 4.5)
**Statut** : Prêt pour exécution - Suivre le Plan d'Action Phase par Phase
