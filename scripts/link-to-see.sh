#!/bin/bash
# Script pour gérer des liens sensibles dans un fichier .txt chiffré avec mot de passe

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LINKS_FILE="$PROJECT_ROOT/links.txt"
LINKS_ENCRYPTED="$PROJECT_ROOT/links.txt.gpg"
PASSWORD_FILE="$PROJECT_ROOT/.links-password"

echo "🔗 Gestionnaire de liens protégés"

# Fonction pour afficher le menu
show_menu() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Menu:"
    echo "  1) Ajouter un lien"
    echo "  2) Voir les liens"
    echo "  3) Voir le contenu brut de links.txt"
    echo "  4) Supprimer un lien"
    echo "  5) Chercher un lien"
    echo "  6) Ouvrir un lien"
    echo "  7) Changer le mot de passe"
    echo "  8) Quitter"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Fonction pour vérifier/initialiser le mot de passe
init_password() {
    if [ ! -f "$PASSWORD_FILE" ]; then
        echo "🔐 Configuration du mot de passe pour protéger les liens..."
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
    if [ ! -f "$LINKS_ENCRYPTED" ]; then
        touch "$LINKS_FILE"
        return 0
    fi
    
    password=$(get_password)
    if [ -z "$password" ]; then
        read -sp "Entrez le mot de passe: " password
        echo ""
    fi
    
    echo "$password" | gpg --batch --yes --passphrase-fd 0 --decrypt "$LINKS_ENCRYPTED" > "$LINKS_FILE" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "❌ Mot de passe incorrect ou erreur de déchiffrement"
        rm -f "$LINKS_FILE"
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
    
    if [ -f "$LINKS_FILE" ]; then
        echo "$password" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 "$LINKS_FILE" 2>/dev/null
        if [ $? -eq 0 ]; then
            rm -f "$LINKS_FILE"
            echo "✅ Fichier chiffré et sauvegardé"
        else
            echo "❌ Erreur lors du chiffrement"
            exit 1
        fi
    fi
}

