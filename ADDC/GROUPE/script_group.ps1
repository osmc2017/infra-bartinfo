# Import du module Active Directory
Import-Module ActiveDirectory

# OU principale contenant les départements
$rootOU = "OU=Départements,DC=test,DC=lan"  # Remplace par ton chemin exact

# Fonction pour vérifier si un groupe existe
function GroupExists {
    param (
        [string]$groupName
    )
    return (Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue)
}

# Parcours des départements (OUs enfants directs de l'OU root)
$departements = Get-ADOrganizationalUnit -Filter * -SearchBase $rootOU | Where-Object { $_.DistinguishedName -notlike "*OU=Départements*" }

foreach ($departement in $departements) {
    $deptName = $departement.Name
    $deptPath = $departement.DistinguishedName

    # Crée un groupe pour le département seulement si c'est un niveau pertinent
    $deptGroupName = "G_Departement_$deptName"
    if (-not (GroupExists $deptGroupName)) {
        New-ADGroup -Name $deptGroupName -GroupScope Global -GroupCategory Security -Path $deptPath -Description "Groupe pour le département $deptName"
        Write-Host "Groupe créé : $deptGroupName"
    } else {
        Write-Host "Le groupe $deptGroupName existe déjà."
    }

    # Parcours des services dans ce département (enfants directs uniquement)
    $services = Get-ADOrganizationalUnit -Filter * -SearchBase $deptPath | Where-Object { $_.DistinguishedName -notlike "*OU=Départements*" }

    foreach ($service in $services) {
        $serviceName = $service.Name
        $servicePath = $service.DistinguishedName

        # Crée un groupe pour le service uniquement
        $serviceGroupName = "G_Service_$serviceName"
        if (-not (GroupExists $serviceGroupName)) {
            New-ADGroup -Name $serviceGroupName -GroupScope Global -GroupCategory Security -Path $servicePath -Description "Groupe pour le service $serviceName"
            Write-Host "Groupe créé : $serviceGroupName"
        } else {
            Write-Host "Le groupe $serviceGroupName existe déjà."
        }

        # Ajoute les utilisateurs du service au groupe
        $users = Get-ADUser -Filter * -SearchBase $servicePath
        foreach ($user in $users) {
            Add-ADGroupMember -Identity $serviceGroupName -Members $user.SamAccountName
            Write-Host "Utilisateur $($user.SamAccountName) ajouté au groupe $serviceGroupName"
        }
    }

    # Ajoute les utilisateurs du département au groupe du département
    $deptUsers = Get-ADUser -Filter * -SearchBase $deptPath
    foreach ($deptUser in $deptUsers) {
        Add-ADGroupMember -Identity $deptGroupName -Members $deptUser.SamAccountName
        Write-Host "Utilisateur $($deptUser.SamAccountName) ajouté au groupe $deptGroupName"
    }
}
