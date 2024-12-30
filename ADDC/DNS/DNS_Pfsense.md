# Tutoriel : Configurer l'accès à pfSense via `http://pfsense.bartinfo.com` et HTTPS

## Objectif
Ce tutoriel explique comment configurer pfSense pour accéder à son interface web via l'URL `http://pfsense.bartinfo.com` et ajoute une section optionnelle pour configurer l'accès HTTPS.

---

## 1. Configurer l'enregistrement DNS

1. **Ajoutez un enregistrement DNS dans votre serveur Active Directory** :
   - Accédez au Gestionnaire DNS.
   - Localisez votre zone DNS (par exemple, `bartinfo.com`).
   - Créez un nouvel enregistrement **A** :
     - **Nom** : `pfsense`
     - **Type** : A
     - **Adresse IP** : Adresse IP locale de pfSense (par exemple, `192.168.1.1`).

2. **Testez la résolution DNS** :
   - Sur un poste client, ouvrez un terminal (CMD) et exécutez :
     ```cmd
     nslookup pfsense.bartinfo.com
     ```
   - Vérifiez que l'adresse IP renvoyée correspond à celle de pfSense.

---

## 2. Autoriser le domaine dans pfSense

1. **Accédez à l'interface pfSense** :
   - Connectez-vous à pfSense via son adresse IP locale, par exemple : `http://192.168.1.1`.

2. **Ajoutez une exception pour le domaine** :
   - Allez dans **System > Advanced > Admin Access**.
   - Dans la section **DNS Rebind Check** :
     - Ajoutez votre domaine dans le champ **Alternate Hostnames** :
       ```
       pfsense.bartinfo.com
       ```
     - Vous pouvez ajouter plusieurs domaines en les séparant par un espace.
   - Cliquez sur **Save** pour enregistrer les modifications.

3. **Redémarrez les services DNS** (si nécessaire) :
   - Allez dans **Status > Services**.
   - Redémarrez le service **unbound (DNS Resolver)**.

4. **Testez l'accès HTTP** :
   - Ouvrez un navigateur sur un poste client et accédez à :
     ```
     http://pfsense.bartinfo.com
     ```

---

## 3. Gérer l'erreur "HTTP_REFERER Detected"

Si vous obtenez l'erreur **"An HTTP_REFERER was detected other than what is defined"**, suivez ces étapes :

1. **Accédez à l'interface pfSense via son IP** :
   - Connectez-vous à l'interface Web de pfSense à l'adresse IP locale (ex. : `http://192.168.1.1`).

2. **Ajoutez une exception pour les référents** :
   - Allez dans **System > Advanced > Admin Access**.
   - Dans la section **Web Configuration > Alternate Hostnames** :
     - Assurez-vous que votre domaine (`pfsense.bartinfo.com`) est ajouté.
     - Si ce n'est pas le cas, ajoutez-le :
       ```
       pfsense.bartinfo.com
       ```
     - Cliquez sur **Save**.

3. **Désactiver temporairement le vérificateur HTTP_REFERER** (si nécessaire) :
   - Toujours dans **System > Advanced > Admin Access**, décochez l'option **Check HTTP_REFERER**.
   - Cliquez sur **Save**. (Cette option peut être réactivée plus tard pour renforcer la sécurité.)

4. **Testez l'accès** :
   - Ouvrez un navigateur et accédez à :
     ```
     http://pfsense.bartinfo.com
     ```

---

## 4. Activer HTTPS pour pfSense (optionnel)

### **A. Créer un certificat SSL auto-signé**
1. **Allez dans Cert Manager** :
   - Naviguez vers **System > Cert Manager > Certificates**.
   - Cliquez sur **Add/Sign**.

2. **Configurez un certificat auto-signé** :
   - **Method** : Create an internal Certificate.
   - **Descriptive Name** : `pfsense-ssl`.
   - **Common Name** : `pfsense.bartinfo.com`.
   - Complétez les champs nécessaires et cliquez sur **Save**.

### **B. Activer HTTPS pour l'interface web**
1. **Accédez à Admin Access** :
   - Allez dans **System > Advanced > Admin Access**.
   - Sous la section **Protocol**, sélectionnez **HTTPS**.
   - Dans **SSL Certificate**, choisissez le certificat que vous venez de créer.
   - Cliquez sur **Save**.

2. **Testez l'accès HTTPS** :
   - Ouvrez un navigateur et accédez à :
     ```
     https://pfsense.bartinfo.com
     ```
   - Si vous voyez un avertissement sur le certificat, acceptez-le (c'est normal pour un certificat auto-signé).

### **C. Rediriger HTTP vers HTTPS (facultatif)**
1. Toujours dans **Admin Access**, configurez une redirection :
   - Activez l'option **Redirect HTTP to HTTPS**.
   - Enregistrez les modifications.

2. Testez l'accès :
   - Accédez à :
     ```
     http://pfsense.bartinfo.com
     ```
   - Vous serez automatiquement redirigé vers HTTPS.

---

## Conclusion
En suivant ce tutoriel, vous pouvez accéder à l'interface web de pfSense via `http://pfsense.bartinfo.com` avec une option pour activer et rediriger vers HTTPS pour un accès sécurisé. Si vous rencontrez des problèmes, vérifiez vos paramètres DNS, de certificat ou de pare-feu.

