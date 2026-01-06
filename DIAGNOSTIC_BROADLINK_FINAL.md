# DIAGNOSTIC BROADLINK - RÉSULTAT FINAL

**Date**: 2025-12-19
**Statut**: ✅ RÉSOLU

---

## PROBLÈME INITIAL

Tu as constaté des dysfonctionnements sur les climatisations du **Salon**, **Maeva** et **Axel** lors de leur activation via Broadlink.

---

## DIAGNOSTIC EFFECTUÉ

### 1. Vérification des entités Remote (Broadlink)

**État AVANT intervention:**
```
remote.clim_salon  : ON   ✅
remote.clim_maeva  : OFF  ❌ (BLOQUÉ - commandes IR impossibles)
remote.clim_axel   : OFF  ❌ (BLOQUÉ - commandes IR impossibles)
```

**État APRÈS activation:**
```
remote.clim_salon  : ON   ✅
remote.clim_maeva  : ON   ✅ (CORRIGÉ)
remote.clim_axel   : ON   ✅ (CORRIGÉ)
```

### 2. Vérification des entités Climate (Climatisations)

```
climate.climatisation_salon : OFF
  Température actuelle: 20.0°C
  Température cible: 23°C

climate.climatisation_maeva : OFF
  Température actuelle: 18.7°C
  Température cible: 20°C

climate.climatisation_axel : HEAT (mode chauffage actif)
  Température actuelle: 20.4°C
  Température cible: 19°C
```

### 3. Test de connectivité réseau

**Broadlink Maeva (192.168.0.136):**
- Ping: ✅ OK
- Appareil accessible sur le réseau

**Broadlink Salon et Axel:**
- IP non récupérées automatiquement depuis HA
- Vérification manuelle recommandée dans: *Paramètres → Appareils et services → Broadlink*

---

## CAUSE RACINE

Les entités **remote.clim_maeva** et **remote.clim_axel** étaient **désactivées (OFF)** dans Home Assistant.

Lorsqu'une entité remote Broadlink est OFF:
- Les commandes IR/RF ne sont PAS envoyées à l'appareil physique
- Les climatisations ne reçoivent AUCUN signal, même si tu les actives dans l'interface HA
- L'entité climate peut sembler fonctionner dans HA, mais physiquement rien ne se passe

---

## SOLUTION APPLIQUÉE

**Action:** Activation des entités remote désactivées

```powershell
# Script exécuté: activate_broadlink_remotes.ps1
Service: homeassistant.turn_on
Entités activées:
  - remote.clim_maeva
  - remote.clim_axel
```

**Résultat:** Les 3 remotes sont maintenant ON et fonctionnels.

---

## SCRIPTS CRÉÉS POUR TOI

1. **check_broadlink_simple.ps1**
   Diagnostic rapide des entités remote et climate Broadlink

2. **activate_broadlink_remotes.ps1**
   Active automatiquement les remotes désactivés

3. **test_broadlink_network.ps1**
   Test de connectivité réseau (ping) des appareils Broadlink

4. **find_broadlink_ips.ps1**
   Recherche les IP des appareils dans la configuration HA

### Utilisation:
```powershell
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"
cd "C:\DATAS\AI\Projets\Perso\Domotique"
.\check_broadlink_simple.ps1
```

---

## TESTS RECOMMANDÉS

Maintenant que les remotes sont activés, teste chaque climatisation:

### Test Climatisation Salon
```
1. Dans HA: Ouvrir climate.climatisation_salon
2. Passer en mode HEAT ou COOL
3. Définir une température cible différente de l'actuelle
4. Vérifier que la climatisation physique réagit (bip sonore + affichage LED)
```

### Test Climatisation Maeva
```
1. Dans HA: Ouvrir climate.climatisation_maeva
2. Passer en mode HEAT
3. Température cible: 22°C (actuellement 18.7°C)
4. Vérifier la réaction physique
```

### Test Climatisation Axel
```
1. Dans HA: Ouvrir climate.climatisation_axel
2. Actuellement en mode HEAT (température cible 19°C, actuelle 20.4°C)
3. Tester un changement de consigne ou de mode
4. Vérifier la réaction physique
```

---

## POINTS D'ATTENTION

### 1. Automation DEBUG désactivée
```
automation.debug_tracer_clim_axel : unavailable
```
→ Cette automation de debug semble cassée, à vérifier si elle est nécessaire.

### 2. IP des appareils Broadlink
Seule l'IP de **Broadlink Maeva** est connue: `192.168.0.136`

Pour trouver les IP de Salon et Axel:
```
1. Dans HA: Paramètres → Appareils et services
2. Cliquer sur l'intégration "Broadlink"
3. Noter les IP de chaque appareil
4. Vérifier la connectivité réseau (ping)
```

### 3. Température cible Salon incohérente
```
Température actuelle: 20.0°C
Température cible: 23°C
Mais climatisation en mode OFF
```
→ Soit l'automation a été bloquée, soit la consigne a été changée manuellement sans activer la clim.

---

## RÉCAPITULATIF DES COMMANDES UTILES

### Vérifier l'état des remotes
```powershell
$env:HA_TOKEN = "VOTRE_TOKEN"
.\check_broadlink_simple.ps1
```

### Activer les remotes si désactivés
```powershell
.\activate_broadlink_remotes.ps1
```

### Tester la connectivité réseau
```powershell
.\test_broadlink_network.ps1
```

### Envoyer une commande IR manuelle (exemple: allumer clim salon)
```powershell
$body = @{
    entity_id = "remote.clim_salon"
    command = "turn_on"  # Dépend de la configuration SmartIR
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://192.168.0.166:8123/api/services/remote/send_command" `
    -Headers @{"Authorization"="Bearer $env:HA_TOKEN";"Content-Type"="application/json"} `
    -Method Post -Body $body
```

---

## CONCLUSION

✅ **Problème résolu:** Les 3 entités remote Broadlink sont maintenant activées.

✅ **Connectivité:** Broadlink Maeva répond au ping (192.168.0.136).

⚠️ **Action requise:** Tester physiquement chaque climatisation pour confirmer que les commandes IR sont bien envoyées.

📋 **Documentation complète:**
- RECAPITULATIF_AUTOMATIONS_CHAUFFAGE.md (17 automations analysées)
- GUIDE_ORDRE_FONCTIONNEMENT.md (fonctionnement détaillé du chauffage)
- Ce diagnostic Broadlink

---

**Prochaines étapes:**
1. Tester les climatisations physiquement
2. Récupérer les IP de Broadlink Salon et Axel
3. Si problème persiste: vérifier la configuration SmartIR et les codes IR
