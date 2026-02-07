#!/bin/bash
# Script pour gérer des mots de passe dans un fichier .txt chiffré avec mot de passe

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PASSWORDS_FILE="$PROJECT_ROOT/passwords.txt"
PASSWORDS_ENCRYPTED="$PROJECT_ROOT/passwords.txt.gpg"
PASSWORD_FILE="$PROJECT_ROOT/.passwords-password"

echo "🔐 Gestionnaire de mots de passe"

# Fonction pour afficher le menu
show_menu() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Menu:"
    echo "  1) Ajouter un mot de passe"
    echo "  2) Voir les mots de passe"
    echo "  3) Voir le contenu brut de passwords.txt"
    echo "  4) Supprimer un mot de passe"
    echo "  5) Chercher un mot de passe"
    echo "  6) Changer le mot de passe"
    echo "  7) Quitter"
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

# Fonction pour ajouter un mot de passe
add_password() {
    decrypt_file
    
    echo ""
    read -p "Nom/Service (ex: Gmail, Facebook): " name
    read -p "Identifiant/Email: " username
    read -sp "Mot de passe: " password
    echo ""
    read -p "URL (optionnel): " url
    read -p "Notes (optionnel): " notes
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $name|$username|$password|$url|$notes" >> "$PASSWORDS_FILE"
    
    encrypt_file
    echo "✅ Mot de passe ajouté"
}

# Fonction pour voir les mots de passe
view_passwords() {
    decrypt_file
    
    if [ ! -s "$PASSWORDS_FILE" ]; then
        echo "ℹ️  Aucun mot de passe enregistré"
        encrypt_file
        return
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔑 Mots de passe:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    line_num=1
    while IFS='|' read -r line; do
        if [[ "$line" =~ ^\[(.*)\]\ (.*)\|(.*)\|(.*)\|(.*)\|(.*)$ ]]; then
            timestamp="${BASH_REMATCH[1]}"
            name="${BASH_REMATCH[2]}"
            username="${BASH_REMATCH[3]}"
            password="${BASH_REMATCH[4]}"
            url="${BASH_REMATCH[5]}"
            notes="${BASH_REMATCH[6]}"
            
            echo "  $line_num) [$timestamp] $name"
            echo "     👤 Identifiant: $username"
            echo "     🔑 Mot de passe: $password"
            if [ -n "$url" ]; then
                echo "     🌐 URL: $url"
            fi
            if [ -n "$notes" ]; then
                echo "     📝 Notes: $notes"
            fi
            echo ""
            line_num=$((line_num + 1))
        fi
    done < "$PASSWORDS_FILE"
    
    encrypt_file
}

# Fonction pour supprimer un mot de passe
delete_password() {
    decrypt_file
    
    if [ ! -s "$PASSWORDS_FILE" ]; then
        echo "ℹ️  Aucun mot de passe à supprimer"
        encrypt_file
        return
    fi
    
    # Afficher une liste simplifiée
    echo ""
    echo "Mots de passe:"
    line_num=1
    while IFS='|' read -r line; do
        if [[ "$line" =~ ^\[(.*)\]\ (.*)\| ]]; then
            name="${BASH_REMATCH[2]}"
            echo "  $line_num) $name"
            line_num=$((line_num + 1))
        fi
    done < "$PASSWORDS_FILE"
    
    echo ""
    read -p "Numéro du mot de passe à supprimer: " num
    
    if ! [[ "$num" =~ ^[0-9]+$ ]]; then
        echo "❌ Numéro invalide"
        encrypt_file
        return
    fi
    
    # Créer un fichier temporaire sans la ligne à supprimer
    temp_file=$(mktemp)
    line_num=1
    while IFS= read -r line; do
        if [ "$line_num" -ne "$num" ]; then
            echo "$line" >> "$temp_file"
        fi
        line_num=$((line_num + 1))
    done < "$PASSWORDS_FILE"
    
    mv "$temp_file" "$PASSWORDS_FILE"
    encrypt_file
    echo "✅ Mot de passe supprimé"
}

# Fonction pour chercher un mot de passe
search_password() {
    decrypt_file
    
    if [ ! -s "$PASSWORDS_FILE" ]; then
        echo "ℹ️  Aucun mot de passe à chercher"
        encrypt_file
        return
    fi
    
    echo ""
    read -p "Rechercher (nom, identifiant, URL): " search_term
    
    if [ -z "$search_term" ]; then
        echo "❌ Terme de recherche vide"
        encrypt_file
        return
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Résultats de recherche pour: $search_term"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    found=0
    while IFS='|' read -r line; do
        if [[ "$line" =~ $search_term ]]; then
            if [[ "$line" =~ ^\[(.*)\]\ (.*)\|(.*)\|(.*)\|(.*)\|(.*)$ ]]; then
                timestamp="${BASH_REMATCH[1]}"
                name="${BASH_REMATCH[2]}"
                username="${BASH_REMATCH[3]}"
                password="${BASH_REMATCH[4]}"
                url="${BASH_REMATCH[5]}"
                notes="${BASH_REMATCH[6]}"
                
                echo "  [$timestamp] $name"
                echo "     👤 Identifiant: $username"
                echo "     🔑 Mot de passe: $password"
                if [ -n "$url" ]; then
                    echo "     🌐 URL: $url"
                fi
                if [ -n "$notes" ]; then
                    echo "     📝 Notes: $notes"
                fi
                echo ""
                found=1
            fi
        fi
    done < "$PASSWORDS_FILE"
    
    if [ $found -eq 0 ]; then
        echo "ℹ️  Aucun résultat trouvé"
    fi
    
    encrypt_file
}

# Fonction pour voir le contenu brut du fichier
view_raw_file() {
    decrypt_file
    
    if [ ! -s "$PASSWORDS_FILE" ]; then
        echo "ℹ️  Le fichier passwords.txt est vide"
        encrypt_file
        return
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 Contenu brut de passwords.txt:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    cat "$PASSWORDS_FILE"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    encrypt_file
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

# Initialiser le mot de passe si nécessaire
init_password

# Menu principal
while true; do
    show_menu
    read -p "Choix: " choice
    
    case $choice in
        1)
            add_password
            ;;
        2)
            view_passwords
            ;;
        3)
            view_raw_file
            ;;
        4)
            delete_password
            ;;
        5)
            search_password
            ;;
        6)
            change_password
            ;;
        7)
            echo "👋 Au revoir!"
            exit 0
            ;;
        *)
            echo "❌ Choix invalide"
            ;;
    esac
done
