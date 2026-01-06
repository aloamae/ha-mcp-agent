# Script de validation des intervalles de reporting Zigbee (Windows)
# Date: 2025-12-18
# Usage: .\validate_sensor_reporting.ps1 [-DurationMinutes 30]

param(
    [int]$DurationMinutes = 30,
    [string]$MqttHost = "localhost",
    [int]$MqttPort = 1883,
    [string]$MqttUser = "homeassistant",
    [string]$MqttPassword = ""
)

# ====================================================================
# CONFIGURATION
# ====================================================================

$Sensors = @(
    "th_cuisine",
    "th_salon",
    "th_loann",
    "th_meva",
    "th_axel",
    "th_parents",
    "th_terrasse"
)

$OutputFile = "sensor_reporting_validation_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# ====================================================================
# FONCTIONS
# ====================================================================

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        default { "Cyan" }
    }

    $prefix = switch ($Level) {
        "SUCCESS" { "[OK]" }
        "ERROR" { "[ERREUR]" }
        "WARNING" { "[ATTENTION]" }
        default { "[INFO]" }
    }

    $logMessage = "[$timestamp] $prefix $Message"

    Write-Host $prefix -ForegroundColor $color -NoNewline
    Write-Host " $Message"

    Add-Content -Path $OutputFile -Value $logMessage
}

function Test-MqttConnection {
    Write-Log "Test de connexion MQTT à ${MqttHost}:${MqttPort}..." "INFO"

    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connection = $tcpClient.BeginConnect($MqttHost, $MqttPort, $null, $null)
        $success = $connection.AsyncWaitHandle.WaitOne(5000, $false)
        $tcpClient.Close()

        if ($success) {
            Write-Log "Connexion MQTT réussie" "SUCCESS"
            return $true
        } else {
            Write-Log "Impossible de se connecter au broker MQTT" "ERROR"
            return $false
        }
    } catch {
        Write-Log "Erreur lors de la connexion MQTT: $_" "ERROR"
        return $false
    }
}

function Get-SensorState {
    param([string]$SensorName)

    # ATTENTION: Cette fonction nécessite mosquitto_sub ou un client MQTT
    # Pour Windows, vous pouvez utiliser:
    # - MQTT Explorer (interface graphique)
    # - mosquitto_sub depuis WSL
    # - Un client .NET MQTT (MQTTnet)

    Write-Log "ATTENTION: Cette fonctionnalité nécessite un client MQTT" "WARNING"
    Write-Log "Utilisez MQTT Explorer ou accédez à Home Assistant directement" "WARNING"

    return @{
        temperature = "N/A"
        humidity = "N/A"
        battery = "N/A"
        linkquality = "N/A"
        last_seen = "N/A"
    }
}

function Get-HomeAssistantSensorState {
    param([string]$SensorName)

    # Alternative: Interroger directement l'API Home Assistant
    $haUrl = "http://localhost:8123"
    $haToken = $env:HA_TOKEN

    if ([string]::IsNullOrEmpty($haToken)) {
        Write-Log "Variable d'environnement HA_TOKEN non définie" "WARNING"
        return $null
    }

    try {
        $headers = @{
            "Authorization" = "Bearer $haToken"
            "Content-Type" = "application/json"
        }

        # Récupérer les entités du capteur
        $tempEntityId = "sensor.${SensorName}_temperature"
        $humEntityId = "sensor.${SensorName}_humidity"
        $battEntityId = "sensor.${SensorName}_battery"
        $lqiEntityId = "sensor.${SensorName}_linkquality"

        $tempResponse = Invoke-RestMethod -Uri "$haUrl/api/states/$tempEntityId" -Headers $headers -ErrorAction SilentlyContinue
        $humResponse = Invoke-RestMethod -Uri "$haUrl/api/states/$humEntityId" -Headers $headers -ErrorAction SilentlyContinue
        $battResponse = Invoke-RestMethod -Uri "$haUrl/api/states/$battEntityId" -Headers $headers -ErrorAction SilentlyContinue
        $lqiResponse = Invoke-RestMethod -Uri "$haUrl/api/states/$lqiEntityId" -Headers $headers -ErrorAction SilentlyContinue

        return @{
            temperature = $tempResponse.state
            humidity = $humResponse.state
            battery = $battResponse.state
            linkquality = $lqiResponse.state
            last_updated_temp = $tempResponse.last_updated
            last_updated_hum = $humResponse.last_updated
        }
    } catch {
        Write-Log "Erreur lors de la récupération de l'état de $SensorName : $_" "ERROR"
        return $null
    }
}

function Test-SensorDiagnostic {
    Write-Log "============================================" "INFO"
    Write-Log "DIAGNOSTIC DES CAPTEURS" "INFO"
    Write-Log "============================================" "INFO"
    Write-Host ""

    foreach ($sensor in $Sensors) {
        Write-Log "Vérification de $sensor..." "INFO"

        $state = Get-HomeAssistantSensorState -SensorName $sensor

        if ($null -eq $state) {
            Write-Log "$sensor : Impossible de récupérer l'état" "ERROR"
            continue
        }

        Write-Log "  Température: $($state.temperature)°C" "INFO"
        Write-Log "  Humidité: $($state.humidity)%" "INFO"
        Write-Log "  Batterie: $($state.battery)%" "INFO"
        Write-Log "  LQI: $($state.linkquality)" "INFO"

        # Alertes
        if ($state.battery -ne "N/A" -and [double]$state.battery -lt 20) {
            Write-Log "  ⚠ Batterie faible ($($state.battery)%)" "WARNING"
        }

        if ($state.linkquality -ne "N/A" -and [int]$state.linkquality -lt 50) {
            Write-Log "  ⚠ Qualité de lien faible (LQI: $($state.linkquality))" "WARNING"
        }

        Write-Host ""
    }
}

