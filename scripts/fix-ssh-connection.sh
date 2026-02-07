#!/bin/bash
# Script de réinitialisation complète pour SSH via Tailscale

set -e

# Charger les variables d'environnement si .env existe
if [ -f "$(dirname "$0")/../.env" ]; then
    set -a
    source "$(dirname "$0")/../.env"
    set +a
fi

# Variables par défaut
SSH_PORT="${SSH_PORT:-22}"
TAILSCALE_IP="${TAILSCALE_IP:-100.94.126.109}"

echo "=== Réinitialisation complète pour SSH ==="
echo "IP Tailscale: $TAILSCALE_IP"
echo "Port SSH: $SSH_PORT"
echo ""

# 1. Réinitialiser iptables
echo "1. Réinitialisation iptables..."
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

# 2. Autoriser SSH et Tailscale
echo "2. Autorisation SSH et Tailscale..."
sudo iptables -A INPUT -p tcp --dport $SSH_PORT -j ACCEPT
sudo iptables -A INPUT -i tailscale0 -j ACCEPT
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 3. Redémarrer SSH
echo "3. Redémarrage SSH..."
sudo systemctl restart ssh

# 4. Vérifier
echo -e "\n4. Vérification:"
echo "SSH écoute sur:"
sudo ss -tlnp | grep :$SSH_PORT || echo "⚠️  SSH n'écoute pas sur le port $SSH_PORT"
echo -e "\niptables INPUT:"
sudo iptables -L INPUT -n -v

# 5. Sauvegarder
echo -e "\n5. Sauvegarde..."
if command -v netfilter-persistent &> /dev/null; then
    sudo netfilter-persistent save
    echo "✅ Règles sauvegardées"
else
    echo "⚠️  netfilter-persistent non installé, règles non sauvegardées"
fi

echo -e "\n✅ Configuration terminée. Testez depuis votre Mac:"
echo "   nc -zv $TAILSCALE_IP $SSH_PORT"
echo "   ssh axel@$TAILSCALE_IP"
