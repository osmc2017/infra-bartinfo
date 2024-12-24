# Tutoriel : Installation de GLPI avec un script Bash

Ce tutoriel décrit les étapes nécessaires pour installer et configurer **GLPI** (Gestionnaire Libre de Parc Informatique) à l'aide d'un script Bash automatisé.



Vous pouvez le télécharger via la commande `wget A AJOUTER`
## Étape 1 : Mise à jour des paquets et installation du socle LAMP

- **LAMP** (Linux, Apache, MySQL/MariaDB, PHP) est installé pour servir d'environnement de base à GLPI.
- Les paquets suivants sont installés : 
  - Apache2 (serveur web)
  - PHP et ses modules nécessaires (ex. : php-json, php-mysql, etc.)
  - MariaDB (base de données relationnelle)

---

## Étape 2 : Configuration de la base de données

- L'utilisateur est invité à saisir :
  - Le nom de la base de données.
  - Le nom d'utilisateur et son mot de passe pour accéder à cette base.
- Une procédure de sécurisation de MariaDB est incluse.
- Le script crée la base de données et configure les privilèges pour l'utilisateur spécifié.

---

## Étape 3 : Téléchargement et installation de GLPI

- **Téléchargement** de la version 10.0.10 de GLPI depuis le dépôt officiel.
- Décompression et configuration des fichiers dans les répertoires appropriés :
  - `/var/www/glpi/` pour les fichiers accessibles par le serveur web.
  - `/etc/glpi/`, `/var/lib/glpi/`, et `/var/log/glpi/` pour une meilleure gestion des configurations, données et journaux.

Un fichier de configuration spécifique est ajouté pour indiquer les emplacements des données à GLPI.

---

## Étape 4 : Configuration d'Apache2

- Un hôte virtuel (VirtualHost) est configuré avec le nom de domaine fourni par l'utilisateur.
- Les modules Apache nécessaires (ex. : `rewrite`) sont activés.
- Les modifications sont appliquées après redémarrage d'Apache.

---

## Étape 5 : Utilisation de PHP8.2-FPM

- **PHP-FPM** (FastCGI Process Manager) est installé pour améliorer les performances PHP.
- Apache est configuré pour utiliser PHP-FPM :
  - Activation des modules nécessaires.
  - Mise à jour des paramètres pour sécuriser les cookies de session.

---

## Étape 6 : Vérification finale

- Une entrée est ajoutée au fichier `/etc/hosts` pour faciliter l'accès local à la base de données.
- MariaDB est redémarré pour appliquer les changements.

---

## Résultat attendu

À la fin de l'exécution du script, GLPI est installé, configuré, et prêt à être utilisé via le nom de domaine spécifié.

Vous pouvez accéder à l'interface GLPI en ouvrant votre navigateur et en saisissant : `http://<nom_de_domaine>`.

---

## Script

Voici le script complet utilisé dans ce tutoriel :

```bash
#!/bin/bash
# Mise à jour et mise à niveau des paquets
apt update && apt upgrade -y

# Installation d'Apache2, PHP et MariaDB
apt install apache2 php mariadb-server -y
apt install php-xml php-common php-json php-mysql php-mbstring php-curl php-gd php-intl php-zip php-bz2 php-imap php-apcu -y
apt install php-ldap -y

# Configuration de la base de données
read -p "Entrez le nom de la base de données (exemple: db24_glpi): " DB_NAME
DB_NAME=${DB_NAME:-db24_glpi}

read -p "Entrez le nom d'utilisateur pour la base de données (exemple: glpi_adm): " DB_USER
DB_USER=${DB_USER:-glpi_adm}

read -sp "Entrez le mot de passe pour l'utilisateur ${DB_USER} (exemple: Azerty1*): " DB_PASS
echo
DB_PASS=${DB_PASS:-Azerty1*}

mysql_secure_installation <<EOF
n
y
y
y
y
y
EOF

mysql -u root -p <<EOF
CREATE DATABASE $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost IDENTIFIED BY "$DB_PASS";
FLUSH PRIVILEGES;
EXIT
EOF

# Téléchargement et configuration de GLPI
cd /tmp
wget https://github.com/glpi-project/glpi/releases/download/10.0.10/glpi-10.0.10.tgz
tar -xzvf glpi-10.0.10.tgz -C /var/www/
chown www-data /var/www/glpi/ -R

mkdir /etc/glpi /var/lib/glpi /var/log/glpi
chown www-data /etc/glpi/ /var/lib/glpi/ /var/log/glpi/
mv /var/www/glpi/config /etc/glpi
mv /var/www/glpi/files /var/lib/glpi

echo "<?php
define('GLPI_CONFIG_DIR', '/etc/glpi/');
if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
    require_once GLPI_CONFIG_DIR . '/local_define.php';
}
?>" > /var/www/glpi/inc/downstream.php

echo "<?php
define('GLPI_VAR_DIR', '/var/lib/glpi/files');
define('GLPI_LOG_DIR', '/var/log/glpi');
?>" > /etc/glpi/local_define.php

# Configuration d'Apache
echo "<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    DocumentRoot /var/www/glpi/public
    <Directory /var/www/glpi/public>
        Require all granted
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/$DOMAIN_NAME.conf

a2ensite $DOMAIN_NAME.conf
a2dissite 000-default.conf
a2enmod rewrite
systemctl restart apache2

# Installation de PHP8.2-FPM
apt install php8.2-fpm
a2enmod proxy_fcgi setenvif
a2enconf php8.2-fpm
systemctl reload apache2

sed -i 's/;session.cookie_httponly =.*/session.cookie_httponly = on/' /etc/php/8.2/fpm/php.ini
systemctl restart php8.2-fpm.service

echo "<FilesMatch \.php$>
    SetHandler "proxy:unix:/run/php/php8.2-fpm.sock|fcgi://localhost/"
</FilesMatch>" >> /etc/apache2/sites-available/$DOMAIN_NAME.conf
systemctl restart apache2

# Vérifications finales
echo "127.0.0.1   $DB_NAME" >> /etc/hosts
systemctl restart mariadb
echo "Installation terminée avec succès !"
```