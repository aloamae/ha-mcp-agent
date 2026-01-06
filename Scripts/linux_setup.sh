#!/bin/bash

# Script d'initialisation de l'environnement Domotique sur Linux
echo "=== CONFIGURATION DE L'ENVIRONNEMENT LINUX ==="

# 1. Vérification de Node.js (Requis pour MCP)
if ! command -v node &> /dev/null; then
    echo "⚠️  Node.js n'est pas installé. Installation recommandée..."
    echo "   Exécutez: sudo apt update && sudo apt install -y nodejs npm"
else
    echo "✅ Node.js est installé: $(node -v)"
fi

# 2. Rendre les scripts exécutables
echo "🔧 Configuration des permissions..."
chmod +x *.sh

# 3. Préparation de la configuration MCP pour Linux
# On adapte le fichier de config Windows pour Linux si nécessaire
if [ -f "home-assistant-mcp-config.json" ]; then
    echo "✅ Configuration MCP détectée."
    # Création d'un fichier de config standard pour les clients MCP (VS Code / Claude)
    # Utilisation de l'agent Vibecode existant sur le port 8099
    
    cat > mcp_linux_config.json <<EOF
{
  "mcpServers": {
    "home-assistant": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-home-assistant"
      ],
      "env": {
        "HA_URL": "http://192.168.0.166:8123",
        "HA_TOKEN": "$(grep -oP '(?<="key": ")[^"]*' home-assistant-mcp-config.json)"
      }
    }
  }
}
EOF
    echo "📄 Fichier 'mcp_linux_config.json' généré pour votre IDE Linux."
fi

echo ""
echo "=== PRÊT ! ==="
echo "Pour utiliser MCP avec Gemini/Claude sur ce Linux :"
echo "1. Ouvrez ce dossier dans VS Code"
echo "2. Configurez l'extension MCP avec le contenu de 'mcp_linux_config.json'"