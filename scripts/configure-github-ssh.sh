#!/bin/bash
# Configuration SSH pour GitHub

set -e

echo "🔐 Configuration SSH pour GitHub..."

# Vérifier que Git est installé
if ! command -v git &> /dev/null; then
    echo "❌ Git n'est pas installé"
    echo "   Installez-le avec: sudo apt-get install -y git"
    exit 1
fi

# Vérifier que SSH est installé
if ! command -v ssh &> /dev/null; then
    echo "❌ SSH n'est pas installé"
    echo "   Installez-le avec: sudo apt-get install -y openssh-client"
    exit 1
fi

# Vérifier si une clé SSH existe déjà
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ -f "$SSH_KEY" ]; then
    echo "ℹ️  Une clé SSH existe déjà: $SSH_KEY"
    read -p "Voulez-vous en créer une nouvelle ? (o/N): " create_new
    if [[ ! "$create_new" =~ ^[OoYy]$ ]]; then
        echo "✅ Utilisation de la clé existante"
    else
        SSH_KEY="$HOME/.ssh/id_ed25519_github"
        echo "📝 Nouvelle clé sera créée: $SSH_KEY"
    fi
fi

# Générer une clé SSH si elle n'existe pas
if [ ! -f "$SSH_KEY" ]; then
    echo ""
    echo "🔑 Génération d'une clé SSH..."
    echo "   Appuyez sur Entrée pour accepter l'emplacement par défaut"
    echo "   Vous pouvez entrer un mot de passe (optionnel mais recommandé)"
    echo ""
    
    ssh-keygen -t ed25519 -C "raspberrypi@alamo" -f "$SSH_KEY"
    
    if [ $? -eq 0 ]; then
        echo "✅ Clé SSH générée"
    else
        echo "❌ Erreur lors de la génération de la clé"
        exit 1
    fi
fi

# Afficher la clé publique
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Votre clé publique SSH:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
cat "${SSH_KEY}.pub"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Instructions pour ajouter la clé sur GitHub
echo "📝 Prochaines étapes:"
echo ""
echo "1. Copiez la clé publique ci-dessus"
echo ""
echo "2. Allez sur GitHub:"
echo "   https://github.com/settings/ssh/new"
echo ""
echo "3. Ajoutez la clé:"
echo "   - Title: Raspberry Pi ALAMO (ou un nom de votre choix)"
echo "   - Key: Collez la clé publique ci-dessus"
echo "   - Cliquez sur 'Add SSH key'"
echo ""
echo "4. Testez la connexion:"
echo "   ssh -T git@github.com"
echo ""
echo "5. Configurez le remote Git:"
echo "   git remote set-url origin git@github.com:Ax-404/ALAMO.git"
echo ""
echo "6. Testez le push:"
echo "   git push origin main"
echo ""

# Demander si l'utilisateur veut configurer le remote maintenant
read -p "Voulez-vous configurer le remote Git maintenant ? (o/N): " configure_remote
if [[ "$configure_remote" =~ ^[OoYy]$ ]]; then
    # Vérifier si on est dans un dépôt Git
    if [ -d ".git" ]; then
        echo ""
        echo "🔧 Configuration du remote Git..."
        git remote set-url origin git@github.com:Ax-404/ALAMO.git
        
        echo "✅ Remote configuré"
        echo ""
        echo "📝 Testez la connexion avec:"
        echo "   ssh -T git@github.com"
        echo ""
        echo "   Si vous voyez 'Hi Ax-404! You've successfully authenticated...',"
        echo "   vous pouvez faire: git push origin main"
    else
        echo "⚠️  Vous n'êtes pas dans un dépôt Git"
        echo "   Allez dans le répertoire du projet et relancez ce script"
    fi
fi

echo ""
echo "✅ Configuration terminée!"
