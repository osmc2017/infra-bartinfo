# Tuto : Configuration de l’authentification LDAP via Active Directory dans GLPI

## Sommaire
1. [Présentation](#présentation)
2. [Configuration cible](#configuration-cible)
3. [Installer l’extension LDAP de PHP](#installer-lextension-ldap-de-php)
4. [Ajouter un annuaire LDAP dans GLPI](#ajouter-un-annuaire-ldap-dans-glpi)
5. [Tester la connexion Active Directory](#tester-la-connexion-active-directory)
6. [Forcer une synchronisation Active Directory](#forcer-une-synchronisation-active-directory)
7. [Conclusion](#conclusion)

---

## Présentation
Ce tutoriel explique comment configurer l’authentification LDAP dans GLPI afin de permettre aux utilisateurs Active Directory (AD) du domaine `bartinfo.com` de se connecter avec leurs identifiants habituels. GLPI s’appuie sur un modèle LDAP pour importer les comptes AD et synchroniser les données utilisateur.

## Configuration cible
- **Domaine Active Directory** : `bartinfo.com`
- **Contrôleur de domaine (AD)** : 192.168.0.2
- **Serveur GLPI** : 192.168.0.35
- **Port LDAP** : 389 (non-sécurisé, sinon utiliser LDAPS sur le port 636)
- **Compte de synchronisation** : `Sync_GLPI`, situé dans `OU=Departements,DC=bartinfo,DC=com`
- **OU des utilisateurs** : `OU=Departements,DC=bartinfo,DC=com`

---

## Installer l’extension LDAP de PHP
Pour que GLPI puisse communiquer avec AD, l’extension LDAP de PHP doit être installée.

1. Connectez-vous au serveur GLPI.
2. Exécutez les commandes suivantes :

```bash
sudo apt-get update
sudo apt-get install php-ldap
```

Cette extension sera automatiquement activée.

---

## Ajouter un annuaire LDAP dans GLPI

1. Connectez-vous à GLPI avec un compte administrateur.
2. Accédez au menu **Configuration > Authentification**.
3. Cliquez sur **Annuaire LDAP**, puis sur **Ajouter**.
4. Renseignez les champs comme suit :

- **Nom** : `Active Directory - bartinfo.com`
- **Serveur par défaut** : Oui
- **Actif** : Oui
- **Serveur** : `192.168.0.2`
- **Port** : `389`
- **Filtre de connexion** :
  ```
  (&(objectClass=user)(objectCategory=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
  ```
- **BaseDN** : `OU=Personnel,DC=bartinfo,DC=com`
- **Utiliser bind** : Oui
- **DN du compte** : `CN=Sync_GLPI,OU=Departements,DC=bartinfo,DC=com`
- **Mot de passe du compte** : Mot de passe associé
- **Champ de l’identifiant** : `userPrincipalName`
- **Champ de synchronisation** : `objectGUID`

5. Cliquez sur **Ajouter**.

GLPI effectuera un test de connexion LDAP. Si une erreur survient, vérifiez que l’adresse IP du contrôleur de domaine est correcte et que le mot de passe du compte de synchronisation est valide.

---

## Tester la connexion Active Directory

1. Depuis l’écran de configuration LDAP, cliquez sur votre annuaire puis sur **Tester**.
2. Essayez de vous connecter à GLPI avec un utilisateur AD (par exemple `user@bartinfo.com`) et son mot de passe AD.
3. Si la connexion réussit, GLPI créera automatiquement un compte utilisateur dans sa base de données.

---

## Forcer une synchronisation Active Directory

1. Rendez-vous dans **Administration > Utilisateurs**.
2. Cliquez sur **Liaison annuaire LDAP**.
3. Choisissez l’action souhaitée :
   - **Importation de nouveaux utilisateurs** : pour ajouter en masse des comptes AD.
   - **Synchroniser les utilisateurs existants** : pour mettre à jour les comptes déjà liés.
4. Sélectionnez les utilisateurs ou groupes souhaités et cliquez sur **Actions**.

---

## Conclusion
Vous avez maintenant configuré GLPI pour qu’il s’authentifie avec les comptes utilisateurs Active Directory du domaine `bartinfo.com`. Cette intégration simplifie la gestion des accès et garantit que les utilisateurs se connectent avec leurs identifiants habituels.

N’hésitez pas à explorer les options de mappage des attributs LDAP et de configuration des rôles utilisateur pour affiner l’intégration.

