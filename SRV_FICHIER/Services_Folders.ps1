# Variables
$racinePartageDepartements = "C:\Partage\Departements"  # Chemin racine pour les départements
$ouServices = "OU=Services,OU=Departements,DC=bartinfo,DC=com"  # OU contenant les groupes des services

# Importer le module Active Directory
Import-Module ActiveDirectory

# Récupérer tous les groupes dans l'OU des services
$groupesServices = Get-ADGroup -Filter * -SearchBase $ouServices

foreach ($groupe in $groupesServices) {
    # Extraire le département parent à partir du nom du groupe ou d'un attribut personnalisé
    $departement = (Get-ADGroup -Identity $groupe.DistinguishedName -Properties ParentContainer).ParentContainer
    $departementFolder = Join-Path -Path $racinePartageDepartements -ChildPath $departement

    # Vérifier si le dossier du département existe
    if (!(Test-Path -Path $departementFolder)) {
        Write-Host "Le dossier pour le département $departement n'existe pas. Skipping..."
        continue
    }

    # Créer le dossier pour le service dans le dossier du département
    $serviceFolder = Join-Path -Path $departementFolder -ChildPath $groupe.SamAccountName

    if (!(Test-Path -Path $serviceFolder)) {
        New-Item -ItemType Directory -Path $serviceFolder
        Write-Host "Dossier créé pour le service : $($groupe.SamAccountName)"
    }

    # Configurer les permissions NTFS
    $acl = Get-Acl -Path $serviceFolder

    # Supprimer l'héritage et définir des permissions spécifiques
    $acl.SetAccessRuleProtection($true, $false)  # Désactiver l'héritage et supprimer les règles héritées

    # Ajouter une règle pour le groupe représentant le service
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
    Set-Acl -Path $serviceFolder -AclObject $acl
    Write-Host "Permissions configurées pour le service : $($groupe.SamAccountName)"
}

Write-Host "Création des dossiers services terminée."