# Fonction pour ajouter un lien
add_link() {
    decrypt_file
    
    echo ""
    read -p "Nom/Description du lien: " name
    read -p "URL du lien: " url
    
    # Valider et formater l'URL
    if [[ ! "$url" =~ ^https?:// ]]; then
        echo "⚠️  L'URL ne commence pas par http:// ou https://, ajout de https://"
        url="https://$url"
    fi
    
    read -p "Notes (optionnel): " notes
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $name|$url|$notes" >> "$LINKS_FILE"
    
    encrypt_file
    echo "✅ Lien ajouté"
}

# Fonction pour voir les liens
view_links() {
    decrypt_file
    
    if [ ! -s "$LINKS_FILE" ]; then
        echo "ℹ️  Aucun lien enregistré"
        encrypt_file
        return
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Liens protégés:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    line_num=1
    while IFS='|' read -r line; do
        if [[ "$line" =~ ^\[(.*)\]\ (.*)\|(.*)\|(.*)$ ]]; then
            timestamp="${BASH_REMATCH[1]}"
            name="${BASH_REMATCH[2]}"
            url="${BASH_REMATCH[3]}"
            notes="${BASH_REMATCH[4]}"
            
            echo "  $line_num) [$timestamp] $name"
            echo "     🔗 $url"
            if [ -n "$notes" ]; then
                echo "     📝 Notes: $notes"
            fi
            echo ""
            line_num=$((line_num + 1))
        fi
    done < "$LINKS_FILE"
    
    encrypt_file
}

# Fonction pour supprimer un lien
delete_link() {
    decrypt_file
    
    if [ ! -s "$LINKS_FILE" ]; then
        echo "ℹ️  Aucun lien à supprimer"
        encrypt_file
        return
    fi
    
    # Afficher une liste simplifiée
    echo ""
    echo "Liens:"
    line_num=1
    while IFS='|' read -r line; do
        if [[ "$line" =~ ^\[(.*)\]\ (.*)\| ]]; then
            name="${BASH_REMATCH[2]}"
            echo "  $line_num) $name"
            line_num=$((line_num + 1))
        fi
    done < "$LINKS_FILE"
    
    echo ""
    read -p "Numéro du lien à supprimer: " num
    
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
    done < "$LINKS_FILE"
    
    mv "$temp_file" "$LINKS_FILE"
    encrypt_file
    echo "✅ Lien supprimé"
}

# Fonction pour chercher un lien
search_link() {
    decrypt_file
    
    if [ ! -s "$LINKS_FILE" ]; then
        echo "ℹ️  Aucun lien à chercher"
        encrypt_file
        return
    fi
    
    echo ""
    read -p "Rechercher (nom, URL, notes): " search_term
    
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
    line_num=1
    while IFS='|' read -r line; do
        if [[ "$line" =~ $search_term ]]; then
            if [[ "$line" =~ ^\[(.*)\]\ (.*)\|(.*)\|(.*)$ ]]; then
                timestamp="${BASH_REMATCH[1]}"
                name="${BASH_REMATCH[2]}"
                url="${BASH_REMATCH[3]}"
                notes="${BASH_REMATCH[4]}"
                
                echo "  $line_num) [$timestamp] $name"
                echo "     🔗 $url"
                if [ -n "$notes" ]; then
                    echo "     📝 Notes: $notes"
                fi
                echo ""
                found=1
                line_num=$((line_num + 1))
            fi
        fi
    done < "$LINKS_FILE"
    
    if [ $found -eq 0 ]; then
        echo "ℹ️  Aucun résultat trouvé"
    fi
    
    encrypt_file
}

# Fonction pour ouvrir un lien
open_link() {
    decrypt_file
    
    if [ ! -s "$LINKS_FILE" ]; then
        echo "ℹ️  Aucun lien à ouvrir"
        encrypt_file
        return
    fi
    
    # Afficher la liste
    echo ""
    echo "Liens:"
    line_num=1
    declare -a urls
    while IFS='|' read -r line; do
        if [[ "$line" =~ ^\[(.*)\]\ (.*)\|(.*)\| ]]; then
            name="${BASH_REMATCH[2]}"
            url="${BASH_REMATCH[3]}"
            echo "  $line_num) $name"
            urls[$line_num]="$url"
            line_num=$((line_num + 1))
        fi
    done < "$LINKS_FILE"
    
    echo ""
    read -p "Numéro du lien à ouvrir: " num
    
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ -z "${urls[$num]}" ]; then
        echo "❌ Numéro invalide"
        encrypt_file
        return
    fi
    
    url="${urls[$num]}"
    echo "🌐 Ouverture de: $url"
    
    # Essayer d'ouvrir le lien selon le système
    if command -v xdg-open &> /dev/null; then
        xdg-open "$url" 2>/dev/null &
    elif command -v open &> /dev/null; then
        open "$url" 2>/dev/null &
    else
        echo "   URL: $url"
        echo "   (Copiez-collez dans votre navigateur)"
    fi
    
    encrypt_file
}

# Fonction pour voir le contenu brut du fichier
view_raw_file() {
    decrypt_file
    
    if [ ! -s "$LINKS_FILE" ]; then
        echo "ℹ️  Le fichier links.txt est vide"
        encrypt_file
        return
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 Contenu brut de links.txt:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    cat "$LINKS_FILE"
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
    if [ -f "$LINKS_ENCRYPTED" ]; then
        echo "$old_password" | gpg --batch --yes --passphrase-fd 0 --decrypt "$LINKS_ENCRYPTED" > "$LINKS_FILE" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "❌ Erreur lors du déchiffrement avec l'ancien mot de passe"
            return
        fi
        
        # Chiffrer avec le nouveau mot de passe
        echo "$new_password" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 "$LINKS_FILE" 2>/dev/null
        rm -f "$LINKS_FILE"
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
            add_link
            ;;
        2)
            view_links
            ;;
        3)
            view_raw_file
            ;;
        4)
            delete_link
            ;;
        5)
            search_link
            ;;
        6)
            open_link
            ;;
        7)
            change_password
            ;;
        8)
            echo "👋 Au revoir!"
            exit 0
            ;;
        *)
            echo "❌ Choix invalide"
            ;;
    esac
done
