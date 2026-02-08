# Alamo - Scripts de Configuration et Sécurité

Collection de scripts pour configurer et sécuriser un serveur Linux (optimisé pour Raspberry Pi).

🔗 **Dépôt GitHub :** [https://github.com/Ax-404/ALAMO](https://github.com/Ax-404/ALAMO)

## 📋 Table des matières

- [Installation](#installation)
- [Scripts de Sécurité](#scripts-de-sécurité)
- [Scripts Réseau](#scripts-réseau)
- [Scripts de Gestion](#scripts-de-gestion)
- [Scripts de Vérification](#scripts-de-vérification)
- [Structure du Projet](#structure-du-projet)

## 🚀 Installation

### Installation de Git (si nécessaire)

Sur Raspberry Pi OS Lite, Git n'est pas installé par défaut. Installez-le d'abord :

```bash
sudo apt-get update
sudo apt-get install -y git
```

### Cloner le dépôt

```bash
git clone https://github.com/Ax-404/ALAMO.git
cd ALAMO
```

### Prérequis

- Système Linux (Debian/Ubuntu recommandé)
- Accès root (sudo)
- Git (généralement déjà installé sur Raspberry Pi OS)
- GPG installé (pour les scripts de gestion de mots de passe/liens)

```bash
# Vérifier/Installer Git (si nécessaire)
sudo ./scripts/install-git.sh

# Installer GPG si nécessaire
sudo apt-get update
sudo apt-get install -y gnupg
```

**Note :** Git est généralement déjà pré-installé sur Raspberry Pi OS. Le script `install-git.sh` vérifie simplement sa présence et l'installe uniquement si nécessaire.

## 🛠️ Scripts d'Installation

### Installation de Git

**`scripts/install-git.sh`**

Vérifie si Git est installé et l'installe si nécessaire. Git est généralement déjà pré-installé sur Raspberry Pi OS.

```bash
sudo ./scripts/install-git.sh
```

**Fonctionnalités :**
- Vérification de la présence de Git
- Installation automatique si absent
- Affichage de la version installée
- Instructions pour la configuration

### Configuration SSH pour GitHub

**`scripts/configure-github-ssh.sh`**

Configure l'authentification SSH pour GitHub (nécessaire pour push/pull).

```bash
./scripts/configure-github-ssh.sh
```

**Fonctionnalités :**
- Génération d'une clé SSH (ed25519)
- Instructions pour ajouter la clé sur GitHub
- Configuration automatique du remote Git en SSH
- Test de la connexion

**Note :** GitHub n'accepte plus les mots de passe pour Git. Utilisez ce script pour configurer SSH.

## 🔒 Scripts de Sécurité

### Protection SSH avec Fail2ban

**`scripts/configure-fail2ban.sh`**

Configure Fail2ban pour protéger SSH contre les attaques brute force.

```bash
sudo ./scripts/configure-fail2ban.sh
```

**Fonctionnalités :**
- Installation automatique de Fail2ban
- Configuration avec 3 tentatives max
- Bannissement de 1 heure
- Protection du service SSH

**Vérification :**
```bash
./scripts/check-fail2ban.sh
```

### Mises à jour automatiques

**`scripts/configure-unattended-upgrades.sh`**

Configure les mises à jour automatiques de sécurité.

```bash
sudo ./scripts/configure-unattended-upgrades.sh
```

**Fonctionnalités :**
- Installation de Unattended Upgrades
- Mises à jour de sécurité automatiques
- Nettoyage automatique des packages inutilisés
- Pas de redémarrage automatique (configurable)

### Configuration système complète

**`scripts/configure-system-security.sh`**

Script combiné qui configure Fail2ban et Unattended Upgrades en une seule commande.

```bash
sudo ./scripts/configure-system-security.sh
```

## 🌐 Scripts Réseau

### Blocage de publicités avec Pi-hole

**`scripts/bloc-ads.sh`**

Installe et configure Pi-hole pour bloquer les publicités au niveau réseau.

```bash
sudo ./scripts/bloc-ads.sh
```

**Fonctionnalités :**
- Installation automatique de Pi-hole
- Interface web d'administration
- Blocage des publicités et trackers
- Statistiques en temps réel

**Après installation :**
- Interface web : `http://<IP>/admin`
- Changer le mot de passe : `pihole -a -p`
- Vérifier le statut : `pihole status`

### Configuration Tailscale (VPN)

**`scripts/configure-tailscale.sh`**

Configure Tailscale pour un accès VPN sécurisé (optionnel).

```bash
sudo ./scripts/configure-tailscale.sh
```

**Fonctionnalités :**
- Installation de Tailscale
- Configuration du firewall
- Accès remote sécurisé

**Après installation :**
```bash
tailscale up
tailscale status
```

**Vérification :**
```bash
./scripts/check-tailscale.sh
```

**Dépannage :**
```bash
./scripts/tailscale-troubleshoot.sh
```

### Isolation réseau

**`scripts/configure-network-isolation.sh`**

Configure l'isolation réseau pour améliorer la sécurité.

```bash
sudo ./scripts/configure-network-isolation.sh
```

**Vérification :**
```bash
./scripts/check-network-isolation.sh
```

## 🔐 Scripts de Gestion

### Gestionnaire de mots de passe

**`scripts/password-word-finder.sh`**

Gestionnaire de mots de passe avec chiffrement GPG. Stocke les mots de passe dans un fichier `.txt` chiffré.

```bash
./scripts/password-word-finder.sh
```

**Fonctionnalités :**
- Chiffrement AES256 avec GPG
- Stockage dans `passwords.txt.gpg`
- Menu interactif
- Recherche et gestion complète

**Menu :**
1. Ajouter un mot de passe
2. Voir les mots de passe (formaté)
3. Voir le contenu brut de `passwords.txt`
4. Supprimer un mot de passe
5. Chercher un mot de passe
6. Changer le mot de passe
7. Quitter

**Format de stockage :**
```
[timestamp] Nom|Identifiant|Mot de passe|URL|Notes
```

### Gestionnaire de liens protégés

**`scripts/link-to-see.sh`**

Gestionnaire de liens sensibles avec chiffrement GPG. Stocke les liens dans un fichier `.txt` chiffré.

```bash
./scripts/link-to-see.sh
```

**Fonctionnalités :**
- Chiffrement AES256 avec GPG
- Stockage dans `links.txt.gpg`
- Menu interactif
- Ouverture automatique des liens

**Menu :**
1. Ajouter un lien
2. Voir les liens (formaté)
3. Voir le contenu brut de `links.txt`
4. Supprimer un lien
5. Chercher un lien
6. Ouvrir un lien
7. Changer le mot de passe
8. Quitter

**Format de stockage :**
```
[timestamp] Nom|URL|Notes
```

## ✅ Scripts de Vérification

### Vérification Fail2ban

**`scripts/check-fail2ban.sh`**

Vérifie l'état de Fail2ban et des jails actives.

```bash
./scripts/check-fail2ban.sh
```

### Vérification Tailscale

**`scripts/check-tailscale.sh`**

Vérifie la configuration et l'état de Tailscale.

```bash
./scripts/check-tailscale.sh
```

### Vérification isolation réseau

**`scripts/check-network-isolation.sh`**

Vérifie la configuration de l'isolation réseau.

```bash
./scripts/check-network-isolation.sh
```

## 📁 Structure du Projet

```
alamo/
├── README.md                    # Ce fichier
├── .env.example                 # Exemple de configuration (si nécessaire)
├── passwords.txt.gpg           # Mots de passe chiffrés (généré)
├── links.txt.gpg               # Liens chiffrés (généré)
├── .passwords-password         # Mot de passe pour passwords (généré)
├── .links-password             # Mot de passe pour links (généré)
└── scripts/
    ├── bloc-ads.sh             # Installation Pi-hole
    ├── password-word-finder.sh  # Gestionnaire de mots de passe
    ├── link-to-see.sh          # Gestionnaire de liens
    ├── configure-fail2ban.sh    # Configuration Fail2ban
    ├── configure-tailscale.sh  # Configuration Tailscale
    ├── configure-unattended-upgrades.sh  # Mises à jour auto
    ├── configure-system-security.sh     # Configuration complète
    ├── configure-network-isolation.sh   # Isolation réseau
    ├── check-fail2ban.sh        # Vérification Fail2ban
    ├── check-tailscale.sh       # Vérification Tailscale
    ├── check-network-isolation.sh # Vérification isolation
    └── tailscale-troubleshoot.sh # Dépannage Tailscale
```

## 🔐 Sécurité

### Fichiers sensibles

Les fichiers suivants contiennent des données sensibles et ne doivent **jamais** être partagés :

- `passwords.txt.gpg` - Mots de passe chiffrés
- `links.txt.gpg` - Liens sensibles chiffrés
- `.passwords-password` - Mot de passe de chiffrement
- `.links-password` - Mot de passe de chiffrement

**Recommandation :** Ajoutez ces fichiers à `.gitignore` si vous utilisez Git.

### Permissions

Les scripts sont exécutables. Si nécessaire :

```bash
chmod +x scripts/*.sh
```

## 🛠️ Utilisation Recommandée

### Configuration initiale d'un nouveau serveur

```bash
# 1. Sécurité de base
sudo ./scripts/configure-system-security.sh

# 2. Blocage de publicités (optionnel)
sudo ./scripts/bloc-ads.sh

# 3. VPN (optionnel)
sudo ./scripts/configure-tailscale.sh

# 4. Vérifications
./scripts/check-fail2ban.sh
```

### Gestion quotidienne

```bash
# Gérer les mots de passe
./scripts/password-word-finder.sh

# Gérer les liens sensibles
./scripts/link-to-see.sh
```

## 📝 Notes

- **Raspberry Pi 3+** : Les scripts sont optimisés pour fonctionner sur Raspberry Pi 3+ avec des ressources limitées
- **Sans Docker** : Les scripts de gestion de mots de passe utilisent GPG directement (pas de Docker) pour être légers
- **Chiffrement** : Tous les fichiers sensibles sont chiffrés avec GPG (AES256)

## 🐛 Dépannage

### Problème avec GPG

```bash
# Vérifier l'installation
which gpg

# Installer si nécessaire
sudo apt-get install -y gnupg
```

### Problème avec les permissions

```bash
# Rendre les scripts exécutables
chmod +x scripts/*.sh
```

### Problème avec Tailscale

```bash
# Utiliser le script de dépannage
./scripts/tailscale-troubleshoot.sh
```

## 📄 Licence

Ce projet est fourni tel quel pour usage personnel.

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

---

**⚠️ Important :** Ces scripts modifient la configuration système. Assurez-vous de comprendre ce que fait chaque script avant de l'exécuter, surtout avec les privilèges root.
