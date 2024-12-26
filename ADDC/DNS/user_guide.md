## Intégration d'une machine Debian à un Active Directory (AD)

### Pré-requis
1. **Débian pré-installée** : Vous devez avoir une machine Debian fonctionnelle.
2. **Paquets nécessaires** :
   - `realmd` : Gestion de l'intégration au domaine.
   - `sssd` : Authentification centralisée.
   - `krb5-user` : Outil pour Kerberos.
   - `samba` et `samba-common-bin` : Configuration et gestion de Samba.
   - `adcli` : Gestion des connexions au domaine.
   - `oddjob` et `oddjob-mkhomedir` : Gestion automatique des répertoires personnels.
   - `packagekit` : Gestion des paquets (optionnel, en cas d'environnement graphique).

---

### Étapes

#### 1. Mettre à jour Debian
**Description :** Cette étape assure que votre système dispose des dernières mises à jour de sécurité et de fonctionnalité.
```bash
sudo apt update && sudo apt upgrade -y
```

#### 2. Installer les paquets nécessaires
**Description :** Installe les outils et services requis pour intégrer la machine Debian à l'Active Directory.
```bash
sudo apt install -y realmd sssd krb5-user samba-common-bin adcli oddjob oddjob-mkhomedir packagekit
```

#### 3. Configurer la résolution DNS
**Description :** Permet à la machine de résoudre correctement les noms de domaine du serveur Active Directory.

1. Éditez le fichier :
   ```bash
   sudo nano /etc/resolv.conf
   ```

2. Ajoutez l'adresse IP de votre serveur DNS (généralement le serveur AD) :
   ```conf
   nameserver <IP_DU_SERVEUR_DNS>
   search bartinfo.com
   ```
   Remplacez `<IP_DU_SERVEUR_DNS>` par l'adresse IP de votre serveur AD et `bartinfo.com` par votre domaine.

3. Assurez-vous que le fichier n'est pas remplacé automatiquement par le système :
   ```bash
   sudo chattr +i /etc/resolv.conf
   ```
   (Vous pouvez enlever cette protection avec `sudo chattr -i /etc/resolv.conf` si besoin.)

Vérifiez la résolution DNS :
```bash
nslookup dc1.bartinfo.com
```
Assurez-vous que le serveur DNS renvoie une réponse correcte.

---

#### 4. Rejoindre le domaine
**Description :** Connecte la machine Debian à l'Active Directory et configure son intégration.

1. Vérifiez que le domaine est détectable :
   ```bash
   sudo realm discover bartinfo.com
   ```

   Si le domaine est détecté, il apparaîtra avec ses informations.

2. Joignez la machine au domaine :
   ```bash
   sudo realm join --user=Administrateur bartinfo.com
   ```
   Remplacez `Administrateur` par un utilisateur ayant les droits de rejoindre le domaine. Il vous sera demandé le mot de passe.

3. Vérifiez que la machine a rejoint le domaine :
   ```bash
   realm list
   ```

---

#### 5. Configurer Kerberos (optionnel)
**Description :** Configure le service Kerberos pour l'authentification centralisée avec l'Active Directory.

Si vous devez ajuster la configuration Kerberos, éditez `/etc/krb5.conf` :
```bash
sudo nano /etc/krb5.conf
```

Assurez-vous que le fichier contient les lignes suivantes, adaptées à votre domaine :
```ini
[libdefaults]
    default_realm = bartinfo.com

[realms]
    bartinfo.com = {
        kdc = dc1.bartinfo.com
        admin_server = dc1.bartinfo.com
    }

[domain_realm]
    .bartinfo.com = bartinfo.com
    bartinfo.com = bartinfo.com
```

---

#### 6. Configurer SSSD
**Description :** SSSD (System Security Services Daemon) gère l'authentification et la résolution des identités pour les utilisateurs du domaine.

Éditez le fichier `/etc/sssd/sssd.conf` :
```bash
sudo nano /etc/sssd/sssd.conf
```

Ajoutez cette configuration :
```ini
[sssd]
services = nss, pam
domains = bartinfo.com

[domain/bartinfo.com]
id_provider = ad
access_provider = ad
override_homedir = /home/%u
default_shell = /bin/bash
```

Appliquez les permissions correctes :
```bash
sudo chmod 600 /etc/sssd/sssd.conf
```

Redémarrez le service SSSD :
```bash
sudo systemctl restart sssd
```

---

#### 7. Configurer Oddjob pour les répertoires personnels
**Description :** Active la création automatique des répertoires personnels pour les utilisateurs du domaine lors de leur première connexion.

Redémarrez le service Oddjob :
```bash
sudo systemctl enable oddjobd --now
```

Assurez-vous que `oddjob-mkhomedir` est correctement activé pour créer les répertoires personnels automatiquement.

---

#### 8. Tester l'authentification
**Description :** Vérifie que les utilisateurs du domaine peuvent s'authentifier et que leurs informations sont correctement résolues.

1. Assurez-vous que les utilisateurs du domaine peuvent être résolus :
   ```bash
   id utilisateur@bartinfo.com
   ```
   Remplacez `utilisateur` par un nom d'utilisateur du domaine.

2. Essayez de vous connecter avec un utilisateur du domaine :
   ```bash
   su - utilisateur@bartinfo.com
   ```

---

#### 9. (Optionnel) Automatiser le montage des répertoires personnels
**Description :** Configure PAM pour créer automatiquement les répertoires personnels à la connexion des utilisateurs.

Pour que les répertoires personnels soient automatiquement créés à la connexion (alternative à Oddjob), éditez `/etc/pam.d/common-session` et ajoutez :
```bash
session required pam_mkhomedir.so skel=/etc/skel umask=0077
```

---

### Dépannage
**Description :** Conseils pour résoudre les problèmes courants rencontrés lors de l'intégration.

- Si la machine n'apparaît pas dans l'AD, vérifiez le nom d'hôte avec :
  ```bash
  hostnamectl
  ```
  Et assurez-vous qu'il est unique.

- En cas de problème avec Kerberos, testez la connectivité :
  ```bash
  kinit utilisateur@bartinfo.com
  ```

- Vérifiez les journaux :
  ```bash
  sudo journalctl -xe
  ```

---

