#!/bin/bash
# Vérification de Tailscale

set -e

echo "🔍 Vérification de Tailscale..."

ERRORS=0
WARNINGS=0

# Vérifier que Tailscale est installé
if ! command -v tailscale &> /dev/null; then
    echo "ℹ️  Tailscale n'est pas installé"
    echo "   C'est normal si vous n'avez pas besoin d'accès remote"
    echo "   Pour installer: sudo ./scripts/configure-tailscale.sh"
    exit 0
fi

# Vérifier que le service est actif
if systemctl is-active --quiet tailscaled; then
    echo "✅ Service Tailscaled: ACTIF"
else
    echo "❌ Service Tailscaled: INACTIF"
    ERRORS=$((ERRORS + 1))
fi

# Vérifier que le service est activé au démarrage
if systemctl is-enabled --quiet tailscaled; then
    echo "✅ Tailscaled activé au démarrage: OUI"
else
    echo "⚠️  Tailscaled activé au démarrage: NON"
    WARNINGS=$((WARNINGS + 1))
fi

# Vérifier le statut
echo ""
echo "📊 Statut Tailscale:"
if tailscale status > /dev/null 2>&1; then
    tailscale status
    echo ""
    
    # Obtenir l'IP Tailscale
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "")
    if [ -n "$TAILSCALE_IP" ]; then
        echo "✅ IP Tailscale: $TAILSCALE_IP"
    else
        echo "⚠️  IP Tailscale: Non disponible (peut-être pas connecté)"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "❌ Impossible d'obtenir le statut de Tailscale"
    echo "   Vous n'êtes peut-être pas authentifié"
    echo "   Utilisez: tailscale up"
    ERRORS=$((ERRORS + 1))
fi

# Vérifier le firewall
if command -v ufw &> /dev/null; then
    echo ""
    echo "🔥 Vérification du firewall:"
    if ufw status | grep -q "tailscale0"; then
        echo "✅ Règles Tailscale dans UFW: CONFIGURÉES"
    else
        echo "⚠️  Règles Tailscale dans UFW: NON CONFIGURÉES"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# Résumé
echo ""
echo "📊 Résumé:"
echo "   Erreurs: $ERRORS"
echo "   Avertissements: $WARNINGS"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ Tailscale: OK"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  Des avertissements ont été détectés"
    exit 0
else
    echo "❌ Des erreurs ont été détectées"
    exit 1
fi
