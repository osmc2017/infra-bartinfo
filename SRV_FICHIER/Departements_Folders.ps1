# Variables
$racinePartageDepartements = "C:\Partage\Departements"  # Chemin racine pour les départements
$ouDepartements = "OU=Departements,DC=bartinfo,DC=com"  # OU contenant les groupes des départements

# Importer le module Active Directory
Import-Module ActiveDirectory

# Vérification et création du dossier racine
if (!(Test-Path -Path $racinePartageDepartements)) {
    New-Item -ItemType Directory -Path $racinePartageDepartements
    Write-Host "Dossier racine créé : $racinePartageDepartements"
}

# Récupérer tous les groupes dans l'OU des départements
$groupesDepartements = Get-ADGroup -Filter * -SearchBase $ouDepartements

foreach ($groupe in $groupesDepartements) {
    $departementFolder = Join-Path -Path $racinePartageDepartements -ChildPath $groupe.SamAccountName

    # Vérifier si le dossier existe déjà
    if (!(Test-Path -Path $departementFolder)) {
        New-Item -ItemType Directory -Path $departementFolder
        Write-Host "Dossier créé pour le département : $($groupe.SamAccountName)"
    }

    # Configurer les permissions NTFS
    $acl = Get-Acl -Path $departementFolder

    # Supprimer l'héritage et définir des permissions spécifiques
    $acl.SetAccessRuleProtection($true, $false)  # Désactiver l'héritage et supprimer les règles héritées

    # Ajouter une règle pour le groupe représentant le département
    $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
        "$($groupe.SamAccountName)", 
        "FullControl", 
        "ContainerInherit,ObjectInherit", 
        "None", 
        "Allow"
    )))

    # Ajouter une règle pour les administrateurs
    $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Administrators", 
        "FullControl", 
        "ContainerInherit,ObjectInherit", 
        "None", 
        "Allow"
    )))

    # Appliquer les permissions au dossier
    Set-Acl -Path $departementFolder -AclObject $acl
    Write-Host "Permissions configurées pour le département : $($groupe.SamAccountName)"
}

Write-Host "Création des dossiers départements terminée."
