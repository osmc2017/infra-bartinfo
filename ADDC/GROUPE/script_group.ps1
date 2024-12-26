# Import du module Active Directory
Import-Module ActiveDirectory

# OU principale contenant les départements
$rootOU = "OU=Départements,DC=test,DC=lan"  # Remplace par ton chemin exact

# Parcours des départements
$departements = Get-ADOrganizationalUnit -Filter * -SearchBase $rootOU

foreach ($departement in $departements) {
    $deptName = $departement.Name
    $deptPath = $departement.DistinguishedName

    # Crée un groupe pour le département
    $deptGroupName = "G_Departement_$deptName"
    if (-not (Get-ADGroup -Filter {Name -eq $deptGroupName})) {
        New-ADGroup -Name $deptGroupName -GroupScope Global -GroupCategory Security -Path $deptPath -Description "Groupe pour le département $deptName"
        Write-Host "Groupe créé : $deptGroupName"
    } else {
        Write-Host "Le groupe $deptGroupName existe déjà."
    }

    # Parcours des services dans le département (uniquement les OUs enfants directs)
    $services = Get-ADOrganizationalUnit -Filter * -SearchBase $deptPath | Where-Object { $_.DistinguishedName -notlike "*OU=Départements*" }

    foreach ($service in $services) {
        $serviceName = $service.Name
        $servicePath = $service.DistinguishedName

        # Crée un groupe pour le service
        $serviceGroupName = "G_Service_$serviceName"
        if (-not (Get-ADGroup -Filter {Name -eq $serviceGroupName})) {
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
