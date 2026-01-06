# GUIDE D'INSTALLATION - ALERTES MODE VACANCES

## FICHIERS CRÉÉS

J'ai créé 4 fichiers pour toi:

### 1. Automations (à installer dans Home Assistant)

- **[automation_alerte_vacances_22h.yaml](automation_alerte_vacances_22h.yaml)**
  - Alerte à 22h si mode vacances toujours actif
  - Notifications: Telegram + iPhone + Persistante HA

- **[automation_notification_mode_vacances_active.yaml](automation_notification_mode_vacances_active.yaml)**
  - Notification quand mode vacances est activé
  - Remplace l'ancienne automation Telegram

- **[automation_action_iphone_desactiver_vacances.yaml](automation_action_iphone_desactiver_vacances.yaml)**
  - Permet de désactiver le mode vacances depuis la notification iPhone
  - Bouton "Désactiver maintenant" dans la notification

### 2. Badge Dashboard

- **[lovelace_badge_mode_vacances.yaml](lovelace_badge_mode_vacances.yaml)**
  - Carte badge rouge visible uniquement quand mode vacances actif
  - 3 versions: animée, simple, compacte

---

## INSTALLATION ÉTAPE PAR ÉTAPE

### ÉTAPE 1: Installer les automations

#### Option A: Via l'interface Home Assistant (RECOMMANDÉ)

1. **Ouvrir Home Assistant:**
   - Aller sur https://ha.cartier-fred.info
   - Se connecter

2. **Accéder aux automations:**
   - Menu → Paramètres → Automations et scènes
   - Cliquer sur "+ CRÉER UNE AUTOMATION" (en bas à droite)
   - Cliquer sur les 3 points en haut à droite
   - Sélectionner "Modifier au format YAML"

3. **Pour chaque fichier d'automation:**

   **a) Alerte 22h:**
   - Copier tout le contenu de `automation_alerte_vacances_22h.yaml`
   - Coller dans l'éditeur YAML
   - Cliquer sur "ENREGISTRER"
   - Donner un nom: "Alerte - Mode Vacances actif (22h)"

   **b) Notification activation:**
   - Répéter avec `automation_notification_mode_vacances_active.yaml`
   - Nom: "Notification - Mode Vacances ACTIVÉ"

   **c) Action iPhone:**
   - Répéter avec `automation_action_iphone_desactiver_vacances.yaml`
   - Nom: "Action iPhone - Désactiver Mode Vacances"

4. **Vérifier:**
   - Les 3 nouvelles automations apparaissent dans la liste
   - Elles sont automatiquement ACTIVÉES (état ON)

#### Option B: Via le fichier automations.yaml

1. **Ouvrir le fichier automations.yaml:**
   ```
   Configuration → Modificateur de fichiers → automations.yaml
   ```

2. **Ajouter à la fin du fichier:**
   - Copier le contenu des 3 fichiers YAML
   - Les coller à la fin de `automations.yaml`
   - Sauvegarder

3. **Recharger les automations:**
   - Outils de développement → YAML
   - Cliquer sur "AUTOMATIONS" → Recharger

---

### ÉTAPE 2: Installer le badge dashboard

#### Méthode rapide (Interface UI):

1. **Aller sur le dashboard principal:**
   - https://ha.cartier-fred.info

2. **Passer en mode édition:**
   - Cliquer sur les 3 points (⋮) en haut à droite
   - Sélectionner "Modifier le tableau de bord"

3. **Ajouter la carte:**
   - Cliquer sur "+ AJOUTER UNE CARTE"
   - Descendre tout en bas
   - Cliquer sur "MANUEL"

