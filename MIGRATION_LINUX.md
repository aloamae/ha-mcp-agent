# Guide de Migration vers Linux

Ce guide explique comment transférer tout votre projet domotique (scripts, docs, configs) vers votre nouvelle machine Linux et configurer l'accès MCP pour Gemini.

## Prérequis

1. **Accès SSH** fonctionnel vers votre machine Linux.
2. **PowerShell** sur votre machine Windows.
3. **Adresse IP** de la machine Linux (ex: `192.168.0.XXX`).

## Étape 1 : Lancer le déploiement

Depuis votre terminal PowerShell dans le dossier du projet :

```powershell
.\deploy_to_linux.ps1 -LinuxIP "192.168.0.XXX" -LinuxUser "votre_nom_utilisateur"
```

*Remplacez `192.168.0.XXX` et `votre_nom_utilisateur` par vos informations réelles.*

Le script va :
1. Compresser tout le projet.
2. L'envoyer sur le Linux dans `~/domotique_project`.
3. Décompresser et lancer le script d'installation `linux_setup.sh`.

## Étape 2 : Configuration MCP sur Linux

Une fois sur Linux, pour que Gemini (dans VS Code ou autre) puisse interagir avec votre Home Assistant :

1. Ouvrez le dossier `~/domotique_project` dans VS Code (ou votre IDE).
2. Un fichier `mcp_linux_config.json` a été généré automatiquement.
3. Il contient la configuration standard pour se connecter à votre Home Assistant (192.168.0.166).

### Si vous utilisez l'extension MCP dans VS Code :
Copiez le contenu de `mcp_linux_config.json` dans la configuration de l'extension.

### Si vous utilisez l'agent Vibecode (Port 8099) :
L'agent Vibecode tourne sur votre serveur Home Assistant. Depuis votre Linux, vous pouvez y accéder via :
- URL : `http://192.168.0.166:8099`
- Clé : (Celle présente dans `home-assistant-mcp-config.json`)

## Vérification

Sur votre machine Linux, lancez :
```bash
ls -l ~/domotique_project
```
Vous devriez voir tous vos fichiers `.md`, `.ps1`, `.yaml` et les scripts de configuration.