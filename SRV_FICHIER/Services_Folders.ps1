# Variables
$racinePartageDepartements = "D:\Partage\Departements"  # Chemin racine pour les départements
$ouDepartements = "OU=Departements,DC=bartinfo,DC=com"  # OU contenant les départements

# Importer le module Active Directory
Import-Module ActiveDirectory

# Vérification et création du dossier racine des départements
if (!(Test-Path -Path $racinePartageDepartements)) {
    Write-Host "Erreur : Le dossier racine des départements n'existe pas. Exécution annulée."
    exit
}

# Récupérer uniquement les OUs directement sous "Departements"
$departements = Get-ADOrganizationalUnit -Filter * -SearchBase $ouDepartements | Where-Object {
    ($_.DistinguishedName -split ',').Count -eq ($ouDepartements -split ',').Count + 1
}

foreach ($departement in $departements) {
    $departementName = ($departement.DistinguishedName -split ',')[0] -replace "^OU=", ""
    $departementFolder = Join-Path -Path $racinePartageDepartements -ChildPath $departementName

    # Vérifier si le dossier du département existe
    if (!(Test-Path -Path $departementFolder)) {
        Write-Host "Erreur : Le dossier pour le département $departementName n'existe pas. Skipping..."
        continue
    }

    # Récupérer les sous-OUs (services) dans chaque département
    $services = Get-ADOrganizationalUnit -Filter * -SearchBase $departement.DistinguishedName | Where-Object {
        ($_.DistinguishedName -split ',').Count -eq ($departement.DistinguishedName -split ',').Count + 1
    }

    foreach ($service in $services) {
        $serviceName = ($service.DistinguishedName -split ',')[0] -replace "^OU=", ""
        $serviceFolder = Join-Path -Path $departementFolder -ChildPath $serviceName

        # Vérifier si le dossier du service existe déjà
        if (!(Test-Path -Path $serviceFolder)) {
            New-Item -ItemType Directory -Path $serviceFolder
            Write-Host "Dossier créé pour le service : $serviceName dans $departementName"
        }

        # Configurer les permissions NTFS
        $acl = Get-Acl -Path $serviceFolder

        # Supprimer l'héritage et définir des permissions spécifiques
        $acl.SetAccessRuleProtection($true, $false)  # Désactiver l'héritage et supprimer les règles héritées

        # Ajouter une règle pour le groupe représentant le service (si nécessaire)
        try {
            $groupName = "Group_Service_$serviceName"  # Adaptez ce nom en fonction de votre convention
            $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
                $groupName, 
                "FullControl", 
                "ContainerInherit,ObjectInherit", 
                "None", 
                "Allow"
            )))
            Write-Host "Permissions configurées pour le groupe : $groupName"
        } catch {
            Write-Host "Aucun groupe trouvé pour le service : $serviceName"
        }

        # Ajouter une règle pour les administrateurs
        $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
            "Administrators", 
            "FullControl", 
            "ContainerInherit,ObjectInherit", 
            "None", 
            "Allow"
        )))

        # Appliquer les permissions au dossier
        Set-Acl -Path $serviceFolder -AclObject $acl
        Write-Host "Permissions appliquées au service : $serviceName"
    }
}

Write-Host "Création des dossiers services terminée."
