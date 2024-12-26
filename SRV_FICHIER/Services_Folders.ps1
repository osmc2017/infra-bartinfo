# Variables
$racinePartageServices = "D:\Partage\Services"  # Chemin racine pour les services
$ouDepartements = "OU=Departements,DC=bartinfo,DC=com"  # OU contenant les départements

# Importer le module Active Directory
Import-Module ActiveDirectory

# Vérification et création du dossier racine des services
if (!(Test-Path -Path $racinePartageServices)) {
    New-Item -ItemType Directory -Path $racinePartageServices
    Write-Host "Dossier racine créé : $racinePartageServices"
}

# Récupérer uniquement les OUs directement sous "Departements"
$departements = Get-ADOrganizationalUnit -Filter * -SearchBase $ouDepartements | Where-Object {
    ($_.DistinguishedName -split ',').Count -eq ($ouDepartements -split ',').Count + 1
}

foreach ($departement in $departements) {
    $departementName = ($departement.DistinguishedName -split ',')[0] -replace "^OU=", ""

    # Récupérer les sous-OUs (services) dans chaque département
    $services = Get-ADOrganizationalUnit -Filter * -SearchBase $departement.DistinguishedName | Where-Object {
        ($_.DistinguishedName -split ',').Count -eq ($departement.DistinguishedName -split ',').Count + 1
    }

    foreach ($service in $services) {
        $serviceName = ($service.DistinguishedName -split ',')[0] -replace "^OU=", ""
        $serviceFolder = Join-Path -Path $racinePartageServices -ChildPath $serviceName

        # Vérifier si le dossier du service existe déjà
        if (!(Test-Path -Path $serviceFolder)) {
            New-Item -ItemType Directory -Path $serviceFolder
            Write-Host "Dossier créé pour le service : $serviceName"
        }

        # Configurer les permissions NTFS
        $acl = Get-Acl -Path $serviceFolder

        # Supprimer l'héritage et définir des permissions spécifiques
        $acl.SetAccessRuleProtection($true, $false)  # Désactiver l'héritage et supprimer les règles héritées

        # Ajouter des permissions pour chaque utilisateur dans l'OU du service
        try {
            $users = Get-ADUser -Filter * -SearchBase $service.DistinguishedName -Properties SamAccountName
            foreach ($user in $users) {
                $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
                    $user.SamAccountName, 
                    "FullControl", 
                    "ContainerInherit,ObjectInherit", 
                    "None", 
                    "Allow"
                )))
                Write-Host "Permissions ajoutées pour l'utilisateur : $($user.SamAccountName)"
            }
        } catch {
            Write-Host "Erreur lors de la récupération ou de l'attribution des droits pour les utilisateurs de l'OU : $serviceName"
        }

        # Ajouter une règle pour les administrateurs
        $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
            "Administrators", 
            "FullControl", 
            "ContainerInherit,ObjectInherit", 
            "None", 
            "Allow"
        )))
        Write-Host "Permissions configurées pour les administrateurs."

        # Appliquer les permissions au dossier
        try {
            Set-Acl -Path $serviceFolder -AclObject $acl
            Write-Host "Permissions appliquées au service : $serviceName"
        } catch {
            Write-Host "Erreur lors de l'application des permissions pour : $serviceFolder"
        }
    }
}

Write-Host "Création des dossiers services terminée."
