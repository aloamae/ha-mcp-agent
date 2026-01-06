# FICHIERS À SUPPRIMER - NETTOYAGE

**Date:** 21 décembre 2025
**Total:** 16 fichiers obsolètes

---

## ❌ LISTE COMPLÈTE

### Automations Chauffage GAZ (Anciennes versions)
1. `automation_chauffage_FINAL_avec_mode_manuel.yaml`
2. `automation_chauffage_GAZ_FINAL.yaml`
3. `automation_chauffage_GAZ_v2.yaml`
4. `automation_chauffage_pilotage_chaudiere_corrigee.yaml`

### Automations Climatisation SALON (Anciennes versions)
5. `automation_climatisation_SALON.yaml`
6. `automation_climatisation_SALON_sans_logs.yaml`
7. `automation_climatisation_SALON_v2.yaml`

### Automations Climatisation AXEL (Anciennes versions)
8. `automation_climatisation_AXEL.yaml`
9. `automation_climatisation_AXEL_sans_logs.yaml`
10. `automation_climatisation_AXEL_v2.yaml`

### Automations Climatisation MAEVA (Anciennes versions)
11. `automation_climatisation_MAEVA.yaml`
12. `automation_climatisation_MAEVA_sans_logs.yaml`
13. `automation_climatisation_MAEVA_v2.yaml`

### Automations Départ/Retour (Anciennes versions)
14. `automation_depart_simple.yaml`
15. `automation_depart_corrigee.yaml`
16. `automation_retour_corrigee.yaml`

---

## ✅ FICHIERS À GARDER

### Automations Principales (V3 - Les plus récentes)
- `automation_chauffage_GAZ_v3.yaml`
- `automation_climatisation_SALON_v3.yaml`
- `automation_climatisation_AXEL_v3.yaml`
- `automation_climatisation_MAEVA_v3.yaml`

### Automations Départ/Retour (FINAL)
- `automation_depart_retour_FINAL.yaml`

### Automations Vacances
- `automation_alerte_vacances_22h.yaml`
- `automation_notification_mode_vacances_active.yaml`
- `automation_action_iphone_desactiver_vacances.yaml`

### Automations Broadlink
- `automation_activer_remotes_demarrage.yaml`
- `automation_reactiver_remotes_broadlink.yaml`
- `automation_maintenir_remotes_broadlink.yaml`

---

## 🗑️ PROCÉDURE SUPPRESSION

**IMPORTANT:** Supprimer les fichiers SEULEMENT si les versions V3 sont bien installées dans Home Assistant!

```powershell
# Vérifier d'abord dans Home Assistant:
# Automations → Vérifier présence de:
# - Chauffage - Pilotage Chaudiere GAZ
# - Climatisation - Pilotage Salon
# - Climatisation - Pilotage Axel
# - Climatisation - Pilotage Maeva

# Ensuite supprimer les fichiers (dans PowerShell):
cd C:\DATAS\AI\Projets\Perso\Domotique

Remove-Item automation_chauffage_FINAL_avec_mode_manuel.yaml
Remove-Item automation_chauffage_GAZ_FINAL.yaml
Remove-Item automation_chauffage_GAZ_v2.yaml
Remove-Item automation_chauffage_pilotage_chaudiere_corrigee.yaml

Remove-Item automation_climatisation_SALON.yaml
Remove-Item automation_climatisation_SALON_sans_logs.yaml
Remove-Item automation_climatisation_SALON_v2.yaml

Remove-Item automation_climatisation_AXEL.yaml
Remove-Item automation_climatisation_AXEL_sans_logs.yaml
Remove-Item automation_climatisation_AXEL_v2.yaml

Remove-Item automation_climatisation_MAEVA.yaml
Remove-Item automation_climatisation_MAEVA_sans_logs.yaml
Remove-Item automation_climatisation_MAEVA_v2.yaml

Remove-Item automation_depart_simple.yaml
Remove-Item automation_depart_corrigee.yaml
Remove-Item automation_retour_corrigee.yaml
```
