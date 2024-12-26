# **Guide Utilisateur : Script de Création de Groupes AD par OU**

## **Description**
Ce script PowerShell permet de créer automatiquement un **groupe de sécurité** pour chaque **Unité Organisationnelle (OU)** d'un domaine Active Directory. Chaque groupe est nommé selon le modèle `G_<NomDeLOU>` et est localisé dans l’OU correspondante. Les utilisateurs présents dans l'OU sont ajoutés au groupe.

---

## **Prérequis**
1. **Environnement Active Directory fonctionnel :**
   - Domaine utilisé : `bartinfo.com`.
   - L'OU principale doit être clairement définie.

2. **Droits nécessaires :**
   - Le compte exécutant le script doit disposer de :
     - Permissions pour créer des groupes dans les OUs ciblées.
     - Permissions pour lire les utilisateurs des OUs.
     - Permissions pour modifier les membres des groupes.

3. **PowerShell :**
   - Le module Active Directory doit être installé sur la machine exécutant le script.
   - Exécuter PowerShell avec des **droits administratifs**.

---

## **Instructions**
### **Étape 1 : Configuration initiale**
1. Ouvrez PowerShell sur une machine membre du domaine Active Directory.
2. Copiez le script suivant dans un fichier `.ps1` (par exemple, `script_group_OU.ps1`).

```powershell
# Import du module Active Directory
Import-Module ActiveDirectory

# OU principale où commencer la création des groupes
$rootOU = "OU=Départements,DC=bartinfo,DC=com"  # Remplace par ton chemin exact

# Fonction pour vérifier si un groupe existe
function GroupExists {
    param (
        [string]$groupName
    )
    return (Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue)
}

# Fonction pour créer un groupe par OU
function CreateGroupForOU {
    param (
        [string]$ouName,
        [string]$ouPath
    )

    $groupName = "G_$ouName"

    if (-not (GroupExists $groupName)) {
        try {
            New-ADGroup -Name $groupName -GroupScope Global -GroupCategory Security -Path $ouPath -Description "Groupe pour l'OU $ouName"
            Write-Host "Groupe créé : $groupName dans $ouPath"
        } catch {
            Write-Host "Erreur lors de la création du groupe $groupName : $($_.Exception.Message)"
        }
    } else {
        Write-Host "Le groupe $groupName existe déjà."
    }
}

# Fonction pour ajouter les utilisateurs d'une OU au groupe correspondant
function AddUsersToGroup {
    param (
        [string]$groupName,
        [string]$ouPath
    )

    $users = Get-ADUser -Filter * -SearchBase $ouPath -ErrorAction SilentlyContinue
    foreach ($user in $users) {
        try {
            Add-ADGroupMember -Identity $groupName -Members $user.SamAccountName
            Write-Host "Utilisateur $($user.SamAccountName) ajouté au groupe $groupName"
        } catch {
            Write-Host "Erreur lors de l'ajout de l'utilisateur $($user.SamAccountName) au groupe $groupName : $($_.Exception.Message)"
        }
    }
}

# Parcours des OUs pour créer un groupe et ajouter les utilisateurs
$ous = Get-ADOrganizationalUnit -Filter * -SearchBase $rootOU

foreach ($ou in $ous) {
    $ouName = $ou.Name
    $ouPath = $ou.DistinguishedName

    # Crée un groupe pour l'OU
    CreateGroupForOU -ouName $ouName -ouPath $ouPath

    # Ajoute les utilisateurs de l'OU au groupe
    AddUsersToGroup -groupName "G_$ouName" -ouPath $ouPath
}
```

3. Modifiez la variable `$rootOU` pour correspondre à l’OU principale où commencer la création des groupes. Exemple :
   ```powershell
   $rootOU = "OU=Départements,DC=bartinfo,DC=com"
   ```

---

### **Étape 2 : Exécution du script**
1. Ouvrez PowerShell en tant qu’administrateur.
2. Naviguez vers le dossier contenant le script :
   ```powershell
   cd "Chemin\Vers\Votre\Script"
   ```
3. Exécutez le script :
   ```powershell
   .\script_group_OU.ps1
   ```

---

### **Étape 3 : Résultats attendus**
- **Groupes créés :**
  - Un groupe nommé `G_<NomDeLOU>` sera créé dans chaque OU.
  - Par exemple :
    - Pour une OU nommée "Marketing", un groupe `G_Marketing` sera créé.
    - Pour une OU nommée "IT", un groupe `G_IT` sera créé.

- **Utilisateurs ajoutés :**
  - Les utilisateurs présents dans chaque OU sont automatiquement ajoutés au groupe correspondant.

- **Messages dans la console :**
  - Le script affichera :
    - Les groupes créés ou déjà existants.
    - Les utilisateurs ajoutés à chaque groupe.
    - Les éventuelles erreurs (avec détails).

---

## **Personnalisation**
- **Noms des groupes :**
  - Le préfixe `G_` peut être modifié directement dans la ligne suivante du script :
    ```powershell
    $groupName = "G_$ouName"
    ```
  - Exemple : remplacer `G_` par `Grp_`.

- **Filtrage des utilisateurs :**
  - Par défaut, tous les utilisateurs d’une OU sont ajoutés au groupe. Vous pouvez modifier cette ligne :
    ```powershell
    $users = Get-ADUser -Filter * -SearchBase $ouPath -ErrorAction SilentlyContinue
    ```
    - Exemple : ajouter un filtre pour ne prendre que les utilisateurs actifs.

---

## **Résolution des Problèmes**
1. **Module Active Directory manquant :**
   - Installez-le via PowerShell :
     ```powershell
     Install-WindowsFeature -Name RSAT-AD-PowerShell -IncludeAllSubFeature
     ```

2. **Erreurs liées aux permissions :**
   - Vérifiez que le compte utilisé dispose des permissions nécessaires dans les OUs.

3. **Groupes non créés :**
   - Vérifiez que l’OU définie dans `$rootOU` existe dans Active Directory.

---



