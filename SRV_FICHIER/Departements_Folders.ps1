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

# Récupérer uniquement les OUs directement sous l'OU "Departements"
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

    # Ajouter une règle pour le groupe représentant le département (si nécessaire)
    try {
        $groupName = "Group_Departement_$departementName"  # Adaptez ce nom en fonction de votre convention
        $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
            $groupName, 
            "FullControl", 
            "ContainerInherit,ObjectInherit", 
            "None", 
            "Allow"
        )))
        Write-Host "Permissions configurées pour le groupe : $groupName"
    } catch {
        Write-Host "Aucun groupe trouvé pour le département : $departementName"
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
    Set-Acl -Path $departementFolder -AclObject $acl
    Write-Host "Permissions appliquées au département : $departementName"
}

Write-Host "Création des dossiers départements terminée."
