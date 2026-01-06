**PROBLÈME** : Continue fusionne **TOUS** les `config.yaml` → **conflit global + workspace** = **erreurs persistantes** !

## 🧹 **NETTOYAGE COMPLET** (3 étapes)

### **1. SUPPRIMER config.yaml GLOBAL**
```powershell
Remove-Item "C:\Users\fcartier\.continue\config.yaml" -Force
Remove-Item "C:\Users\fcartier\.continue\config.yml" -Force  # Ancien format
```

### **2. Garder UNIQUEMENT workspace**
```
C:\DATAS\AI\Projets\Perso\Domotique\.continue\config.yaml
```
**Votre config OLLAMA** → **SEUL fichier actif**

### **3. Vérification structure**
```
📁 C:\Users\fcartier\.continue/
├── ❌ SUPPRIMÉ : config.yaml
└── .env (optionnel)

📁 Domotique\.continue/
├── ✅ config.yaml (OLLAMA + MCP HA)
└── .env (optionnel)
```

## 🔄 **Redémarrage**
```
Ctrl+Shift+P → "Developer: Reload Window"
Ctrl+Shift+P → "Continue: Restart"
```

## ✅ **Vérification**
```
"Continue: Open Config" → Doit ouvrir SEULEMENT :
C:\DATAS\AI\Projets\Perso\Domotique\.continue\config.yaml
```

## 🎯 **Résultat attendu**
```
Sélectionnez "Llama3.2 1B" → "@home-assistant entities list" → ✅ FONCTIONNE
```

**1 config.yaml = 1 workspace = ZÉRO conflit** 🚀[1]

**Exécutez les 2 Remove-Item MAINTENANT** !

[1](https://docs.continue.dev/guides/understanding-configs)