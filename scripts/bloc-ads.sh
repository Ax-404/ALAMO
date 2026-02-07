#!/bin/bash
# Installation et configuration de Pi-hole pour bloquer les publicités

set -e

echo "🛡️  Installation de Pi-hole..."

# Vérifier que le script est exécuté en root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Ce script doit être exécuté en root (utilisez sudo)"
    exit 1
fi

# Vérifier que Pi-hole n'est pas déjà installé
if [ -d "/etc/pihole" ]; then
    echo "ℹ️  Pi-hole est déjà installé"
    echo "   Pour le réinstaller, désinstallez-le d'abord avec: pihole uninstall"
    exit 0
fi

# Vérifier les dépendances système
echo "🔍 Vérification des dépendances..."

# Vérifier que curl est installé
if ! command -v curl &> /dev/null; then
    echo "📦 Installation de curl..."
    apt-get update
    apt-get install -y curl
fi

# Installer Pi-hole
echo "📦 Installation de Pi-hole..."
echo "   Cette installation peut prendre plusieurs minutes..."
curl -sSL https://install.pi-hole.net | bash

# Configuration post-installation
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Pi-hole installé!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Informations importantes:"
echo ""
echo "   🔑 Mot de passe admin:"
echo "      pihole -a -p"
echo ""
echo "   🌐 Interface web:"
echo "      http://$(hostname -I | awk '{print $1}')/admin"
echo "      ou"
echo "      http://pi.hole/admin"
echo ""
echo "   📊 Commandes utiles:"
echo "      pihole status          - Vérifier le statut"
echo "      pihole -g              - Mettre à jour les listes"
echo "      pihole -w <domaine>    - Autoriser un domaine"
echo "      pihole -b <domaine>    - Bloquer un domaine"
echo "      pihole -q <domaine>    - Chercher un domaine"
echo ""
echo "   ⚙️  Configuration DNS:"
echo "      Configurez votre routeur ou vos appareils pour utiliser:"
echo "      $(hostname -I | awk '{print $1}') comme serveur DNS"
echo ""
echo "   🔄 Pour désinstaller:"
echo "      pihole uninstall"
echo ""
