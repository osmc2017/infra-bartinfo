# Import du module Active Directory
Import-Module ActiveDirectory

# OU principale contenant les départements
$rootOU = "OU=Départements,DC=test,DC=lan"  # Remplace par ton chemin exact

# Fonction pour vérifier si un groupe existe
function GroupExists {
    param (
        [string]$groupName
    )
    return (Get-ADGroup -Filter {Name -eq $groupName} -ErrorAction SilentlyContinue)
}

# Fonction pour créer un groupe uniquement s'il n'existe pas
function CreateGroupIfNotExists {
    param (
        [string]$groupName,
        [string]$groupPath,
        [string]$description
    )
    if (-not (GroupExists $groupName)) {
        try {
            New-ADGroup -Name $groupName -GroupScope Global -GroupCategory Security -Path $groupPath -Description $description
            Write-Host "Groupe créé : $groupName"
        } catch {
            Write-Host "Erreur lors de la création du groupe $groupName : $($_.Exception.Message)"
        }
    } else {
        Write-Host "Le groupe $groupName existe déjà."
    }
}

# Parcours des départements (OUs enfants directs de l'OU root uniquement)
$departements = Get-ADOrganizationalUnit -Filter * -SearchBase $rootOU | Where-Object { $_.DistinguishedName -notmatch "OU=Départements," }

foreach ($departement in $departements) {
    $deptName = $departement.Name
    $deptPath = $departement.DistinguishedName

    # Crée un groupe pour le département
    $deptGroupName = "G_Departement_$deptName"
    CreateGroupIfNotExists -groupName $deptGroupName -groupPath $deptPath -description "Groupe pour le département $deptName"

    # Parcours des services dans le département (enfants directs uniquement)
    $services = Get-ADOrganizationalUnit -Filter * -SearchBase $deptPath | Where-Object { $_.DistinguishedName -notmatch "OU=Départements," }

    foreach ($service in $services) {
        $serviceName = $service.Name
        $servicePath = $service.DistinguishedName

        # Crée un groupe pour le service
        $serviceGroupName = "G_Service_$serviceName"
        CreateGroupIfNotExists -groupName $serviceGroupName -groupPath $servicePath -description "Groupe pour le service $serviceName"

        # Ajoute les utilisateurs du service au groupe
        $users = Get-ADUser -Filter * -SearchBase $servicePath -ErrorAction SilentlyContinue
        foreach ($user in $users) {
            try {
                Add-ADGroupMember -Identity $serviceGroupName -Members $user.SamAccountName
                Write-Host "Utilisateur $($user.SamAccountName) ajouté au groupe $serviceGroupName"
            } catch {
                Write-Host "Erreur lors de l'ajout de l'utilisateur $($user.SamAccountName) au groupe $serviceGroupName : $($_.Exception.Message)"
            }
        }
    }

    # Ajoute les utilisateurs du département au groupe du département
    $deptUsers = Get-ADUser -Filter * -SearchBase $deptPath -ErrorAction SilentlyContinue
    foreach ($deptUser in $deptUsers) {
        try {
            Add-ADGroupMember -Identity $deptGroupName -Members $deptUser.SamAccountName
            Write-Host "Utilisateur $($deptUser.SamAccountName) ajouté au groupe $deptGroupName"
        } catch {
            Write-Host "Erreur lors de l'ajout de l'utilisateur $($deptUser.SamAccountName) au groupe $deptGroupName : $($_.Exception.Message)"
        }
    }
}
