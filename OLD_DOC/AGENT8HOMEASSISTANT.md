name: Multimodel Config
version: 1.0.0
schema: v1

# COMPLETION AUTOMATIQUE ULTRA-RAPIDE (GROQ)
autocomplete:
  providers:
    - provider: groq
      model: llama-3.1-8b-instant

models:
  # Ultra rapide → parfait pour coder, refactorer, compléter
  - name: Groq Code HA
    provider: groq
    model: llama-3.1-8b-instant
    apiKey: ${GROQ_API_KEY}          # ← Variable .env
    contextLength: 4000              # ← Anti-TPM
    completionTokens: 1000           # ← Réponses courtes
    systemMessage: "Réponds en 3 phrases max."

  # Modèle Groq maximal (raisonnement + code)
  - name: Groq Llama 3.1 405B
    provider: groq
    model: llama-3.1-405b
    apiKey: ${GROQ_API_KEY}

  # Raisonnement profond et architecture
  - name: Gemini 2.5 Pro
    provider: google
    model: gemini-2.5-pro
    apiKey: ${GOOGLE_API_KEY}

  # Vision + rapidité
  - name: Gemini 2.0 Flash
    provider: google
    model: gemini-2.0-flash
    apiKey: ${GOOGLE_API_KEY}

agents:
  # Agent de raisonnement → utilise automatiquement Gemini 2.5 Pro
  - name: reasoning
    model: Gemini 2.5 Pro
    goal: >
      Réaliser des tâches nécessitant un raisonnement avancé :
      analyse technique, architecture, compréhension complexe,
      refactoring structuré, planification multi-étapes.

  # ⚡ Agent rapide → Groq 8B (temps de réponse < 100 ms)
  - name: speed
    model: Groq Code HA
    goal: >
      Répondre très rapidement aux demandes de complétion, correction rapide,
      debugging, réponses courtes et efficaces.

  # Génération de code haut niveau → Groq 405B
  - name: codegen
    model: Groq Llama 3.1 405B
    goal: >
      Écrire du code complexe, générer des modules entiers,
      expliquer et améliorer des structures ou architectures.

  # 👁 Analyse d'images
  - name: vision
    model: Gemini 2.0 Flash
    goal: >
      Traiter ou analyser des images et capturer les informations visuelles.

  # 🏠🔧 Agent INFRADOMOTIQUE COMPLET
  - name: infra-domotique
    description: >
      Agent expert en architecture Home Assistant, Docker, réseau, MQTT, Zigbee2MQTT
      et conception d'un homelab domotique complet.
    model: Gemini 2.5 Pro
    instructions: |
      Tu es un architecte d'infrastructure domotique complet pour un homelab.

      Contexte général :
      - L'utilisateur utilise Home Assistant en conteneur Docker dans un environnement type homelab.
      - Il utilise aussi d'autres services comme Portainer, VSCode (code-server), éventuellement Ollama, reverse proxy, etc.
      - L'ensemble tourne sur Linux avec docker ou docker-compose, et souvent des images linuxserver.io.

      Ce que tu dois faire :
      - Concevoir, expliquer et améliorer l'architecture globale de la stack domotique.
      - Proposer des fichiers docker-compose complets, cohérents et lisibles.
      - Gérer les aspects réseau : ports, réseaux docker (bridge, custom networks), reverse proxy éventuel.
      - Intégrer Home Assistant proprement (volumes /config, timezone, réseau).
      - Proposer des bonnes pratiques de sécurité de base (utilisateur non-root, gestion des secrets, droits des volumes).
      - Montrer comment connecter les services entre eux (ex : Home Assistant ↔ MQTT ↔ Zigbee2MQTT, etc.).
      - Quand c'est pertinent, proposer aussi la partie Home Assistant (YAML d'intégration, automations).

      Style de réponse :
      - Toujours commencer par une vue d'ensemble : "Architecture proposée" sous forme de liste ou schéma textuel.
      - Ensuite, donner les fichiers concrets (docker-compose, YAML Home Assistant, etc.) en blocs complets.
      - Expliquer brièvement chaque bloc (ports, volumes, sécurité, dépendances).
      - Ne jamais proposer uniquement un extrait fragmenté si l'utilisateur demande une stack complète.

      Contraintes :
      - YAML strictement valide (indentation par espaces, pas de tab).
      - En docker-compose, utiliser au minimum la version 3.7 ou plus.
      - Bien séparer :
        - le réseau "frontend" (reverse proxy, accès web)
        - le réseau "backend" (Home Assistant, bases de données, services internes).
      - Signaler si un redémarrage des conteneurs ou de Home Assistant est nécessaire.

      Types de tâches typiques :
      - Proposer une stack complète : Home Assistant + Portainer + VSCode + reverse proxy.
      - Intégrer un nouveau service : MQTT, Zigbee2MQTT, ESPHome, InfluxDB, Grafana.
      - Optimiser la résilience : volumes, backups, séparation des responsabilités.
      - Analyser un docker-compose existant et proposer une version plus propre et robuste.

# MCP HOME ASSISTANT ✅
mcpServers:
  - name: home-assistant
    command: npx
    args:
      - -y
      - "@coolver/home-assistant-mcp@latest"
    env:
      HA_AGENT_URL: "http://192.168.0.166:8099"
      HA_AGENT_KEY: "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"

# rules:
#  - exclude:
#      - "/opt/home-automation/portainer/data/tls"
#      - "/opt/home-automation/portainer/data/docker_config"
#      - "/opt/home-automation/portainer/data"
#      - "/opt/home-automation/portainer"
#      - "**/tls"
#      - "**/docker_config"
#      - "**/.git"
#      - "**/node_modules"
#      - "**/dist"
