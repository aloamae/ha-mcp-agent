# Option 1 : Winget
winget install Ollama

# Option 2 : Direct
iwr -useb https://ollama.ai/install.ps1 | iex


ollama pull llama3.2:1b     # Ultra-léger, rapide
ollama pull llama3.2:3b     # Meilleur équilibre
ollama pull gemma2:2b       # Google Gemma rapide
ollama list                 # Vérifier

```yaml
name: Ollama Local
version: 1.0.0
schema: v1

models:
  - name: Llama Local 1B
    provider: ollama
    model: llama3.2:1b      # TPM ∞ local !

  - name: Llama Local 3B
    provider: ollama
    model: llama3.2:3b

  - name: Gemma Local
    provider: ollama
    model: gemma2:2b

autocomplete:
  providers:
    - provider: ollama
      model: llama3.2:1b

# Votre MCP HA reste !
mcpServers:
  - name: home-assistant
    command: npx
    args:
      - -y
      - "@coolver/home-assistant-mcp@latest"
    env:
      HA_AGENT_URL: "http://192.168.0.166:8099"
      HA_AGENT_KEY: "jZT5-o3QZOXj00id5Z8_QOU1topknUozOWIL6QL-pl4"
```


Ctrl+Shift+P → "Continue: Restart"
Sélectionnez "Llama Local 1B"
"@home-assistant entities list"  # ← FONCTIONNE !


ollama ps                   # Modèles actifs
ollama run llama3.2:1b "test" # Test direct
ollama pull qwen2.5:3b      # Plus de modèles


@home-assistant entities list     # MCP instantané
@infra-domotique docker-compose HA  # Agent local
Tab sur code                      # Autocomplete local


commande contiue MCP
@home-assistant <commande>  # Dans Continue chat
/mcp home-assistant <commande>


###############
📋 COMANDES ESSENTIELLES
ENTITIES (Entités)
text
@home-assistant entities list                    # Toutes les entités
@home-assistant entities list --domain light     # Lampes seulement
@home-assistant entities list --domain switch    # Interrupteurs
@home-assistant entities list --area salon       # Zone salon
@home-assistant entity light.salon state         # État lampe salon
@home-assistant entity light.salon attributes    # Attributs
STATES (États)
text
@home-assistant states light.salon               # État actuel
@home-assistant states --domain light            # États toutes lampes
@home-assistant states --changed-last 1h         # Changés 1h
AREAS & DEVICES
text
@home-assistant areas list                       # Toutes les zones
@home-assistant devices list                     # Tous les appareils
@home-assistant areas salon entities             # Entités zone salon
@home-assistant device <device_id> entities      # Entités appareil
SERVICES (Actions)
text
@home-assistant services list                    # Tous les services
@home-assistant service light.turn_on light.salon # Allumer lampe
@home-assistant service light.turn_off light.salon # Éteindre
@home-assistant service notify.notify allume salon # Notification
CONFIG & INFO
text
@home-assistant config                           # Config HA
@home-assistant version                          # Version HA
@home-assistant integrations list                # Intégrations
@home-assistant zones list                       # Zones
@home-assistant automations list                 # Automatisations
🔥 COMMANDE HA PARFAIT (Votre agent)
text
@infra-domotique List all HA entities via MCP    # Agent + MCP
@infra-domotique Create light   salon   # Agent génère YAML
@infra-domotique HA + MQTT + Zigbee2MQTT stack   # Stack complète
⚡ EXEMPLES PRATIQUES
text
# 1. Inventaire complet
@home-assistant entities list --domain light,switch

# 2. État salon
@home-assistant entities list --area salon

# 3. Allumer tout
@home-assistant service light.turn_on --entity_id light.salon,light.cuisine

# 4. Debug
@home-assistant entity light.salon attributes
📊 RÉSUMÉ RAPIDE
Catégorie	Commande
Tout	entities list
Lampes	entities list --domain light
Zones	areas list
Allumer	service light.turn_on light.salon
État	states light.salon
Appareils	devices list
🎯 TEST MAINTENANT
text
@home-assistant entities list  # ← PREMIÈRE commande