#!/bin/bash
# Installation de Git si nécessaire

set -e

echo "🔍 Vérification de Git..."

# Vérifier que le script est exécuté en root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Ce script doit être exécuté en root (utilisez sudo)"
    exit 1
fi

# Vérifier si Git est déjà installé
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    echo "✅ Git est déjà installé (version $GIT_VERSION)"
    echo ""
    echo "📊 Informations Git:"
    git --version
    echo ""
    echo "📍 Emplacement:"
    which git
    exit 0
fi

# Installer Git
echo "📦 Installation de Git..."
apt-get update
apt-get install -y git

# Vérifier l'installation
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Git installé avec succès!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📊 Version installée: $GIT_VERSION"
    echo ""
    echo "📝 Configuration recommandée:"
    echo "   git config --global user.name \"Votre Nom\""
    echo "   git config --global user.email \"votre@email.com\""
    echo ""
    echo "💡 Pour cloner le dépôt ALAMO:"
    echo "   git clone https://github.com/Ax-404/ALAMO.git"
else
    echo "❌ Erreur lors de l'installation de Git"
    exit 1
fi
