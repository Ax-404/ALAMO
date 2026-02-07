#!/bin/bash
# Dépannage Tailscale - diagnostic et solutions

echo "🔍 Diagnostic Tailscale..."
echo ""

# 1. Service
echo "1️⃣ Service tailscaled:"
if systemctl is-active --quiet tailscaled; then
    echo "   ✅ Actif"
else
    echo "   ❌ Inactif → lancez: sudo systemctl start tailscaled"
fi

# 2. Statut actuel
echo ""
echo "2️⃣ Statut actuel:"
tailscale status 2>&1 | head -5

# 3. Connectivité réseau (control plane Tailscale)
echo ""
echo "3️⃣ Connexion aux serveurs Tailscale:"
if curl -sS --connect-timeout 5 -o /dev/null https://controlplane.tailscale.com; then
    echo "   ✅ Accès OK"
else
    echo "   ❌ Impossible de joindre Tailscale (firewall/DNS ?)"
fi

# 4. Solution recommandée
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Si 'sudo tailscale up' ne fonctionne pas:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Sur une LattePanda sans navigateur, utilisez une CLÉ D'AUTHENTIFICATION:"
echo ""
echo "  1. Allez sur: https://login.tailscale.com/admin/settings/keys"
echo "  2. Cliquez « Generate auth key »"
echo "  3. Cochez « Reusable » et « Ephemeral » (optionnel)"
echo "  4. Copiez la clé (tskey-auth-xxxxxxxxxxxx)"
echo "  5. Sur la LattePanda:"
echo ""
echo "     sudo tailscale up --auth-key=tskey-auth-VOTRE_CLE"
echo ""
echo "Cela authentifie la machine sans ouvrir de navigateur."
echo ""
