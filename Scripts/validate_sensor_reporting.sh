#!/bin/bash

# Script de validation des intervalles de reporting Zigbee
# Date: 2025-12-18
# Usage: ./validate_sensor_reporting.sh [durée_en_minutes]

set -euo pipefail

# ====================================================================
# CONFIGURATION
# ====================================================================

MQTT_HOST="localhost"
MQTT_PORT=1883
MQTT_USER="homeassistant"
MQTT_PASSWORD="${MQTT_PASSWORD:-}"  # À définir en variable d'environnement

SENSORS=(
    "th_cuisine"
    "th_salon"
    "th_loann"
    "th_meva"
    "th_axel"
    "th_parents"
    "th_terrasse"
)

MONITORING_DURATION=${1:-30}  # Durée de monitoring en minutes (défaut: 30)
OUTPUT_FILE="sensor_reporting_validation_$(date +%Y%m%d_%H%M%S).log"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ====================================================================
# FONCTIONS
# ====================================================================

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$OUTPUT_FILE"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✓${NC} $*" | tee -a "$OUTPUT_FILE"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ✗${NC} $*" | tee -a "$OUTPUT_FILE"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠${NC} $*" | tee -a "$OUTPUT_FILE"
}

check_dependencies() {
    local missing=0

    if ! command -v mosquitto_sub &> /dev/null; then
        log_error "mosquitto_sub n'est pas installé. Installer: apt-get install mosquitto-clients"
        missing=1
    fi

    if ! command -v jq &> /dev/null; then
        log_error "jq n'est pas installé. Installer: apt-get install jq"
        missing=1
    fi

    if [[ $missing -eq 1 ]]; then
        exit 1
    fi

    log_success "Toutes les dépendances sont installées"
}

test_mqtt_connection() {
    log "Test de connexion MQTT à $MQTT_HOST:$MQTT_PORT..."

    if [[ -n "$MQTT_PASSWORD" ]]; then
        if timeout 5 mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" \
            -u "$MQTT_USER" -P "$MQTT_PASSWORD" \
            -t "zigbee2mqtt/bridge/state" -C 1 &> /dev/null; then
            log_success "Connexion MQTT réussie"
            return 0
        fi
    else
        if timeout 5 mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" \
            -t "zigbee2mqtt/bridge/state" -C 1 &> /dev/null; then
            log_success "Connexion MQTT réussie"
            return 0
        fi
    fi

    log_error "Impossible de se connecter au broker MQTT"
    return 1
}

get_sensor_state() {
    local sensor_name=$1
    local mqtt_cmd

    if [[ -n "$MQTT_PASSWORD" ]]; then
        mqtt_cmd="mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASSWORD"
    else
        mqtt_cmd="mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT"
    fi

    timeout 2 $mqtt_cmd -t "zigbee2mqtt/$sensor_name" -C 1 2>/dev/null || echo "{}"
}

