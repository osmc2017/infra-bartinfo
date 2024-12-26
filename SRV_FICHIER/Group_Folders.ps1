# Variables
$racinePartageGroupes = "D:\Partage\Groupes"  # Chemin de stockage des dossiers des groupes
$searchBase = "OU=departements,DC=bartinfo,DC=com"  # OU où se trouvent les groupes

# Importer le module Active Directory
Import-Module ActiveDirectory

# Créer le dossier racine des groupes s'il n'existe pas
if (!(Test-Path -Path $racinePartageGroupes)) { 
    New-Item -ItemType Directory -Path $racinePartageGroupes 
    Write-Host "Dossier racine créé : $racinePartageGroupes"
}

# Récupérer tous les groupes dans l'OU 'departements' et ses sous-OUs
$groupes = Get-ADGroup -Filter * -SearchBase $searchBase

# Parcours des groupes trouvés
foreach ($groupe in $groupes) {
    $groupFolder = Join-Path -Path $racinePartageGroupes -ChildPath $groupe.SamAccountName
    
    # Vérifier si le dossier existe déjà
    if (!(Test-Path -Path $groupFolder)) {
        New-Item -ItemType Directory -Path $groupFolder
        Write-Host "Dossier créé pour le groupe : $($groupe.SamAccountName)"
    }

    # Configurer les permissions NTFS
    $acl = Get-Acl -Path $groupFolder
    $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$($groupe.SamAccountName)", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")))
    Set-Acl -Path $groupFolder -AclObject $acl
    Write-Host "Permissions configurées pour le groupe : $($groupe.SamAccountName)"
}

Write-Host "Création des dossiers groupes terminée."
