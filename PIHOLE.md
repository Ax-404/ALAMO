# Guide d'Installation et Configuration de Pi-hole

Guide complet pour installer et configurer Pi-hole sur Raspberry Pi.

## 📋 Table des matières

- [Installation](#installation)
- [Configuration pendant l'installation](#configuration-pendant-linstallation)
- [Configuration post-installation](#configuration-post-installation)
- [Choix de l'interface réseau](#choix-de-linterface-réseau)
- [Listes de blocage](#listes-de-blocage)
- [Query Logging](#query-logging)
- [Privacy Mode](#privacy-mode)
- [Commandes utiles](#commandes-utiles)
- [Dépannage](#dépannage)

## 🚀 Installation

### Prérequis

- Raspberry Pi avec Raspberry Pi OS (Lite recommandé)
- Accès root (sudo)
- Connexion Internet

### Installation via le script

```bash
sudo ./scripts/bloc-ads.sh
```

Le script va :
1. Vérifier les dépendances (curl)
2. Installer Pi-hole automatiquement
3. Lancer l'installation interactive

## ⚙️ Configuration pendant l'installation

L'installation de Pi-hole est interactive et pose plusieurs questions. Voici les recommandations pour chaque étape :

### 1. Interface réseau

**Question :** Quelle interface réseau voulez-vous utiliser ?

#### Option A : Interface principale (eth0 ou wlan0) - Recommandé pour usage local

**Choisissez si :**
- Vous voulez que Pi-hole fonctionne sur votre réseau local
- Tous les appareils de votre réseau local doivent utiliser Pi-hole
- C'est l'usage le plus courant

**Avantages :**
- Fonctionne pour tous les appareils sur le réseau local
- Configuration simple
- Pas besoin de Tailscale sur tous les appareils

**Inconvénients :**
- Ne fonctionne que sur le réseau local
- En déplacement, Pi-hole ne sera pas disponible

#### Option B : Interface Tailscale (tailscale0) - Recommandé pour usage mobile

**Choisissez si :**
- Vous utilisez Tailscale sur tous vos appareils
- Vous voulez Pi-hole disponible en déplacement
- Vous êtes souvent mobile

**Avantages :**
- Pi-hole fonctionne partout via Tailscale
- Pas besoin d'être sur le réseau local
- Configuration centralisée pour tous vos appareils
- Trafic chiffré via Tailscale
- Pas besoin d'ouvrir des ports sur votre routeur

**Inconvénients :**
- Les appareils sans Tailscale ne pourront pas utiliser Pi-hole
- Dépendance à Tailscale (doit être actif)

**Comment trouver l'IP Tailscale :**
```bash
tailscale ip -4
```

**Recommandation :** Si vous utilisez Tailscale sur tous vos appareils et que vous êtes souvent en déplacement, choisissez `tailscale0`.

### 2. Protocole IP

**Question :** IPv4 ou IPv4 + IPv6 ?

**Recommandation :** IPv4 (suffisant pour la plupart des cas)

### 3. DNS Upstream

**Question :** Quels serveurs DNS utiliser ?

**Options recommandées :**
- Google (8.8.8.8, 8.8.4.4)
- Cloudflare (1.1.1.1, 1.0.0.1)
- OpenDNS (208.67.222.222, 208.67.220.220)

**Recommandation :** Cloudflare (1.1.1.1) - Rapide et respectueux de la vie privée

### 4. Listes de blocage

**Question :** Voulez-vous installer des listes de blocage supplémentaires ?

#### StevenBlack's Unified Hosts - **RECOMMANDÉ : OUI**

**Qu'est-ce que c'est ?**
- Liste de blocage qui combine plusieurs sources
- Bloque : publicités, trackers, sites malveillants, phishing

**Avantages :**
- Blocage plus efficace des publicités
- Protection supplémentaire contre les malwares
- Liste maintenue et mise à jour régulièrement
- Très utilisée et fiable

**Inconvénients :**
- Légèrement plus de domaines bloqués
- Peut bloquer des sites légitimes dans de rares cas (faux positifs)

**Recommandation :** **Activez-la (Oui)**

### 5. Interface web

**Question :** Voulez-vous activer l'interface web ?

**Recommandation :** **Oui** - Essentiel pour gérer Pi-hole

### 6. Query Logging

**Question :** Voulez-vous activer Query Logging (journalisation des requêtes) ?

**Qu'est-ce que c'est ?**
- Enregistrement de toutes les requêtes DNS
- Statistiques détaillées dans l'interface web

**Avantages :**
- Statistiques en temps réel
- Identification des domaines bloqués
- Débogage facilité
- Compréhension de l'utilisation du réseau

**Inconvénients :**
- Consommation d'espace disque (surveillez sur Raspberry Pi)
- Questions de confidentialité si partagé

**Recommandation :** **Activez-le (Oui)** avec rotation des logs

**Configuration recommandée :**
- Activer Query Logging
- Limiter la rétention à 7-30 jours (selon l'espace disque)
- Surveiller l'espace disque régulièrement

**Vérifier l'espace disque :**
```bash
df -h
```

### 7. Privacy Mode for FTL

**Question :** Quel niveau de confidentialité voulez-vous ?

#### Option 0 : Show Everything (Aucun filtre) - **RECOMMANDÉ pour usage personnel**

**Choisissez si :**
- C'est votre Pi-hole personnel
- Vous êtes seul ou en famille
- Vous voulez le maximum d'informations pour le débogage

**Affiche :**
- Toutes les informations dans les logs
- Adresses IP complètes des clients
- Tous les domaines consultés

#### Option 1 : Hide Domains (Masquer les domaines)

**Choisissez si :**
- Vous voulez un peu plus de confidentialité
- Vous avez des invités qui utilisent votre réseau
- Vous voulez quand même voir les IP des clients

**Affiche :**
- Adresses IP des clients
- Masque les noms de domaines

#### Option 2 : Hide Domains and Clients (Masquer domaines et clients)

**Choisissez si :**
- Plusieurs utilisateurs partagent le Pi-hole
- Vous voulez protéger la vie privée des utilisateurs
- Statistiques globales uniquement

#### Option 3 : Private Mode (Mode privé complet)

**Choisissez si :**
- Usage public ou très sensible
- Maximum de confidentialité requis
- Statistiques globales uniquement

**Recommandation :** **Option 0** pour usage personnel/familial

## 📝 Configuration post-installation

### 1. Récupérer/Changer le mot de passe admin

L'installation affiche un mot de passe temporaire. **Notez-le** ou changez-le immédiatement :

```bash
pihole -a -p
```

### 2. Accéder à l'interface web

Ouvrez dans un navigateur :
- `http://<IP_DE_VOTRE_PI>/admin`
- ou `http://pi.hole/admin`

**Trouver l'IP de votre Raspberry Pi :**
```bash
hostname -I
```

Exemple : `http://192.168.1.100/admin`

### 3. Configurer les appareils pour utiliser Pi-hole

Pour que Pi-hole bloque les publicités, configurez vos appareils pour utiliser l'IP du Raspberry Pi comme serveur DNS.

#### Option A : Configurer le routeur (RECOMMANDÉ)

**Avantages :**
- Tous les appareils utilisent automatiquement Pi-hole
- Configuration unique
- Fonctionne pour tous les nouveaux appareils

**Étapes :**
1. Accédez à l'interface de votre routeur (généralement `192.168.1.1` ou `192.168.0.1`)
2. Trouvez les paramètres DNS
3. Remplacez les serveurs DNS par l'IP de votre Raspberry Pi
4. Redémarrez le routeur si nécessaire

#### Option B : Configurer chaque appareil

**Si vous utilisez Tailscale (interface tailscale0) :**

1. Trouvez l'IP Tailscale de votre Raspberry Pi :
```bash
tailscale ip -4
```

2. Configurez cette IP comme serveur DNS sur chaque appareil :
   - **Windows :** Paramètres → Réseau → Adapter → Propriétés → DNS
   - **macOS :** Préférences Système → Réseau → Avancé → DNS (voir détails ci-dessous)
   - **Android :** Paramètres → Wi-Fi → Modifier → DNS
   - **iOS :** Paramètres → Wi-Fi → (i) → Configurer DNS

#### Configuration DNS sur macOS (détails)

**Important :** L'IP Tailscale de votre Raspberry Pi est **à la fois** :
- L'adresse IP Tailscale de votre Raspberry Pi
- Le serveur DNS Pi-hole (car Pi-hole est installé sur cette machine)

**Où configurer :**
- **DNS Server (Serveur DNS)** : C'est ici que vous mettez l'IP Tailscale du Raspberry Pi
- **Search Domain (Domaine de recherche)** : Ne mettez pas l'IP ici (ce champ sert aux domaines de recherche automatiques)

**Étapes :**
1. Ouvrez **Préférences Système** → **Réseau**
2. Sélectionnez votre connexion (Wi‑Fi ou Ethernet)
3. Cliquez sur **Avancé...**
4. Allez dans l'onglet **DNS**
5. Dans la section **Serveurs DNS**, cliquez sur **+**
6. Ajoutez l'IP Tailscale de votre Raspberry Pi (ex: `100.x.x.x`)
7. Cliquez sur **OK**

**Ordre de priorité :** macOS utilise les serveurs DNS dans l'ordre de la liste. Pour que Pi-hole fonctionne :
- Mettez l'IP Tailscale du Raspberry Pi **en premier** dans la liste
- Si vous avez le DNS Tailscale par défaut (`100.100.100.100`), retirez-le ou mettez-le après Pi-hole

**Vérification :**
```bash
# Vérifier quel serveur DNS est utilisé
scutil --dns | grep nameserver

# Tester une résolution DNS
nslookup google.com
```

Vous devriez voir l'IP Tailscale de votre Raspberry Pi dans la liste, et `nslookup` devrait l'utiliser en premier.

**Si vous utilisez l'interface principale (eth0/wlan0) :**

1. Utilisez l'IP locale de votre Raspberry Pi (ex: `192.168.1.100`)
2. Configurez cette IP comme serveur DNS sur chaque appareil

### 4. Vérifier que ça fonctionne

**Sur le Raspberry Pi :**
```bash
# Vérifier le statut de Pi-hole
pihole status

# Voir les logs en temps réel
pihole tail
```

**Sur votre Mac (ou autre appareil) :**
```bash
# Vérifier quel serveur DNS est utilisé
scutil --dns | grep nameserver

# Tester une résolution DNS
nslookup google.com

# Vérifier la configuration DNS complète
scutil --dns
```

Vous devriez voir l'IP Tailscale de votre Raspberry Pi dans la liste des serveurs DNS, et `nslookup` devrait l'utiliser.

### 5. Tester le blocage

1. Allez sur un site avec des publicités
2. Vérifiez dans l'interface web de Pi-hole (Dashboard)
3. Le compteur "Domains on blocklist" devrait augmenter
4. Les publicités devraient être bloquées

## 🔧 Commandes utiles

### Gestion de base

```bash
# Vérifier le statut
pihole status

# Redémarrer Pi-hole
pihole restartdns

# Arrêter Pi-hole
pihole stop

# Démarrer Pi-hole
pihole start
```

### Mise à jour

```bash
# Mettre à jour les listes de blocage - NOUVELLE SYNTAXE
pihole updateGravity
# (ancienne commande: pihole -g)

# Mettre à jour Pi-hole
pihole updatePihole
```

### Gestion des domaines

```bash
# Autoriser un domaine (whitelist) - NOUVELLE SYNTAXE
pihole allow example.com
# ou
pihole allowlist example.com

# Bloquer un domaine manuellement - NOUVELLE SYNTAXE
pihole deny example.com
# ou
pihole denylist example.com

# Chercher un domaine dans les listes
pihole query example.com

# Supprimer un domaine de la whitelist
pihole allow -d example.com
# ou
pihole allowlist -d example.com

# Supprimer un domaine de la blacklist
pihole deny -d example.com
# ou
pihole denylist -d example.com

# Options avancées
# Bloquer avec regex
pihole regex '.*example\.com.*'

# Autoriser avec regex
pihole allow-regex '.*example\.com.*'

# Bloquer avec wildcard
pihole wildcard '*.example.com'

# Autoriser avec wildcard
pihole allow-wild '*.example.com'
```

**Note :** Les anciennes commandes `-w` et `-b` ne fonctionnent plus dans les versions récentes de Pi-hole. Utilisez `allow`/`allowlist` et `deny`/`denylist`.

### Logs et statistiques

```bash
# Voir les logs en temps réel - NOUVELLE SYNTAXE
pihole tail
# ou avec filtre
pihole tail example.com
# (ancienne commande: pihole -t)

# Voir les statistiques
pihole status

# Voir les requêtes récentes
pihole querylog
```

### Configuration

```bash
# Changer le mot de passe admin
pihole -a -p

# Activer Query Logging
pihole logging on

# Désactiver Query Logging
pihole logging off

# Voir la configuration
pihole -v
```

## 🔄 Modifier la configuration après installation

### Changer l'interface réseau

```bash
# Éditer la configuration
sudo nano /etc/pihole/setupVars.conf

# Modifier la ligne INTERFACE= pour mettre eth0, wlan0, ou tailscale0
# Puis redémarrer Pi-hole
sudo pihole restartdns
```

### Changer le Privacy Mode

**Via l'interface web :**
1. Allez sur `http://<IP>/admin`
2. Menu "Settings" → "Privacy"
3. Changez le "Privacy Level"

**Via la ligne de commande :**
```bash
# Éditer la configuration
sudo nano /etc/pihole/pihole-FTL.conf

# Modifier PRIVACYLEVEL=0 (0, 1, 2, ou 3)
# Puis redémarrer
sudo pihole restartdns
```

### Ajouter/Retirer des listes de blocage

**Via l'interface web :**
1. Allez sur `http://<IP>/admin`
2. Menu "Adlists" (Listes de blocage)
3. Ajoutez ou supprimez des listes

**Listes recommandées :**
- StevenBlack's Unified Hosts
- Liste par défaut de Pi-hole
- Liste de malwares

## 🐛 Dépannage

### Pi-hole ne bloque pas les publicités

1. Vérifiez que les appareils utilisent bien l'IP du Raspberry Pi comme DNS
2. Vérifiez le statut : `pihole status`
3. Vérifiez les logs : `pihole -t`
4. Redémarrez Pi-hole : `pihole restartdns`

### Site bloqué par erreur (faux positif)

```bash
# Autoriser le domaine - NOUVELLE SYNTAXE
pihole allow example.com
# ou
pihole allowlist example.com

# Mettre à jour les listes
pihole updateGravity
```

### Problème d'espace disque

```bash
# Vérifier l'espace disque
df -h

# Nettoyer les logs anciens
pihole logging off
pihole logging on

# Ou limiter la rétention dans l'interface web
```

### Pi-hole ne démarre pas

```bash
# Vérifier les logs
sudo journalctl -u pihole-FTL

# Redémarrer le service
sudo systemctl restart pihole-FTL
```

### Réinitialiser Pi-hole

```bash
# Désinstaller (ATTENTION : supprime tout)
pihole uninstall

# Puis réinstaller
sudo ./scripts/bloc-ads.sh
```

## 📊 Interface web

### Accès

- URL : `http://<IP>/admin` ou `http://pi.hole/admin`
- Mot de passe : Changez-le avec `pihole -a -p`

### Sections principales

- **Dashboard :** Statistiques en temps réel
- **Query Log :** Logs des requêtes DNS
- **Whitelist :** Domaines autorisés
- **Blacklist :** Domaines bloqués
- **Adlists :** Listes de blocage
- **Settings :** Configuration
- **Tools :** Outils de diagnostic

## 🔐 Sécurité

### Bonnes pratiques

1. **Changez le mot de passe admin** immédiatement après l'installation
2. **Mettez à jour régulièrement** : `pihole updatePihole`
3. **Surveillez les logs** pour détecter des activités suspectes
4. **Limitez l'accès** à l'interface web si nécessaire (firewall)

### Firewall

Si vous voulez limiter l'accès à l'interface web :

```bash
# Autoriser uniquement votre IP
sudo ufw allow from <VOTRE_IP> to any port 80
sudo ufw allow from <VOTRE_IP> to any port 443
```

## 📚 Ressources

- [Documentation officielle Pi-hole](https://docs.pi-hole.net/)
- [Forum Pi-hole](https://discourse.pi-hole.net/)
- [Listes de blocage recommandées](https://firebog.net/)

## ✅ Checklist post-installation

- [ ] Mot de passe admin changé
- [ ] Interface web accessible
- [ ] DNS configuré sur les appareils/routeur
- [ ] Test de blocage effectué
- [ ] Listes de blocage mises à jour
- [ ] Query Logging configuré
- [ ] Privacy Mode configuré
- [ ] Statistiques vérifiées

---

**Note :** Ce guide est basé sur l'installation via le script `bloc-ads.sh`. Pour une installation manuelle, consultez la [documentation officielle de Pi-hole](https://docs.pi-hole.net/).
