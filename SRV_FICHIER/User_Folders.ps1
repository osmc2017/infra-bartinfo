# Variables
$racinePartageUtilisateurs = "D:\Partage\Utilisateurs"  # Chemin de stockage des dossiers des utilisateurs
$domainUsersGroup = "Domain Users"  # Groupe contenant les utilisateurs (par défaut dans AD)

# Importer le module Active Directory
Import-Module ActiveDirectory

# Créer le dossier racine des utilisateurs s'il n'existe pas
if (!(Test-Path -Path $racinePartageUtilisateurs)) {
    New-Item -ItemType Directory -Path $racinePartageUtilisateurs
}

# Récupérer tous les utilisateurs du domaine
$utilisateurs = Get-ADUser -Filter * -SearchBase "OU=Departements,DC=bartinfo,DC=com" -Properties SamAccountName

foreach ($utilisateur in $utilisateurs) {
    $userFolder = Join-Path -Path $racinePartageUtilisateurs -ChildPath $utilisateur.SamAccountName
    
    # Vérifier si le dossier existe déjà
    if (!(Test-Path -Path $userFolder)) {
        New-Item -ItemType Directory -Path $userFolder
        Write-Host "Dossier créé pour l'utilisateur : $($utilisateur.SamAccountName)"
    }

    # Configurer les permissions NTFS
    $acl = Get-Acl -Path $userFolder
    $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$($utilisateur.SamAccountName)", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")))
    Set-Acl -Path $userFolder -AclObject $acl
    Write-Host "Permissions configurées pour l'utilisateur : $($utilisateur.SamAccountName)"
}

Write-Host "Création des dossiers utilisateurs terminée."