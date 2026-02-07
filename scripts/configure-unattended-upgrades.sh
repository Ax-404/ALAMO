#!/bin/bash
# Configuration de Unattended Upgrades pour mises à jour automatiques

set -e

echo "🔒 Configuration de Unattended Upgrades..."

# Vérifier que le script est exécuté en root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Ce script doit être exécuté en root (utilisez sudo)"
    exit 1
fi

# Installer Unattended Upgrades si nécessaire
if ! command -v unattended-upgrade &> /dev/null; then
    echo "📦 Installation de Unattended Upgrades..."
    apt-get update
    apt-get install -y unattended-upgrades apt-listchanges
fi

# Créer la configuration
CONFIG_FILE="/etc/apt/apt.conf.d/50unattended-upgrades"

# Sauvegarder la configuration existante si elle existe
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
fi

# Configuration recommandée pour sécurité
cat > "$CONFIG_FILE" << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
Unattended-Upgrade::Mail "root";
EOF

# Activer les mises à jour automatiques
AUTO_FILE="/etc/apt/apt.conf.d/20auto-upgrades"
cat > "$AUTO_FILE" << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF

# Tester la configuration
echo "🧪 Test de la configuration..."
unattended-upgrade --dry-run --debug

echo "✅ Unattended Upgrades configuré"
echo ""
echo "📊 Configuration:"
echo "   - Mises à jour de sécurité: AUTOMATIQUES"
echo "   - Nettoyage automatique: ACTIVÉ"
echo "   - Redémarrage automatique: DÉSACTIVÉ (configurable)"
