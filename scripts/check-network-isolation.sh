#!/bin/bash
# Vérification de l'isolation réseau

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 Vérification de l'isolation réseau..."

CONTAINER_NAME="openclaw-secure"
ERRORS=0

# Vérifier que le conteneur est en cours d'exécution
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Le conteneur $CONTAINER_NAME n'est pas en cours d'exécution"
    exit 1
fi

# Obtenir l'IP du conteneur
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")

if [ -z "$CONTAINER_IP" ]; then
    echo "❌ Impossible de récupérer l'IP du conteneur"
    exit 1
fi

echo "📡 IP du conteneur: $CONTAINER_IP"

# Test 1: Vérifier l'accès Internet (doit fonctionner)
echo "🌐 Test d'accès Internet..."
if docker exec "$CONTAINER_NAME" ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "✅ Accès Internet: OK"
else
    echo "❌ Accès Internet: ÉCHEC"
    ERRORS=$((ERRORS + 1))
fi

# Test 2: Vérifier que l'accès au réseau local est bloqué
echo "🏠 Test de blocage réseau local..."
LOCAL_IP=$(hostname -I | awk '{print $1}')
if [ -n "$LOCAL_IP" ]; then
    if docker exec "$CONTAINER_NAME" ping -c 1 -W 2 "$LOCAL_IP" > /dev/null 2>&1; then
        echo "❌ Accès réseau local: NON BLOQUÉ (problème de sécurité!)"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ Accès réseau local: BLOQUÉ (correct)"
    fi
fi

# Test 3: Vérifier que l'accès à 192.168.1.1 est bloqué
echo "🔒 Test de blocage réseau privé..."
if docker exec "$CONTAINER_NAME" ping -c 1 -W 2 192.168.1.1 > /dev/null 2>&1; then
    echo "❌ Accès réseau privé: NON BLOQUÉ (problème de sécurité!)"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Accès réseau privé: BLOQUÉ (correct)"
fi

# Résumé
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ Isolation réseau: OK"
    exit 0
else
    echo "❌ $ERRORS problème(s) détecté(s)"
    exit 1
fi
