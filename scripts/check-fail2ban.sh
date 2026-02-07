#!/bin/bash
# Vérification de Fail2ban

set -e

echo "🔍 Vérification de Fail2ban..."

ERRORS=0
WARNINGS=0

# Vérifier que Fail2ban est installé
if ! command -v fail2ban-client &> /dev/null; then
    echo "❌ Fail2ban n'est pas installé"
    echo "   Installez-le avec: sudo ./scripts/configure-fail2ban.sh"
    exit 1
fi

# Vérifier que le service est actif
if systemctl is-active --quiet fail2ban; then
    echo "✅ Service Fail2ban: ACTIF"
else
    echo "❌ Service Fail2ban: INACTIF"
    ERRORS=$((ERRORS + 1))
fi

# Vérifier que le service est activé au démarrage
if systemctl is-enabled --quiet fail2ban; then
    echo "✅ Fail2ban activé au démarrage: OUI"
else
    echo "⚠️  Fail2ban activé au démarrage: NON"
    WARNINGS=$((WARNINGS + 1))
fi

# Vérifier le statut des jails
echo ""
echo "📊 Statut des jails:"
if fail2ban-client status > /dev/null 2>&1; then
    fail2ban-client status
    echo ""
    
    # Vérifier que sshd est activé
    if fail2ban-client status sshd > /dev/null 2>&1; then
        echo "✅ Jail SSH: ACTIF"
        fail2ban-client status sshd | grep -E "(Currently banned|Total banned)" || true
    else
        echo "❌ Jail SSH: INACTIF"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "❌ Impossible d'obtenir le statut de Fail2ban"
    ERRORS=$((ERRORS + 1))
fi

# Résumé
echo ""
echo "📊 Résumé:"
echo "   Erreurs: $ERRORS"
echo "   Avertissements: $WARNINGS"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ Fail2ban: OK"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  Des avertissements ont été détectés"
    exit 0
else
    echo "❌ Des erreurs ont été détectées"
    exit 1
fi
