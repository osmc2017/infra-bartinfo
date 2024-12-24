#!/bin/bash

# Mise à jour et mise à niveau des paquets
apt update && apt upgrade -y

## 1. Installation du socle LAMP

# Installation d'Apache2, PHP et MariaDB
apt install apache2 php mariadb-server -y

# Installation des modules PHP nécessaires
apt install php-xml php-common php-json php-mysql php-mbstring php-curl php-gd php-intl php-zip php-bz2 php-imap php-apcu -y

# Installation de php-ldap
apt install php-ldap -y

## 2. PREPARATION DE LA BASE DONNEE

# Demande à l'utilisateur les informations de base de données
read -p "Entrez le nom de la base de données (exemple: db24_glpi): " DB_NAME
DB_NAME=${DB_NAME:-db24_glpi}  # Valeur par défaut si l'utilisateur appuie sur Entrée sans saisir

read -p "Entrez le nom d'utilisateur pour la base de données (exemple: glpi_adm): " DB_USER
DB_USER=${DB_USER:-glpi_adm}  # Valeur par défaut si l'utilisateur appuie sur Entrée sans saisir

read -sp "Entrez le mot de passe pour l'utilisateur ${DB_USER} (exemple: Azerty1*): " DB_PASS
echo
DB_PASS=${DB_PASS:-Azerty1*}  # Valeur par défaut si l'utilisateur appuie sur Entrée sans saisir

# Sécurisation de MariaDB
mysql_secure_installation <<EOF
n
y
y
y
y
y
EOF

# Connexion à MariaDB et création de la base
mysql -u root -p <<EOF
CREATE DATABASE $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost IDENTIFIED BY "$DB_PASS";
FLUSH PRIVILEGES;
EXIT
EOF

## 3. Téléchargement de GLPI

# Demande du nom de domaine
read -p "Entrez le nom de domaine (exemple: domaine.local): " DOMAIN_NAME
DOMAIN_NAME=${DOMAIN_NAME:-domaine.local}  # Valeur par défaut si l'utilisateur appuie sur Entrée sans saisir

# 3.1 Téléchargement et installation de GLPI
cd /tmp
wget https://github.com/glpi-project/glpi/releases/download/10.0.10/glpi-10.0.10.tgz
tar -xzvf glpi-10.0.10.tgz -C /var/www/
chown www-data /var/www/glpi/ -R

# 3.2 Sécurisation de l'installation de GLPI
mkdir /etc/glpi
chown www-data /etc/glpi/
mv /var/www/glpi/config /etc/glpi
mkdir /var/lib/glpi
chown www-data /var/lib/glpi/
mv /var/www/glpi/files /var/lib/glpi
mkdir /var/log/glpi
chown www-data /var/log/glpi

# 3.3 Configuration pour indiquer à GLPI où sont stockées les données
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

## 4. Préparer Apache2

# Configuration du VirtualHost pour GLPI
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

# Activation du site et des modules Apache
a2ensite $DOMAIN_NAME.conf
a2dissite 000-default.conf
a2enmod rewrite
systemctl restart apache2

## 5. Utilisation de PHP8.2-FPM

# Installation de PHP8.2-FPM
apt install php8.2-fpm

# Activation des modules Apache pour PHP-FPM
a2enmod proxy_fcgi setenvif
a2enconf php8.2-fpm
systemctl reload apache2

# Modification du fichier php.ini pour activer la sécurité des cookies de session
sed -i 's/;session.cookie_httponly =.*/session.cookie_httponly = on/' /etc/php/8.2/fpm/php.ini
systemctl restart php8.2-fpm.service

# Configuration d'Apache pour utiliser PHP8.2-FPM
echo "<FilesMatch \\.php$>
    SetHandler \"proxy:unix:/run/php/php8.2-fpm.sock|fcgi://localhost/\"
</FilesMatch>" >> /etc/apache2/sites-available/$DOMAIN_NAME.conf

# Redémarrer Apache2 pour prendre en compte la nouvelle configuration
systemctl restart apache2

## 6. Vérification et ajout de l'utilisateur MariaDB

# Ajout de l'entrée dans le fichier hosts
echo "127.0.0.1   $DB_NAME" >> /etc/hosts

# Redémarrage de MariaDB
systemctl restart mariadb

echo "Installation terminée avec succès !"
