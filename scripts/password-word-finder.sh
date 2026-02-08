#!/bin/bash
# Script pour éditer des mots de passe dans un fichier .txt chiffré avec mot de passe

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PASSWORDS_FILE="$PROJECT_ROOT/passwords.txt"
PASSWORDS_ENCRYPTED="$PROJECT_ROOT/passwords.txt.gpg"
PASSWORD_FILE="$PROJECT_ROOT/.passwords-password"
EDITOR="${EDITOR:-nano}"

echo "🔐 Gestionnaire de mots de passe"

# Fonction pour afficher le menu
show_menu() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Menu:"
    echo "  1) Éditer passwords.txt"
    echo "  2) Changer le mot de passe"
    echo "  3) Quitter"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Fonction pour vérifier/initialiser le mot de passe
init_password() {
    if [ ! -f "$PASSWORD_FILE" ]; then
        echo "🔐 Configuration du mot de passe pour protéger les mots de passe..."
        read -sp "Entrez un mot de passe: " password
        echo ""
        read -sp "Confirmez le mot de passe: " password_confirm
        echo ""
        
        if [ "$password" != "$password_confirm" ]; then
            echo "❌ Les mots de passe ne correspondent pas"
            exit 1
        fi
        
        echo "$password" > "$PASSWORD_FILE"
        chmod 600 "$PASSWORD_FILE"
        echo "✅ Mot de passe configuré"
    fi
}

# Fonction pour obtenir le mot de passe
get_password() {
    if [ -f "$PASSWORD_FILE" ]; then
        cat "$PASSWORD_FILE"
    else
        echo ""
    fi
}

# Fonction pour déchiffrer le fichier
decrypt_file() {
    if [ ! -f "$PASSWORDS_ENCRYPTED" ]; then
        touch "$PASSWORDS_FILE"
        return 0
    fi
    
    password=$(get_password)
    if [ -z "$password" ]; then
        read -sp "Entrez le mot de passe: " password
        echo ""
    fi
    
    echo "$password" | gpg --batch --yes --passphrase-fd 0 --decrypt "$PASSWORDS_ENCRYPTED" > "$PASSWORDS_FILE" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "❌ Mot de passe incorrect ou erreur de déchiffrement"
        rm -f "$PASSWORDS_FILE"
        exit 1
    fi
}

# Fonction pour chiffrer le fichier
encrypt_file() {
    password=$(get_password)
    if [ -z "$password" ]; then
        read -sp "Entrez le mot de passe: " password
        echo ""
    fi
    
    if [ -f "$PASSWORDS_FILE" ]; then
        echo "$password" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 "$PASSWORDS_FILE" 2>/dev/null
        if [ $? -eq 0 ]; then
            rm -f "$PASSWORDS_FILE"
            echo "✅ Fichier chiffré et sauvegardé"
        else
            echo "❌ Erreur lors du chiffrement"
            exit 1
        fi
    fi
}

# Fonction pour éditer le fichier
edit_file() {
    echo ""
    echo "📝 Édition de passwords.txt..."
    
    # Déchiffrer le fichier
    decrypt_file
    
    # Créer un fichier temporaire pour l'édition
    TEMP_FILE=$(mktemp)
    cp "$PASSWORDS_FILE" "$TEMP_FILE"
    
    # Ouvrir l'éditeur
    echo "   Ouverture de l'éditeur ($EDITOR)..."
    echo "   (Le fichier sera automatiquement chiffré après votre édition)"
    echo ""
    
    if $EDITOR "$TEMP_FILE"; then
        # Copier le fichier édité
        cp "$TEMP_FILE" "$PASSWORDS_FILE"
        rm -f "$TEMP_FILE"
        
        # Chiffrer le fichier
        encrypt_file
        echo "✅ Modifications sauvegardées"
    else
        echo "⚠️  Édition annulée"
        rm -f "$TEMP_FILE"
        encrypt_file
    fi
}

# Fonction pour changer le mot de passe
change_password() {
    echo ""
    read -sp "Ancien mot de passe: " old_password
    echo ""
    
    # Vérifier l'ancien mot de passe
    if [ -f "$PASSWORD_FILE" ]; then
        stored_password=$(cat "$PASSWORD_FILE")
        if [ "$old_password" != "$stored_password" ]; then
            echo "❌ Ancien mot de passe incorrect"
            return
        fi
    fi
    
    read -sp "Nouveau mot de passe: " new_password
    echo ""
    read -sp "Confirmez le nouveau mot de passe: " new_password_confirm
    echo ""
    
    if [ "$new_password" != "$new_password_confirm" ]; then
        echo "❌ Les mots de passe ne correspondent pas"
        return
    fi
    
    # Déchiffrer avec l'ancien mot de passe
    if [ -f "$PASSWORDS_ENCRYPTED" ]; then
        echo "$old_password" | gpg --batch --yes --passphrase-fd 0 --decrypt "$PASSWORDS_ENCRYPTED" > "$PASSWORDS_FILE" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "❌ Erreur lors du déchiffrement avec l'ancien mot de passe"
            return
        fi
        
        # Chiffrer avec le nouveau mot de passe
        echo "$new_password" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 "$PASSWORDS_FILE" 2>/dev/null
        rm -f "$PASSWORDS_FILE"
    fi
    
    # Sauvegarder le nouveau mot de passe
    echo "$new_password" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"
    echo "✅ Mot de passe changé"
}

# Vérifier que GPG est installé
if ! command -v gpg &> /dev/null; then
    echo "❌ GPG n'est pas installé"
    echo "   Installez-le avec: sudo apt-get install -y gnupg"
    exit 1
fi

# Vérifier que l'éditeur est disponible
if ! command -v $EDITOR &> /dev/null; then
    echo "⚠️  L'éditeur '$EDITOR' n'est pas disponible"
    echo "   Installation de nano..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y nano
    else
        echo "   Veuillez installer un éditeur de texte (nano, vim, etc.)"
        exit 1
    fi
fi

# Initialiser le mot de passe si nécessaire
init_password

# Menu principal
while true; do
    show_menu
    read -p "Choix: " choice
    
    case $choice in
        1)
            edit_file
            ;;
        2)
            change_password
            ;;
        3)
            echo "👋 Au revoir!"
            exit 0
            ;;
        *)
            echo "❌ Choix invalide"
            ;;
    esac
done
