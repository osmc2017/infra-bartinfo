# Variables
$racinePartageUtilisateurs = "D:\Partage\Utilisateurs"  # Chemin de stockage des dossiers des utilisateurs
$searchBase = "OU=Utilisateurs,DC=bartinfo,DC=com"  # Changez pour l'OU où se trouvent vos utilisateurs

# Importer le module Active Directory
Import-Module ActiveDirectory

# Vérification et création du dossier racine
if (!(Test-Path -Path $racinePartageUtilisateurs)) {
    New-Item -ItemType Directory -Path $racinePartageUtilisateurs
    Write-Host "Dossier racine créé : $racinePartageUtilisateurs"
}

# Récupérer tous les utilisateurs dans l'OU spécifiée
$utilisateurs = Get-ADUser -Filter * -SearchBase $searchBase -Properties SamAccountName

foreach ($utilisateur in $utilisateurs) {
    $userFolder = Join-Path -Path $racinePartageUtilisateurs -ChildPath $utilisateur.SamAccountName

    # Vérifier si le dossier existe déjà
    if (!(Test-Path -Path $userFolder)) {
        New-Item -ItemType Directory -Path $userFolder
        Write-Host "Dossier créé pour l'utilisateur : $($utilisateur.SamAccountName)"
    }

    # Configurer les permissions NTFS
    $acl = Get-Acl -Path $userFolder

    # Supprimer les permissions héritées si nécessaire
    $acl.SetAccessRuleProtection($true, $false)  # Désactiver l'héritage et supprimer les règles héritées

    # Ajouter une règle pour donner à l'utilisateur un contrôle total
    $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
        "$($utilisateur.SamAccountName)", 
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
    Set-Acl -Path $userFolder -AclObject $acl
    Write-Host "Permissions configurées pour l'utilisateur : $($utilisateur.SamAccountName)"
}

Write-Host "Création des dossiers utilisateurs et configuration des permissions terminée."
