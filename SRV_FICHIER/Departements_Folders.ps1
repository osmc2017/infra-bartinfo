# Variables
$racinePartageDepartements = "D:\Partage\Departements"  # Chemin racine pour les départements
$ouDepartements = "OU=Departements,DC=bartinfo,DC=com"  # OU contenant les départements

# Importer le module Active Directory
Import-Module ActiveDirectory

# Vérification et création du dossier racine
if (!(Test-Path -Path $racinePartageDepartements)) {
    New-Item -ItemType Directory -Path $racinePartageDepartements
    Write-Host "Dossier racine créé : $racinePartageDepartements"
}

# Récupérer uniquement les OUs directement sous "Departements"
$departements = Get-ADOrganizationalUnit -Filter * -SearchBase $ouDepartements | Where-Object {
    ($_.DistinguishedName -split ',').Count -eq ($ouDepartements -split ',').Count + 1
}

foreach ($departement in $departements) {
    $departementName = ($departement.DistinguishedName -split ',')[0] -replace "^OU=", ""
    $departementFolder = Join-Path -Path $racinePartageDepartements -ChildPath $departementName

    # Vérifier si le dossier existe déjà
    if (!(Test-Path -Path $departementFolder)) {
        New-Item -ItemType Directory -Path $departementFolder
        Write-Host "Dossier créé pour le département : $departementName"
    }

    # Configurer les permissions NTFS
    $acl = Get-Acl -Path $departementFolder

    # Supprimer l'héritage et définir des permissions spécifiques
    $acl.SetAccessRuleProtection($true, $false)  # Désactiver l'héritage et supprimer les règles héritées

    # Ajouter des permissions pour chaque utilisateur dans l'OU
    try {
        $users = Get-ADUser -Filter * -SearchBase $departement.DistinguishedName -Properties SamAccountName
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
        Write-Host "Erreur lors de la récupération ou de l'attribution des droits pour les utilisateurs de l'OU : $departementName"
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
        Set-Acl -Path $departementFolder -AclObject $acl
        Write-Host "Permissions appliquées au département : $departementName"
    } catch {
        Write-Host "Erreur lors de l'application des permissions pour : $departementFolder"
    }
}

Write-Host "Création des dossiers départements terminée."
