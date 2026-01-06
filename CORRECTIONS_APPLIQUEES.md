# CORRECTIONS APPLIQUÉES - AUTOMATIONS MODE VACANCES

## PROBLÈME RENCONTRÉ

Home Assistant affichait l'erreur:
```
L'automatisation utilise une action inconnue : notify.mobile_app_iphone_de_fredo
```

## CAUSE

Le service de notification iPhone s'appelle **`mobile_app_iphone_fredo`** (sans "de_").

J'avais utilisé le mauvais nom: `mobile_app_iphone_de_fredo`

## SERVICES DE NOTIFICATION DISPONIBLES

Sur ton système Home Assistant, voici les services notify disponibles:

### Pour iPhone/Mobile:
- ✅ **`notify.mobile_app_iphone_fredo`** → Ton iPhone (UTILISÉ)
- `notify.mobile_app_iphone_5` → iPhone (5)
- `notify.mobile_app_iphone_de_loann` → iPhone de Loann
- `notify.mobile_app_2107113sg` → Autre appareil

### Général:
- `notify.notify` → Tous les appareils
- `notify.persistent_notification` → Notifications dans HA

## CORRECTIONS EFFECTUÉES

J'ai corrigé le nom du service dans les 3 fichiers:

### 1. automation_alerte_vacances_22h.yaml
**Avant:**
```yaml
- service: notify.mobile_app_iphone_de_fredo
```

**Après:**
```yaml
- service: notify.mobile_app_iphone_fredo
```

### 2. automation_notification_mode_vacances_active.yaml
**Avant:**
```yaml
- service: notify.mobile_app_iphone_de_fredo
```

**Après:**
```yaml
- service: notify.mobile_app_iphone_fredo
```

### 3. automation_action_iphone_desactiver_vacances.yaml
**Avant:**
```yaml
- service: notify.mobile_app_iphone_de_fredo
```

**Après:**
```yaml
- service: notify.mobile_app_iphone_fredo
```

## MARCHE À SUIVRE

### Si les automations sont DÉJÀ installées dans Home Assistant:

#### Option 1: Réinstaller (RECOMMANDÉ)

1. **Supprimer les anciennes automations:**
   - Menu → Paramètres → Automations et scènes
   - Chercher "Mode Vacances"
   - Supprimer les 3 automations avec erreur

2. **Réinstaller avec les fichiers corrigés:**
   - Suivre le GUIDE_INSTALLATION_ALERTES_VACANCES.md
   - Utiliser les fichiers YAML mis à jour

#### Option 2: Modifier manuellement

Pour chaque automation qui a l'erreur:

1. **Ouvrir l'automation:**
   - Menu → Paramètres → Automations et scènes
   - Cliquer sur l'automation

2. **Passer en mode YAML:**
   - 3 points en haut à droite
   - "Modifier au format YAML"

3. **Remplacer le service:**
   - Chercher: `notify.mobile_app_iphone_de_fredo`
   - Remplacer par: `notify.mobile_app_iphone_fredo`

4. **Sauvegarder:**
   - Cliquer sur "ENREGISTRER"
   - L'erreur devrait disparaître

### Si les automations ne sont PAS encore installées:

✅ **Rien à faire!** Les fichiers sont déjà corrigés.

Installe-les normalement en suivant le guide.

## VÉRIFICATION

Pour vérifier que tout fonctionne:

### Test rapide:

1. **Ouvrir Outils de développement → Services**

2. **Service:** `notify.mobile_app_iphone_fredo`

3. **Données:**
   ```yaml
   title: Test notification
   message: Si tu reçois ce message, tout fonctionne!
   ```

4. **Cliquer sur "APPELER LE SERVICE"**

5. **Vérifier:**
   - ✅ Notification reçue sur ton iPhone
   - ✅ Pas d'erreur dans les logs HA

### Test avec action (bouton):

```yaml
title: Test avec bouton
message: Appuie sur le bouton pour tester
data:
  actions:
    - action: TEST_ACTION
      title: Bouton test
```

Si tu reçois la notification avec le bouton "Bouton test", c'est parfait!

## FICHIERS CORRIGÉS

Tous les fichiers YAML ont été mis à jour:

```
✅ automation_alerte_vacances_22h.yaml
✅ automation_notification_mode_vacances_active.yaml
✅ automation_action_iphone_desactiver_vacances.yaml
✅ GUIDE_INSTALLATION_ALERTES_VACANCES.md
```

Tu peux maintenant les installer sans erreur!

## EN CAS DE PROBLÈME

Si les notifications iPhone ne fonctionnent toujours pas:

1. **Vérifier que l'app Home Assistant est installée sur l'iPhone**

2. **Vérifier que l'iPhone est connecté à HA:**
   - Paramètres → Appareils et services
   - Chercher "mobile_app"
   - Vérifier que "iPhone fredo" apparaît

3. **Vérifier les autorisations iOS:**
   - Réglages iOS → Home Assistant
   - Notifications → Activées

4. **Réinstaller l'app si nécessaire:**
   - Supprimer l'app
   - Réinstaller depuis App Store
   - Se reconnecter à HA

## RÉSUMÉ

✅ **Problème identifié:** Mauvais nom de service
✅ **Correction appliquée:** `mobile_app_iphone_fredo` (au lieu de `mobile_app_iphone_de_fredo`)
✅ **Fichiers mis à jour:** 3 automations + 1 guide
✅ **Prêt à installer:** Tous les fichiers sont maintenant corrects

Tu peux installer les automations sans erreur maintenant!
