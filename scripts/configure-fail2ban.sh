#!/bin/bash
# Configuration de Fail2ban pour protection SSH

set -e

echo "🔒 Configuration de Fail2ban..."

# Vérifier que le script est exécuté en root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Ce script doit être exécuté en root (utilisez sudo)"
    exit 1
fi

# Installer Fail2ban si nécessaire
if ! command -v fail2ban-client &> /dev/null; then
    echo "📦 Installation de Fail2ban..."
    apt-get update
    apt-get install -y fail2ban
fi

# Créer la configuration locale
CONFIG_FILE="/etc/fail2ban/jail.local"

cat > "$CONFIG_FILE" << 'EOF'
[DEFAULT]
# Ban time: 1 heure
bantime = 3600
# Find time: 10 minutes
findtime = 600
# Max retries: 3 tentatives
maxretry = 3
# Email (optionnel - commenté par défaut)
# destemail = root@localhost
# sendername = Fail2Ban
# action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 3
bantime = 3600
findtime = 600
EOF

# Redémarrer Fail2ban
echo "🔄 Redémarrage de Fail2ban..."
systemctl restart fail2ban
systemctl enable fail2ban

# Vérifier le statut
echo "✅ Fail2ban configuré"
echo ""
echo "📊 Statut:"
fail2ban-client status

echo ""
echo "✅ Configuration terminée"
echo "   Fail2ban protège maintenant SSH contre les attaques brute force"
