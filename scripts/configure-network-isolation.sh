#!/bin/bash
# Configuration de l'isolation réseau pour OpenClaw

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔒 Configuration de l'isolation réseau..."

# Vérifier que le script est exécuté en root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Ce script doit être exécuté en root (utilisez sudo)"
    exit 1
fi

# Vérifier que UFW est installé
if ! command -v ufw &> /dev/null; then
    echo "📦 Installation de UFW..."
    apt-get update
    apt-get install -y ufw
fi

# Obtenir l'IP du conteneur OpenClaw
CONTAINER_NAME="openclaw-secure"
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Le conteneur $CONTAINER_NAME n'est pas en cours d'exécution"
    echo "   Démarrez d'abord le conteneur avec: docker-compose up -d"
    exit 1
fi

CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")

if [ -z "$CONTAINER_IP" ]; then
    echo "❌ Impossible de récupérer l'IP du conteneur"
    exit 1
fi

echo "📡 IP du conteneur: $CONTAINER_IP"

# Activer UFW si ce n'est pas déjà fait
if ! ufw status | grep -q "Status: active"; then
    echo "🔧 Activation de UFW..."
    ufw --force enable
fi

# Autoriser SSH (important pour ne pas se bloquer)
ufw allow 22/tcp

# Autoriser l'accès Internet depuis le conteneur (via NAT)
# Le conteneur peut sortir sur Internet mais pas accéder au réseau local

# Bloquer l'accès aux réseaux privés depuis le conteneur
echo "🚫 Blocage de l'accès aux réseaux privés..."
ufw deny from "$CONTAINER_IP" to 192.168.0.0/16
ufw deny from "$CONTAINER_IP" to 10.0.0.0/8
ufw deny from "$CONTAINER_IP" to 172.16.0.0/12
ufw deny from "$CONTAINER_IP" to 127.0.0.0/8

# Bloquer également l'accès Tailscale (100.64.0.0/10)
ufw deny from "$CONTAINER_IP" to 100.64.0.0/10

echo "✅ Isolation réseau configurée"
echo "   Le conteneur peut accéder à Internet mais pas au réseau local"
