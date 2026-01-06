# Guide de Configuration MCP pour Gemini / Home Assistant

Ce guide explique comment connecter l'agent Gemini (ou tout client MCP) à votre instance locale Home Assistant.

## Prérequis

1. **Node.js** doit être installé sur votre machine Windows.
   - Vérifier dans PowerShell : `node --version`
2. **Accès réseau** : La machine doit pouvoir accéder à `http://192.168.0.166:8123`.

## Étape 1 : Générer le Token Home Assistant

Le serveur MCP a besoin d'un jeton d'accès longue durée pour agir en votre nom.

1. Ouvrez votre Home Assistant : http://192.168.0.166:8123
2. Cliquez sur votre **Profil** (vos initiales en bas à gauche de la barre latérale).
3. Descendez jusqu'à la section **Jetons d'accès longue durée**.
4. Cliquez sur **CRÉER UN JETON**.
5. Nommez-le (ex: `MCP_Gemini_Agent`).
6. **Copiez le jeton immédiatement** (il ne sera plus jamais affiché).

## Étape 2 : Mettre à jour la configuration

1. Ouvrez le fichier `c:\DATAS\AI\Projets\Perso\Domotique\home-assistant-mcp-config.json`.
2. Remplacez `<VOTRE_TOKEN_LONGUE_DUREE>` par le jeton copié à l'étape 1.
3. Sauvegardez le fichier.

## Étape 3 : Test de connexion (Optionnel mais recommandé)

Pour vérifier que la configuration fonctionne avant de l'intégrer à l'IDE ou à l'agent, vous pouvez lancer le serveur manuellement dans PowerShell pour voir s'il démarre sans erreur.

```powershell
# Définir les variables temporairement pour le test
$env:HA_URL = "http://192.168.0.166:8123"
$env:HA_TOKEN = "coller_votre_token_ici"

# Lancer le serveur (Ctrl+C pour arrêter)
npx -y @modelcontextprotocol/server-home-assistant
```

*Si le serveur démarre et attend (curseur clignotant ou logs JSON), c'est que la connexion est réussie.*

## Étape 4 : Utilisation avec Gemini / Clients MCP

Selon l'outil que vous utilisez pour interagir avec Gemini (VS Code, Claude Desktop, ou un script Python custom) :

### Cas A : Configuration standard (Fichier JSON)
Copiez le contenu de `home-assistant-mcp-config.json` dans le fichier de configuration de votre outil MCP (souvent situé dans `%APPDATA%\Code\User\globalStorage\...` ou défini dans les settings de l'extension).

### Cas B : Agent Vibecode existant (Port 8099)
Votre audit mentionne un agent existant sur le port 8099 (`home-assistant-vibecode-agent`).
Si vous préférez utiliser cet agent déjà configuré plutôt que le serveur officiel via `npx`, configurez votre client MCP ainsi :

- **Type** : SSE (Server-Sent Events)
- **URL** : `http://localhost:8099/sse`
```