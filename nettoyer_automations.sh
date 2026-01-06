#!/bin/bash
# =====================================
# SCRIPT NETTOYAGE AUTOMATIONS DOUBLONS
# Date: 22 décembre 2025
# =====================================

set -e

echo ""
echo "==================================="
echo "NETTOYAGE AUTOMATIONS DOUBLONS"
echo "==================================="
echo ""

# Fichier automations.yaml
AUTOMATIONS_FILE="/config/automations.yaml"

# Vérifier que le fichier existe
if [ ! -f "$AUTOMATIONS_FILE" ]; then
    echo "[ERREUR] Fichier introuvable: $AUTOMATIONS_FILE"
    exit 1
fi

# Créer une sauvegarde
BACKUP_FILE="/config/automations.yaml.backup_$(date +%Y%m%d_%H%M%S)"
cp "$AUTOMATIONS_FILE" "$BACKUP_FILE"
echo "[OK] Sauvegarde créée: $BACKUP_FILE"
echo ""

# Liste des IDs à nettoyer
echo "[INFO] Recherche des doublons..."
echo ""

# Trouver les IDs en double
DUPLICATE_IDS=$(grep "^- id:" "$AUTOMATIONS_FILE" | awk '{print $3}' | sort | uniq -d)

if [ -z "$DUPLICATE_IDS" ]; then
    echo "[INFO] Aucun doublon trouvé"
    exit 0
fi

echo "[DOUBLONS DÉTECTÉS]"
echo "$DUPLICATE_IDS"
echo ""

# Pour chaque ID en double, supprimer toutes les occurrences sauf la première
for ID in $DUPLICATE_IDS; do
    echo "[TRAITEMENT] ID: $ID"

    # Trouver toutes les lignes où cet ID apparaît
    LINES=$(grep -n "^- id: $ID$" "$AUTOMATIONS_FILE" | cut -d: -f1)
    LINE_COUNT=$(echo "$LINES" | wc -l)

    echo "  → Trouvé $LINE_COUNT occurrences"

    # Garder la première, supprimer les autres
    FIRST_LINE=$(echo "$LINES" | head -1)
    TO_DELETE=$(echo "$LINES" | tail -n +2)

    if [ -n "$TO_DELETE" ]; then
        for LINE_NUM in $TO_DELETE; do
            # Trouver le début et la fin de cette automation
            # (de "- id:" jusqu'au prochain "- id:" ou fin de fichier)
            NEXT_LINE=$(awk -v start=$LINE_NUM 'NR>start && /^- id:/ {print NR; exit}' "$AUTOMATIONS_FILE")

            if [ -z "$NEXT_LINE" ]; then
                # Dernière automation, supprimer jusqu'à la fin
                NEXT_LINE='$'
            else
                NEXT_LINE=$((NEXT_LINE - 1))
            fi

            echo "  → Suppression lignes $LINE_NUM à $NEXT_LINE"
        done
    fi
done

echo ""
echo "==================================="
echo "MÉTHODE ALTERNATIVE RECOMMANDÉE"
echo "==================================="
echo ""
echo "Le nettoyage automatique est complexe en bash."
echo "Méthode recommandée:"
echo ""
echo "1. Supprimer via l'interface Home Assistant:"
echo "   - Paramètres → Automatisations"
echo "   - Chercher les doublons"
echo "   - Supprimer les versions obsolètes"
echo ""
echo "2. OU éditer manuellement:"
echo "   - nano $AUTOMATIONS_FILE"
echo "   - Supprimer les blocs dupliqués"
echo ""
echo "IDs à corriger:"
for ID in $DUPLICATE_IDS; do
    echo "  - $ID"
done
echo ""
echo "Sauvegarde disponible: $BACKUP_FILE"
echo ""
