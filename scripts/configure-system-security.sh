#!/bin/bash
# Script combiné pour configurer la sécurité système
# Configure Fail2ban et Unattended Upgrades

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔒 Configuration de la sécurité système..."
echo "   Ce script configure:"
echo "   - Fail2ban (protection SSH)"
echo "   - Unattended Upgrades (mises à jour automatiques)"
echo ""

# Vérifier que le script est exécuté en root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Ce script doit être exécuté en root (utilisez sudo)"
    exit 1
fi

# Configuration Fail2ban
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Configuration de Fail2ban..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$SCRIPT_DIR/configure-fail2ban.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Configuration de Unattended Upgrades..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$SCRIPT_DIR/configure-unattended-upgrades.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Configuration terminée!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Vérification:"
echo "   - Fail2ban: ./scripts/check-fail2ban.sh"
echo "   - Unattended Upgrades: ./scripts/check-unattended-upgrades.sh"
