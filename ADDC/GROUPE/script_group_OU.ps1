# Import du module Active Directory
Import-Module ActiveDirectory

# OU principale où commencer la création des groupes
$rootOU = "OU=Départements,DC=test,DC=lan"  # Remplace par ton chemin exact

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