monitor_sensor_updates() {
    log "Début du monitoring des capteurs pour $MONITORING_DURATION minutes..."
    log "Fichier de log: $OUTPUT_FILE"
    echo ""

    declare -A last_update
    declare -A update_count
    declare -A last_temperature
    declare -A last_humidity
    declare -A intervals

    # Initialiser les compteurs
    for sensor in "${SENSORS[@]}"; do
        last_update[$sensor]=0
        update_count[$sensor]=0
        last_temperature[$sensor]=""
        last_humidity[$sensor]=""
        intervals[$sensor]=""
    done

    local end_time=$(($(date +%s) + MONITORING_DURATION * 60))
    local mqtt_cmd

    if [[ -n "$MQTT_PASSWORD" ]]; then
        mqtt_cmd="mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASSWORD -v"
    else
        mqtt_cmd="mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -v"
    fi

    # S'abonner à tous les topics des capteurs
    local topics_args=()
    for sensor in "${SENSORS[@]}"; do
        topics_args+=("-t" "zigbee2mqtt/$sensor")
    done

    # Monitoring en temps réel
    $mqtt_cmd "${topics_args[@]}" | while read -r line; do
        # Vérifier si le temps est écoulé
        if [[ $(date +%s) -ge $end_time ]]; then
            break
        fi

        # Parser le message MQTT
        local topic
        topic=$(echo "$line" | awk '{print $1}')
        local payload
        payload=$(echo "$line" | cut -d' ' -f2-)

        # Extraire le nom du capteur
        local sensor_name
        sensor_name=$(echo "$topic" | sed 's|zigbee2mqtt/||')

        # Vérifier si c'est un de nos capteurs
        if [[ " ${SENSORS[*]} " =~ " ${sensor_name} " ]]; then
            local current_time
            current_time=$(date +%s)

            # Extraire température et humidité
            local temperature
            temperature=$(echo "$payload" | jq -r '.temperature // empty' 2>/dev/null || echo "")
            local humidity
            humidity=$(echo "$payload" | jq -r '.humidity // empty' 2>/dev/null || echo "")
            local battery
            battery=$(echo "$payload" | jq -r '.battery // empty' 2>/dev/null || echo "")
            local linkquality
            linkquality=$(echo "$payload" | jq -r '.linkquality // empty' 2>/dev/null || echo "")

            # Calculer l'intervalle depuis la dernière mise à jour
            local interval=0
            if [[ ${last_update[$sensor_name]} -ne 0 ]]; then
                interval=$((current_time - last_update[$sensor_name]))

                # Ajouter l'intervalle à la liste
                if [[ -n "${intervals[$sensor_name]}" ]]; then
                    intervals[$sensor_name]="${intervals[$sensor_name]} $interval"
                else
                    intervals[$sensor_name]="$interval"
                fi
            fi

            last_update[$sensor_name]=$current_time
            ((update_count[$sensor_name]++)) || true

            # Afficher la mise à jour
            local interval_display=""
            if [[ $interval -gt 0 ]]; then
                interval_display="(${interval}s depuis dernière update)"
            fi

            log_success "$sensor_name: T=${temperature}°C H=${humidity}% Batt=${battery}% LQI=${linkquality} $interval_display"

            # Détecter les changements significatifs
            if [[ -n "$temperature" && -n "${last_temperature[$sensor_name]}" ]]; then
                local temp_diff
                temp_diff=$(echo "$temperature - ${last_temperature[$sensor_name]}" | bc 2>/dev/null || echo "0")
                temp_diff=${temp_diff#-}  # Valeur absolue

                if (( $(echo "$temp_diff > 0.5" | bc -l) )); then
                    log_warning "  → Changement température significatif: ${temp_diff}°C"
                fi
            fi

            if [[ -n "$humidity" && -n "${last_humidity[$sensor_name]}" ]]; then
                local hum_diff
                hum_diff=$(echo "$humidity - ${last_humidity[$sensor_name]}" | bc 2>/dev/null || echo "0")
                hum_diff=${hum_diff#-}  # Valeur absolue

                if (( $(echo "$hum_diff > 5" | bc -l) )); then
                    log_warning "  → Changement humidité significatif: ${hum_diff}%"
                fi
            fi

            last_temperature[$sensor_name]=$temperature
            last_humidity[$sensor_name]=$humidity
        fi
    done

    # Afficher le résumé
    echo ""
    log "============================================"
    log "RÉSUMÉ DU MONITORING ($MONITORING_DURATION minutes)"
    log "============================================"
    echo ""

    for sensor in "${SENSORS[@]}"; do
        local count=${update_count[$sensor]}

        if [[ $count -eq 0 ]]; then
            log_error "$sensor: AUCUNE mise à jour reçue"
        else
            # Calculer l'intervalle moyen
            local avg_interval=0
            if [[ -n "${intervals[$sensor]}" ]]; then
                local sum=0
                local num=0
                for val in ${intervals[$sensor]}; do
                    sum=$((sum + val))
                    ((num++)) || true
                done
                if [[ $num -gt 0 ]]; then
                    avg_interval=$((sum / num))
                fi
            fi

            log_success "$sensor: $count mises à jour (intervalle moyen: ${avg_interval}s)"

            # Analyser la qualité
            if [[ $avg_interval -gt 0 ]]; then
                if [[ $avg_interval -le 180 ]]; then
                    log_success "  → Excellent (≤ 3 minutes)"
                elif [[ $avg_interval -le 300 ]]; then
                    log_warning "  → Acceptable (3-5 minutes)"
                elif [[ $avg_interval -le 600 ]]; then
                    log_warning "  → Lent (5-10 minutes)"
                else
                    log_error "  → Très lent (> 10 minutes) - Vérifier LQI ou batterie"
                fi
            fi
        fi
    done

    echo ""
    log "Monitoring terminé. Log complet: $OUTPUT_FILE"
}

# ====================================================================
# DIAGNOSTICS INITIAUX
# ====================================================================

diagnostic_sensors() {
    log "============================================"
    log "DIAGNOSTIC DES CAPTEURS"
    log "============================================"
    echo ""

    for sensor in "${SENSORS[@]}"; do
        log "Vérification de $sensor..."

        local state
        state=$(get_sensor_state "$sensor")

        if [[ "$state" == "{}" || -z "$state" ]]; then
            log_error "$sensor: Aucune donnée reçue"
            continue
        fi

        local temperature
        temperature=$(echo "$state" | jq -r '.temperature // "N/A"')
        local humidity
        humidity=$(echo "$state" | jq -r '.humidity // "N/A"')
        local battery
        battery=$(echo "$state" | jq -r '.battery // "N/A"')
        local linkquality
        linkquality=$(echo "$state" | jq -r '.linkquality // "N/A"')
        local last_seen
        last_seen=$(echo "$state" | jq -r '.last_seen // "N/A"')

        log "  Température: ${temperature}°C"
        log "  Humidité: ${humidity}%"
        log "  Batterie: ${battery}%"
        log "  LQI: $linkquality"
        log "  Dernière activité: $last_seen"

        # Alertes
        if [[ "$battery" != "N/A" ]] && (( $(echo "$battery < 20" | bc -l) )); then
            log_warning "  ⚠ Batterie faible ($battery%)"
        fi

        if [[ "$linkquality" != "N/A" ]] && [[ $linkquality -lt 50 ]]; then
            log_warning "  ⚠ Qualité de lien faible (LQI: $linkquality)"
        fi

        echo ""
    done
}

# ====================================================================
# MAIN
# ====================================================================

main() {
    clear
    log "=========================================="
    log "VALIDATION DES INTERVALLES DE REPORTING"
    log "=========================================="
    echo ""

    # Vérifier les dépendances
    check_dependencies
    echo ""

    # Tester la connexion MQTT
    test_mqtt_connection
    echo ""

    # Diagnostic initial
    diagnostic_sensors

    # Démarrer le monitoring
    monitor_sensor_updates
}

# Gérer Ctrl+C proprement
trap 'log ""; log "Monitoring interrompu par utilisateur"; exit 0' SIGINT SIGTERM

main "$@"
