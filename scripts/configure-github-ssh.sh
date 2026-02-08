#!/bin/bash
# Configuration SSH pour GitHub

set -e

echo "🔐 Configuration SSH pour GitHub..."
echo ""

# Fonction pour la solution rapide (réinitialisation complète)
quick_fix() {
    echo "🔧 Solution rapide - Réinitialisation complète..."
    echo ""
    
    # 1. Créer le répertoire .ssh
    echo "1. Création du répertoire .ssh..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    # 2. Générer la clé SSH (sans mot de passe pour simplifier)
    echo "2. Génération de la clé SSH..."
    ssh-keygen -t ed25519 -C "raspberrypi@alamo" -f ~/.ssh/id_ed25519 -N "" -y 2>/dev/null || \
    ssh-keygen -t ed25519 -C "raspberrypi@alamo" -f ~/.ssh/id_ed25519 -N ""
    
    # 3. Configurer ssh-agent
    echo "3. Configuration de ssh-agent..."
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519 2>/dev/null || true
    
    # 4. Créer la config SSH
    echo "4. Création de la configuration SSH..."
    cat > ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF
    chmod 600 ~/.ssh/config
    
    # 5. Afficher la clé publique
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Votre clé publique SSH:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    cat ~/.ssh/id_ed25519.pub
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    echo "✅ Configuration terminée!"
    echo ""
    echo "📝 Prochaines étapes:"
    echo "   1. Copiez la clé publique ci-dessus"
    echo "   2. Ajoutez-la sur GitHub: https://github.com/settings/ssh/new"
    echo "   3. Testez avec: ssh -T git@github.com"
    echo "   4. Si ça fonctionne: git push origin main"
    echo ""
}

# Menu principal
echo "Choisissez une option:"
echo "  1) Configuration normale (recommandé)"
echo "  2) Solution rapide (si vous avez des problèmes)"
echo ""
read -p "Choix (1 ou 2): " menu_choice

if [ "$menu_choice" = "2" ]; then
    quick_fix
    exit 0
fi

echo ""

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
echo ""

# Section Solution rapide en cas de problème
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 SOLUTION RAPIDE - En cas de problème"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Si vous avez des problèmes d'authentification SSH avec GitHub,"
echo "exécutez cette séquence de commandes pour tout réinitialiser:"
echo ""
echo "```bash"
echo "# 1. Créer le répertoire .ssh"
echo "mkdir -p ~/.ssh"
echo "chmod 700 ~/.ssh"
echo ""
echo "# 2. Générer la clé SSH (sans mot de passe pour simplifier)"
echo "ssh-keygen -t ed25519 -C \"raspberrypi@alamo\" -f ~/.ssh/id_ed25519 -N \"\""
echo ""
echo "# 3. Afficher la clé publique"
echo "cat ~/.ssh/id_ed25519.pub"
echo ""
echo "# 4. Configurer ssh-agent"
echo "eval \"\$(ssh-agent -s)\""
echo "ssh-add ~/.ssh/id_ed25519"
echo ""
echo "# 5. Créer la config SSH"
echo "cat > ~/.ssh/config << 'EOF'"
echo "Host github.com"
echo "    HostName github.com"
echo "    User git"
echo "    IdentityFile ~/.ssh/id_ed25519"
echo "    IdentitiesOnly yes"
echo "EOF"
echo "chmod 600 ~/.ssh/config"
echo ""
echo "# 6. Tester la connexion"
echo "ssh -T git@github.com"
echo "```"
echo ""
echo "📝 Étapes importantes:"
echo "   1. Copiez la clé publique affichée par: cat ~/.ssh/id_ed25519.pub"
echo "   2. Ajoutez-la sur GitHub: https://github.com/settings/ssh/new"
echo "   3. Testez avec: ssh -T git@github.com"
echo "   4. Si ça fonctionne, testez: git push origin main"
echo ""
