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
```bash
sudo apt update && sudo apt upgrade -y
```

#### 2. Installer les paquets nécessaires
```bash
sudo apt install -y realmd sssd krb5-user samba-common-bin adcli oddjob oddjob-mkhomedir packagekit
```

Pendant l'installation de `krb5-user`, entrez le **nom du domaine AD** (par ex. `test.lan`).

---

#### 3. Rejoindre le domaine
1. Vérifiez que le domaine est détectable :
   ```bash
   sudo realm discover test.lan
   ```

   Si le domaine est détecté, il apparaîtra avec ses informations.

2. Joignez la machine au domaine :
   ```bash
   sudo realm join --user=Administrateur test.lan
   ```
   Remplacez `Administrateur` par un utilisateur ayant les droits de rejoindre le domaine. Il vous sera demandé le mot de passe.

3. Vérifiez que la machine a rejoint le domaine :
   ```bash
   realm list
   ```

---

#### 4. Configurer Kerberos (optionnel)
Si vous devez ajuster la configuration Kerberos, éditez `/etc/krb5.conf` :
```bash
sudo nano /etc/krb5.conf
```

Assurez-vous que le fichier contient les lignes suivantes, adaptées à votre domaine :
```ini
[libdefaults]
    default_realm = TEST.LAN

[realms]
    TEST.LAN = {
        kdc = dc1.test.lan
        admin_server = dc1.test.lan
    }

[domain_realm]
    .test.lan = TEST.LAN
    test.lan = TEST.LAN
```

---

#### 5. Configurer SSSD
Éditez le fichier `/etc/sssd/sssd.conf` :
```bash
sudo nano /etc/sssd/sssd.conf
```

Ajoutez cette configuration :
```ini
[sssd]
services = nss, pam
domains = test.lan

[domain/test.lan]
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

#### 6. Configurer Oddjob pour les répertoires personnels
Redémarrez le service Oddjob :
```bash
sudo systemctl enable oddjobd --now
```

Assurez-vous que `oddjob-mkhomedir` est correctement activé pour créer les répertoires personnels automatiquement.

---

#### 7. Tester l'authentification
1. Assurez-vous que les utilisateurs du domaine peuvent être résolus :
   ```bash
   id utilisateur@test.lan
   ```
   Remplacez `utilisateur` par un nom d'utilisateur du domaine.

2. Essayez de vous connecter avec un utilisateur du domaine :
   ```bash
   su - utilisateur@test.lan
   ```

---

#### 8. (Optionnel) Automatiser le montage des répertoires personnels
Pour que les répertoires personnels soient automatiquement créés à la connexion (alternative à Oddjob), éditez `/etc/pam.d/common-session` et ajoutez :
```bash
session required pam_mkhomedir.so skel=/etc/skel umask=0077
```

---

### Dépannage
- Si la machine n'apparaît pas dans l'AD, vérifiez le nom d'hôte avec :
  ```bash
  hostnamectl
  ```
  Et assurez-vous qu'il est unique.

- En cas de problème avec Kerberos, testez la connectivité :
  ```bash
  kinit utilisateur@test.lan
  ```

- Vérifiez les journaux :
  ```bash
  sudo journalctl -xe
  ```

---

Ce guide devrait suffire pour intégrer Debian à un domaine Active Directory. Si vous avez des questions ou des problèmes spécifiques, n'hésitez pas à demander !
