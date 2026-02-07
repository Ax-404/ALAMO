#!/bin/bash
# Configuration de Tailscale pour accès remote (OPTIONNEL)

set -e

echo "🔒 Configuration de Tailscale (OPTIONNEL)..."

# Vérifier d'éventuels dépôts APT problématiques connus
APT_ISSUES=()
APT_FILES=("/etc/apt/sources.list" /etc/apt/sources.list.d/*.list)

for file in "${APT_FILES[@]}"; do
    [ -r "$file" ] || continue
    if grep -qi "archive\\.ubuntu\\.com/ubuntu[[:space:]]\+cinnamon" "$file"; then
        APT_ISSUES+=("Dépôt Ubuntu « cinnamon » détecté dans $file → supprimer ou commenter cette entrée.")
    fi
    if grep -qi "download\\.docker\\.com/.*/ubuntu[[:space:]]\+victoria" "$file"; then
        APT_ISSUES+=("Dépôt Docker pointant vers « victoria » dans $file → remplacer par « jammy » ou désactiver.")
    fi
    if grep -qi "downloads\\.cursor\\.com/aptrepo" "$file" && ! [ -f /usr/share/keyrings/cursor-archive-keyring.gpg ]; then
        APT_ISSUES+=("Dépôt Cursor sans clé GPG installée (42A1772E62E492D6) détecté dans $file → importer la clé ou désactiver le dépôt.")
    fi
done

if [ "${#APT_ISSUES[@]}" -gt 0 ]; then
    echo "❌ Impossible de continuer : dépôts APT à corriger avant l'installation."
    echo ""
    echo "Corrigez les points suivants puis relancez ce script :"
    for issue in "${APT_ISSUES[@]}"; do
        echo "  - ${issue}"
    done
    echo ""
    echo "Exemples de corrections :"
    echo "  • sudo sed -i 's/^deb .*cinnamon/# &/' /etc/apt/sources.list"
    echo "  • sudo sed -i 's/victoria/jammy/g' /etc/apt/sources.list.d/docker.list"
    echo "  • curl -fsSL https://downloads.cursor.com/aptrepo/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cursor-archive-keyring.gpg"
    echo "    sudo tee /etc/apt/sources.list.d/cursor.list <<< 'deb [signed-by=/usr/share/keyrings/cursor-archive-keyring.gpg] https://downloads.cursor.com/aptrepo stable main'"
    exit 1
fi

# Vérifier que le script est exécuté en root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Ce script doit être exécuté en root (utilisez sudo)"
    exit 1
fi

# Vérifier que Tailscale n'est pas déjà installé
if command -v tailscale &> /dev/null; then
    echo "ℹ️  Tailscale est déjà installé"
    tailscale status
    exit 0
fi

# Installer Tailscale
echo "📦 Installation de Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# Démarrer Tailscale
echo "🚀 Démarrage de Tailscale..."
systemctl enable --now tailscaled

# Configurer le firewall pour autoriser Tailscale
if command -v ufw &> /dev/null; then
    echo "🔥 Configuration du firewall pour Tailscale..."
    ufw allow 41641/udp  # Port Tailscale
    ufw allow in on tailscale0
    ufw allow out on tailscale0
fi

# Instructions pour l'authentification
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Tailscale installé!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Prochaines étapes:"
echo "   1. Authentifiez-vous avec:"
echo "      tailscale up"
echo ""
echo "   2. Suivez les instructions pour vous connecter à votre compte Tailscale"
echo ""
echo "   3. Vérifiez le statut avec:"
echo "      tailscale status"
echo ""
echo "   4. Vérifiez l'IP Tailscale avec:"
echo "      tailscale ip -4"
echo ""
echo "   5. Vérifiez la configuration avec:"
echo "      ./scripts/check-tailscale.sh"
