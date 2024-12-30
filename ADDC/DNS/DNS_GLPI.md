# Tutoriel : Accès à GLPI via l’URL http://glpi.bartinfo.com

## Objectif
Ce tutoriel vous guide pour configurer l’accès à votre instance GLPI à l’aide de l’URL `http://glpi.bartinfo.com`.

---

## Prérequis
- Un serveur GLPI fonctionnel (installé dans `/var/www/html/glpi`).
- Un nom de domaine configuré (`glpi.bartinfo.com`).
- Apache installé sur le serveur GLPI.

---

## Étapes

### **1. Configuration DNS**
1. **Ajouter un enregistrement DNS dans Active Directory** :
   - Accédez à votre serveur DNS.
   - Ajoutez un enregistrement **A** :
     - **Nom** : `glpi`
     - **Type** : A
     - **Adresse IP** : Adresse IP du serveur GLPI.

2. **Tester la résolution DNS** :
   - Sur un client du domaine, exécutez :
     ```cmd
     nslookup glpi.bartinfo.com
     ```
   - Assurez-vous que l’adresse IP renvoyée est correcte.

---

### **2. Configuration Apache**

1. **Modifier le fichier de configuration Apache** :
   - Localisez le fichier de configuration dans `/etc/apache2/sites-available/`.
   - Si vous avez un fichier existant, comme `bartinfo.local.conf`, modifiez-le :
     ```bash
     sudo nano /etc/apache2/sites-available/bartinfo.local.conf
     ```

2. **Configurer le VirtualHost pour GLPI** :
   Ajoutez ou modifiez le bloc de configuration suivant :
   ```apache
   <VirtualHost *:80>
       ServerName glpi.bartinfo.com

       DocumentRoot /var/www/html/glpi

       <Directory /var/www/html/glpi>
           Options FollowSymLinks
           AllowOverride All
           Require all granted
       </Directory>

       ErrorLog ${APACHE_LOG_DIR}/glpi_error.log
       CustomLog ${APACHE_LOG_DIR}/glpi_access.log combined
   </VirtualHost>
   ```

3. **Activer la configuration et redémarrer Apache** :
   ```bash
   sudo a2ensite bartinfo.local.conf
   sudo systemctl restart apache2
   ```

---

### **3. Tester l’URL**
1. **Accéder à GLPI** :
   - Ouvrez un navigateur sur un client du domaine.
   - Saisissez l’URL : `http://glpi.bartinfo.com`.

2. **Vérifiez que l’interface de GLPI s’affiche correctement.**

---

### **4. Ajouter HTTPS (optionnel)**
Pour sécuriser l’accès, vous pouvez ajouter un certificat SSL :

1. **Installer Certbot** (si non installé) :
   ```bash
   sudo apt install certbot python3-certbot-apache
   ```

2. **Générer un certificat SSL pour glpi.bartinfo.com** :
   ```bash
   sudo certbot --apache -d glpi.bartinfo.com
   ```

3. **Tester l’accès HTTPS** :
   - Accédez à : `https://glpi.bartinfo.com`.
   - Assurez-vous que le certificat est valide.

4. **Rediriger HTTP vers HTTPS** (facultatif) :
   - Ajoutez ce bloc dans votre configuration Apache :
     ```apache
     <VirtualHost *:80>
         ServerName glpi.bartinfo.com
         RewriteEngine On
         RewriteCond %{HTTPS} !=on
         RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]
     </VirtualHost>
     ```
   - Redémarrez Apache :
     ```bash
     sudo systemctl restart apache2
     ```

---

## Conclusion
Vous pouvez désormais accéder à GLPI via `http://glpi.bartinfo.com` ou `https://glpi.bartinfo.com` si HTTPS est configuré. Assurez-vous que votre configuration DNS et Apache est correcte pour éviter tout problème. 😊