function Start-SensorMonitoring {
    Write-Log "Début du monitoring des capteurs pour $DurationMinutes minutes..." "INFO"
    Write-Log "Fichier de log: $OutputFile" "INFO"
    Write-Host ""

    $lastUpdate = @{}
    $updateCount = @{}
    $intervals = @{}

    # Initialiser les compteurs
    foreach ($sensor in $Sensors) {
        $lastUpdate[$sensor] = @{}
        $updateCount[$sensor] = 0
        $intervals[$sensor] = @()
    }

    $endTime = (Get-Date).AddMinutes($DurationMinutes)

    Write-Log "MÉTHODE DE MONITORING: Polling Home Assistant API toutes les 30 secondes" "INFO"
    Write-Log "Pour un monitoring en temps réel, utilisez MQTT Explorer ou le script Bash sous Linux/WSL" "WARNING"
    Write-Host ""

    while ((Get-Date) -lt $endTime) {
        foreach ($sensor in $Sensors) {
            $state = Get-HomeAssistantSensorState -SensorName $sensor

            if ($null -eq $state) {
                continue
            }

            $currentTime = Get-Date

            # Vérifier si les données ont changé
            $hasChanged = $false
            if ($lastUpdate[$sensor].Count -eq 0) {
                $hasChanged = $true
            } else {
                if ($state.temperature -ne $lastUpdate[$sensor].temperature -or
                    $state.humidity -ne $lastUpdate[$sensor].humidity) {
                    $hasChanged = $true
                }
            }

            if ($hasChanged) {
                # Calculer l'intervalle
                $interval = 0
                if ($lastUpdate[$sensor].Count -gt 0) {
                    $interval = ($currentTime - $lastUpdate[$sensor].timestamp).TotalSeconds
                    $intervals[$sensor] += $interval
                }

                $lastUpdate[$sensor] = @{
                    temperature = $state.temperature
                    humidity = $state.humidity
                    battery = $state.battery
                    linkquality = $state.linkquality
                    timestamp = $currentTime
                }

                $updateCount[$sensor]++

                $intervalDisplay = ""
                if ($interval -gt 0) {
                    $intervalDisplay = "(${interval}s depuis dernière update)"
                }

                Write-Log "$sensor : T=$($state.temperature)°C H=$($state.humidity)% Batt=$($state.battery)% LQI=$($state.linkquality) $intervalDisplay" "SUCCESS"
            }
        }

        # Attendre 30 secondes avant la prochaine vérification
        Start-Sleep -Seconds 30
    }

    # Afficher le résumé
    Write-Host ""
    Write-Log "============================================" "INFO"
    Write-Log "RÉSUMÉ DU MONITORING ($DurationMinutes minutes)" "INFO"
    Write-Log "============================================" "INFO"
    Write-Host ""

    foreach ($sensor in $Sensors) {
        $count = $updateCount[$sensor]

        if ($count -eq 0) {
            Write-Log "$sensor : AUCUNE mise à jour détectée" "ERROR"
        } else {
            # Calculer l'intervalle moyen
            $avgInterval = 0
            if ($intervals[$sensor].Count -gt 0) {
                $avgInterval = ($intervals[$sensor] | Measure-Object -Average).Average
            }

            Write-Log "$sensor : $count mises à jour (intervalle moyen: $([math]::Round($avgInterval, 1))s)" "SUCCESS"

            # Analyser la qualité
            if ($avgInterval -gt 0) {
                if ($avgInterval -le 180) {
                    Write-Log "  → Excellent (≤ 3 minutes)" "SUCCESS"
                } elseif ($avgInterval -le 300) {
                    Write-Log "  → Acceptable (3-5 minutes)" "WARNING"
                } elseif ($avgInterval -le 600) {
                    Write-Log "  → Lent (5-10 minutes)" "WARNING"
                } else {
                    Write-Log "  → Très lent (> 10 minutes) - Vérifier LQI ou batterie" "ERROR"
                }
            }
        }
    }

    Write-Host ""
    Write-Log "Monitoring terminé. Log complet: $OutputFile" "INFO"
}

# ====================================================================
# MAIN
# ====================================================================

Clear-Host
Write-Log "==========================================" "INFO"
Write-Log "VALIDATION DES INTERVALLES DE REPORTING" "INFO"
Write-Log "==========================================" "INFO"
Write-Host ""

# Vérifier la connexion MQTT
Test-MqttConnection
Write-Host ""

# Vérifier si HA_TOKEN est défini
if ([string]::IsNullOrEmpty($env:HA_TOKEN)) {
    Write-Log "ATTENTION: Variable d'environnement HA_TOKEN non définie" "WARNING"
    Write-Log "Pour l'activer, exécutez:" "INFO"
    Write-Log '  $env:HA_TOKEN = "VOTRE_TOKEN_HOME_ASSISTANT"' "INFO"
    Write-Host ""

    $continue = Read-Host "Continuer quand même? (O/N)"
    if ($continue -ne "O" -and $continue -ne "o") {
        exit 0
    }
}

Write-Host ""

# Diagnostic initial
Test-SensorDiagnostic

# Démarrer le monitoring
Start-SensorMonitoring