4. **Copier-coller le code:**
   - Ouvrir `lovelace_badge_mode_vacances.yaml`
   - Copier la PREMIÈRE carte (jusqu'à la ligne `---`)
   - Coller dans l'éditeur
   - Cliquer sur "ENREGISTRER"

5. **Positionner la carte:**
   - Glisser-déposer la carte EN HAUT du dashboard
   - Cliquer sur "TERMINÉ" en haut à droite

6. **Tester:**
   - Activer le mode vacances
   - Le badge rouge devrait apparaître immédiatement
   - Désactiver le mode vacances
   - Le badge devrait disparaître

---

### ÉTAPE 3: Configurer les notifications iPhone

#### Vérifier le nom de votre appareil:

1. **Dans Home Assistant:**
   - Menu → Paramètres → Appareils et services
   - Chercher "mobile_app"
   - Cliquer dessus

2. **Trouver votre iPhone:**
   - Regarder la liste des appareils
   - Le nom est du type: `mobile_app_iphone_xxxx`

3. **Nom déjà configuré:**
   - Les automations utilisent: `notify.mobile_app_iphone_fredo`
   - C'est le bon service pour ton iPhone
   - Si tu as plusieurs iPhones disponibles:
     - `notify.mobile_app_iphone_5`
     - `notify.mobile_app_iphone_de_loann`
     - `notify.mobile_app_2107113sg`
     - `notify.mobile_app_iphone_fredo` ✅ (configuré)

#### Tester la notification iPhone:

1. **Aller dans Outils de développement → Services**

2. **Sélectionner le service:** `notify.mobile_app_iphone_fredo`

3. **Copier ce code dans "Données du service":**
   ```yaml
   title: Test notification
   message: Ceci est un test
   data:
     actions:
       - action: TEST
         title: Bouton test
   ```

4. **Cliquer sur "APPELER LE SERVICE"**

5. **Vérifier:**
   - Notification reçue sur iPhone
   - Bouton "Bouton test" visible

Si ça ne marche pas:
- Vérifier que l'app Home Assistant est installée sur iPhone
- Vérifier les autorisations notifications dans Réglages iOS
- Vérifier que l'iPhone est bien connecté à Home Assistant

---

## TESTS À FAIRE

### Test 1: Notification activation mode vacances

1. Activer le mode vacances manuellement
2. Vérifications:
   - ✅ Notification Telegram reçue sur chat 8486475897
   - ✅ Notification iPhone reçue avec bouton "Désactiver"
   - ✅ Badge rouge apparaît sur le dashboard

### Test 2: Bouton iPhone désactiver

1. Sur la notification iPhone, appuyer sur "Désactiver"
2. Vérifications:
   - ✅ Mode vacances se désactive dans HA
   - ✅ Notification de confirmation reçue
   - ✅ Badge rouge disparaît du dashboard

### Test 3: Alerte 22h (test manuel)

1. Activer le mode vacances
2. Aller dans Automations → "Alerte - Mode Vacances actif (22h)"
3. Cliquer sur "EXÉCUTER"
4. Vérifications:
   - ✅ Notification Telegram reçue avec texte d'alerte
   - ✅ Notification iPhone reçue
   - ✅ Notification persistante dans HA

### Test 4: Alerte 22h (test réel)

1. Activer le mode vacances avant 22h
2. Attendre 22h00
3. Vérifications:
   - ✅ Les 3 notifications sont envoyées automatiquement

---

## DÉSINSTALLER L'ANCIENNE AUTOMATION

Tu as déjà une automation `Telegram - Chauffage OFF (Vacances)` (ID: 1766101683414).

La nouvelle automation `Notification - Mode Vacances ACTIVÉ` la remplace avec plus de fonctionnalités.

### Pour désactiver l'ancienne:

1. Menu → Paramètres → Automations et scènes
2. Chercher "Telegram - Chauffage OFF (Vacances)"
3. Cliquer dessus
4. Cliquer sur le bouton ON/OFF en haut à droite pour la DÉSACTIVER
5. Ou la supprimer complètement (bouton poubelle)

**Note:** La nouvelle automation fait la même chose + notifications iPhone + lien direct.

---

## PERSONNALISATION

### Changer l'heure de l'alerte:

Dans `automation_alerte_vacances_22h.yaml`, ligne 4:
```yaml
at: "22:00:00"  # Changer pour "21:00:00" par exemple
```

### Changer le message Telegram:

Modifier le texte dans la section `message:` de chaque automation.

### Ajouter d'autres notifications:

Ajouter dans la section `action:`:
```yaml
- service: notify.all_devices
  data:
    title: Mode Vacances actif
    message: Alerte!
```

### Changer le style du badge:

Dans `lovelace_badge_mode_vacances.yaml`:
- Couleur de fond: `background: #ff0000` (rouge)
- Bordure: `border: 4px solid #ffa500` (orange)
- Animation: Supprimer la section `animation: pulse 2s infinite`

---

## DÉPANNAGE

### Les notifications Telegram ne fonctionnent pas:

1. Vérifier que le chat_id est correct: `8486475897`
2. Tester manuellement:
   ```yaml
   service: telegram_bot.send_message
   data:
     chat_id: 8486475897
     message: Test
   ```

### Les notifications iPhone ne fonctionnent pas:

1. Vérifier le nom de l'appareil (voir ÉTAPE 3)
2. Vérifier que l'app HA est installée et connectée
3. Tester avec une notification simple d'abord

### Le badge ne s'affiche pas:

1. Vérifier que le mode vacances est bien activé
2. Vider le cache du navigateur (Ctrl+F5)
3. Essayer l'alternative simple (sans card_mod)

### L'automation ne se déclenche pas à 22h:

1. Vérifier que l'automation est activée (état ON)
2. Vérifier l'heure du serveur HA:
   ```
   Outils de développement → États
   Chercher "sensor.time"
   ```
3. Regarder les traces d'exécution:
   - Automation → Cliquer sur l'automation → Onglet "Traces"

---

## RÉSUMÉ

### Ce qui va se passer maintenant:

1. **Quand tu actives le mode vacances:**
   - Badge rouge apparaît sur le dashboard
   - Notification Telegram envoyée
   - Notification iPhone avec bouton désactiver

2. **Tous les soirs à 22h (si mode vacances actif):**
   - Alerte Telegram rappel
   - Alerte iPhone rappel
   - Notification persistante dans HA

3. **Depuis la notification iPhone:**
   - Tu peux désactiver le mode vacances en 1 clic
   - Confirmation immédiate

4. **Sur le dashboard:**
   - Impossible de rater que le mode vacances est actif
   - Lien direct pour le désactiver

---

## FICHIERS CRÉÉS POUR TOI

```
C:\DATAS\AI\Projets\Perso\Domotique\
├── automation_alerte_vacances_22h.yaml
├── automation_notification_mode_vacances_active.yaml
├── automation_action_iphone_desactiver_vacances.yaml
├── lovelace_badge_mode_vacances.yaml
├── GUIDE_INSTALLATION_ALERTES_VACANCES.md (ce fichier)
├── REPONSE_MODE_VACANCES.md
├── RAPPORT_MODE_VACANCES.md
├── DIAGNOSTIC_BROADLINK_FINAL.md
└── ... (autres scripts)
```

---

## BESOIN D'AIDE?

Si tu rencontres un problème:
1. Vérifier les logs HA: Paramètres → Système → Logs
2. Tester les automations manuellement (bouton "Exécuter")
3. Vérifier que toutes les entités existent:
   - `input_boolean.mode_vacance`
   - `notify.mobile_app_iphone_de_fredo`
   - Chat Telegram 8486475897

Tout est prêt à être installé! 🚀
