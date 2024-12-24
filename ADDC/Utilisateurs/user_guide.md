# Guide d'utilisation : Script de création d'utilisateurs dans Active Directory

## Introduction
Ce script PowerShell permet de créer des utilisateurs dans Active Directory (AD) en fonction des informations fournies dans un fichier CSV. Les utilisateurs sont automatiquement placés dans les bonnes Unités Organisationnelles (OUs) basées sur leur département et leur service.

---

## Fonctionnalités principales
1. Création automatique des utilisateurs à partir d'un fichier CSV.
2. Placement des utilisateurs dans les OUs correspondantes selon les départements et services spécifiés.
3. Validation de l'existence des OUs avant la création des utilisateurs.
4. Vérification si l'utilisateur existe déjà avant de le créer.
5. Affectation d'un mot de passe par défaut et configuration pour demander un changement au premier login.

---

## Pré-requis

### 1. Infrastructure
- Windows Server avec Active Directory installé.
- Module PowerShell **ActiveDirectory** disponible et importé.
- Droits d'administration Active Directory.

### 2. Fichier CSV
Le fichier CSV doit contenir les colonnes suivantes :
- **Prénom** : Le prénom de l'utilisateur.
- **Nom** : Le nom de l'utilisateur.
- **Département** : Le département auquel l'utilisateur appartient.
- **Service** : Le service (facultatif, peut être vide ou "-").
- **Fonction** : Le poste ou le rôle de l'utilisateur dans l'organisation.

#### Exemple de fichier CSV attendu :
```csv
Prénom,Nom,Département,Service,Fonction
Lupe,DaSilva,Finance,Comptabilité,Comptable
Marie,Dupont,RH,Recrutement,Recruteur
Jean,Martin,IT,-,Technicien
```

### 3. Structure des OUs
Le script suppose que les OUs ont été créées préalablement avec cette structure :
```
OU=Service,OU=Département,OU=Departements,DC=demo,DC=lan
OU=Département,OU=Departements,DC=demo,DC=lan
```

### 4. Donner les droits au script avec: 

`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

### 5. Encodage du script: 

AINSI

---

## Description du script

### Chemin du fichier CSV
Le chemin du fichier CSV est défini dans la variable `$CSVFile` :
```powershell
$CSVFile = "C:\Users\Administrator\Desktop\bartinfo.csv"
```
Adaptez ce chemin selon l'emplacement réel de votre fichier.

### Parcours des données CSV
Le script lit chaque ligne du fichier CSV et extrait les informations nécessaires pour créer l'utilisateur.

### Placement dans les OUs
- Si la colonne **Service** contient une valeur valide, l'utilisateur est placé dans l'OU correspondante au service.
- Si la colonne **Service** est vide ou contient "-", l'utilisateur est placé dans l'OU du département.

### Vérification des OUs
Avant de créer un utilisateur, le script vérifie si l'OU existe. Si l'OU est introuvable, l'utilisateur est ignoré et un message d'avertissement est affiché.

### Création des utilisateurs
Le script utilise les commandes suivantes pour créer un utilisateur :
- `New-ADUser` : Crée un nouvel utilisateur avec les informations extraites du CSV.
- Les champs comme `SamAccountName`, `GivenName`, `Surname`, `EmailAddress`, et `Title` sont remplis en fonction des données CSV.
- Le mot de passe par défaut est défini sur **Azerty1***, et l'utilisateur devra le changer lors de sa première connexion.

### Vérification des doublons
Avant de créer un utilisateur, le script vérifie si un utilisateur avec le même `SamAccountName` existe déjà. Si c'est le cas, il affiche un message d'avertissement et passe à l'utilisateur suivant.

---

## Messages affichés

### Succès
Lorsqu'un utilisateur est créé avec succès, le script affiche :
```plaintext
Utilisateur 'Nom Prénom' créé avec succès dans 'OUPath'.
```

### Erreur OU introuvable
Si l'OU spécifiée n'existe pas :
```plaintext
L'OU spécifiée 'OUPath' n'existe pas. L'utilisateur 'Nom Prénom' sera ignoré.
```

### Doublon
Si un utilisateur avec le même `SamAccountName` existe déjà :
```plaintext
L'identifiant SamAccountName existe déjà dans l'AD.
```

---

## Instructions d'exécution

### Étape 1 : Préparer l'environnement
1. Assurez-vous que les OUs nécessaires ont été créées dans Active Directory.
2. Vérifiez que le fichier CSV est correctement formaté et placé à l'emplacement spécifié.

### Étape 2 : Lancer le script
1. Ouvrez PowerShell en tant qu'administrateur.
2. Exécutez le script.

### Étape 3 : Vérifier les résultats
- Consultez les messages affichés pour confirmer que les utilisateurs ont été créés correctement.
- Utilisez la console Active Directory Users and Computers (`dsa.msc`) pour vérifier les utilisateurs et leur emplacement.

---

## Dépannage

### Erreurs courantes
- **L'OU spécifiée n'existe pas :** Assurez-vous que les OUs sont correctement créées avec les noms exacts.
- **L'identifiant existe déjà :** Vérifiez si un utilisateur avec le même login est déjà présent dans Active Directory.
- **Erreur lors de la création de l'utilisateur :** Vérifiez les détails de l'erreur affichée pour identifier le problème.

### Support
Si des problèmes persistent, vérifiez les messages d'erreur ou adaptez le script pour répondre aux besoins spécifiques de votre organisation.

