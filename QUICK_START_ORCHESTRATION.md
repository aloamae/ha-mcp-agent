# Quick Start - Réparation Chauffage et Broadlink

**Temps total**: 30 minutes
**Objectif**: Réparer rapidement les climatisations Broadlink

---

## En 3 Commandes

```powershell
# 1. Définir le token (PowerShell)
$env:HA_TOKEN = "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"

# 2. Naviguer vers le répertoire
cd "c:\DATAS\AI\Projets\Perso\Domotique"

# 3. Exécuter le diagnostic Broadlink
.\check_broadlink_status.ps1
```

**Résultat** : Vous saurez exactement quel est le problème.

---

## Réparation Rapide (10 minutes)

### Problème #1 : Remote Entity OFF

**Symptôme** : "remote entity is turned off"

**Solution Express** :
```powershell
# Activer tous les remote en une fois
$body = @{
    entity_id = @("remote.clim_salon", "remote.clim_maeva", "remote.clim_axel")
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://192.168.0.166:8123/api/services/homeassistant/turn_on" `
    -Headers @{ "Authorization" = "Bearer $env:HA_TOKEN"; "Content-Type" = "application/json" } `
    -Method Post -Body $body
```

✅ **Fait** : Les 3 remote sont maintenant ON.

---

### Problème #2 : Network Timeout Broadlink Maeva

**Symptôme** : "Network timeout at 192.168.0.136"

**Solution Express** :
1. Aller dans la chambre Maeva
2. Débrancher le Broadlink RM4 Pro
3. Attendre 10 secondes
4. Rebrancher
5. Attendre 30 secondes

✅ **Test** :
```powershell
Test-Connection -ComputerName 192.168.0.136 -Count 4
```

Si ping OK → Passer à l'étape suivante

---

### Problème #3 : Intégration Broadlink HA

**Symptôme** : Après redémarrage Broadlink, HA ne le détecte pas

**Solution Express** :
1. Ouvrir Home Assistant (http://192.168.0.166:8123)
2. **Paramètres** → **Appareils et services**
3. Trouver **Broadlink**
4. Cliquer sur **⋮** (3 points) → **Recharger**
5. Attendre 10 secondes

✅ **Fait** : Intégration Broadlink rechargée.

---

## Test Final (5 minutes)

### Tester Climatisation Salon

1. Ouvrir Home Assistant
2. Carte `climate.climatisation_salon`
3. Mode : **Heat**
4. Température : **22°C**
5. **Observer le climatiseur physique**

✅ Si le climatiseur démarre → **SUCCÈS**
❌ Si rien ne se passe → Voir dépannage ci-dessous

### Tester Climatisation Maeva

Répéter test pour `climate.climatisation_maeva`

### Tester Climatisation Axel

Répéter test pour `climate.climatisation_axel`

---

## Dépannage Express

### Le climatiseur ne démarre toujours pas

**Vérifier** :
```powershell
# État du remote
Invoke-RestMethod -Uri "http://192.168.0.166:8123/api/states/remote.clim_salon" `
    -Headers @{ "Authorization" = "Bearer $env:HA_TOKEN" } | Select-Object entity_id, state
```

**Résultat attendu** : `state = "on"`

**Si OFF** : Répéter activation (voir Problème #1)

---

### Commande manuelle de test

```powershell
# Envoyer commande IR manuelle
$body = @{
    entity_id = "remote.clim_salon"
    command = "power"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://192.168.0.166:8123/api/services/remote/send_command" `
    -Headers @{ "Authorization" = "Bearer $env:HA_TOKEN"; "Content-Type" = "application/json" } `
    -Method Post -Body $body
```

✅ Si climatiseur démarre → Configuration OK, problème ailleurs
❌ Si rien → Vérifier codes IR SmartIR

---

## Aide Approfondie

Si problème persiste après Quick Start :

1. Lire `DIAGNOSTIC_BROADLINK.md` (plan d'action complet)
2. Exécuter collecte complète :
   ```powershell
   .\collect_automation_data.ps1
   .\analyze_automation_details.ps1
   ```
3. Consulter `README_ORCHESTRATION_COMPLETE.md`

---

## Résumé des Actions

| Action | Durée | Statut |
|--------|-------|--------|
| Définir token HA | 30 sec | ⏳ |
| Exécuter diagnostic | 2 min | ⏳ |
| Activer remote entities | 2 min | ⏳ |
| Redémarrer Broadlink Maeva | 3 min | ⏳ |
| Recharger intégration HA | 2 min | ⏳ |
| Tester 3 climatisations | 5 min | ⏳ |
| **TOTAL** | **15 min** | |

---

## Commandes Utiles

### Vérifier État Remote

```powershell
$remotes = @("remote.clim_salon", "remote.clim_maeva", "remote.clim_axel")
foreach ($r in $remotes) {
    $s = Invoke-RestMethod -Uri "http://192.168.0.166:8123/api/states/$r" -Headers @{"Authorization"="Bearer $env:HA_TOKEN"}
    Write-Host "$r : $($s.state)" -ForegroundColor $(if($s.state -eq "on"){"Green"}else{"Red"})
}
```

### Vérifier État Climate

```powershell
$climates = @("climate.climatisation_salon", "climate.climatisation_maeva", "climate.climatisation_axel")
foreach ($c in $climates) {
    $s = Invoke-RestMethod -Uri "http://192.168.0.166:8123/api/states/$c" -Headers @{"Authorization"="Bearer $env:HA_TOKEN"}
    Write-Host "$c : $($s.state) ($($s.attributes.current_temperature)°C)" -ForegroundColor Cyan
}
```

---

## Next Steps

Après réparation rapide :

1. ✅ Réserver adresses IP DHCP (éviter futurs timeouts)
2. ✅ Ajouter monitoring (automation de surveillance)
3. ✅ Documenter codes IR (backup SmartIR)
4. ✅ Lire documentation complète

---

**Document créé le** : 2025-12-19
**Pour** : Réparation rapide en 15 minutes
**Statut** : Prêt à exécuter

⚡ **START NOW** : `.\check_broadlink_status.ps1`
