# Importer le module Active Directory
Import-Module ActiveDirectory

# Chemin vers votre fichier CSV contenant les départements et services
$csvPath = "C:\Users\Administrator\Desktop\bartinfo.csv"

# Vérifier si le fichier CSV existe
if (-Not (Test-Path $csvPath)) {
    Write-Error "Le fichier CSV n'existe pas à l'emplacement spécifié : $csvPath"
    exit
}

# Importer les données du fichier CSV en filtrant uniquement les colonnes nécessaires
$data = Import-Csv -Path $csvPath | Select-Object Département, Service

# Spécifier l'OU parent pour les départements
$departmentsParentOU = "OU=Departements,DC=bartinfo,DC=com"

# Fonction pour vérifier et créer une OU si elle n'existe pas
function CreateOU {
    param (
        [string]$ouName,  # Nom de l'OU
        [string]$parentPath  # Chemin du conteneur parent
    )

    # Construire le chemin distingué (DN) complet
    $ouDN = "OU=$ouName,$parentPath"

    # Vérifier si l'OU existe déjà
    if (-Not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $ouDN } -ErrorAction SilentlyContinue)) {
        try {
            # Créer l'OU si elle n'existe pas
            New-ADOrganizationalUnit -Name $ouName -Path $parentPath -ErrorAction Stop
            Write-Host "L'OU '$ouName' créée avec succès dans '$parentPath'."
        }
        catch {
            Write-Error "Erreur lors de la création de l'OU '$ouName'. Détails de l'erreur : $_"
        }
    } else {
        Write-Host "L'OU '$ouName' existe déjà dans '$parentPath'."
    }

    return $ouDN
}

# Créer l'OU principale "Departements"
CreateOU -ouName "Departements" -parentPath "DC=bartinfo,DC=com"

# Grouper les données par département
$departmentServices = $data | Group-Object Département

# Parcourir chaque groupe de départements
foreach ($group in $departmentServices) {
    $department = $group.Name
    $services = $group.Group | Select-Object -ExpandProperty Service -Unique

    # Vérifier que le département n'est pas vide
    if ([string]::IsNullOrWhiteSpace($department)) {
        Write-Warning "Le département est vide, il sera ignoré."
        continue
    }

    # Créer l'OU pour le département
    $departmentOUDN = CreateOU -ouName $department -parentPath $departmentsParentOU

    # Parcourir les services et les créer sous le département
    foreach ($service in $services) {
        if (-Not [string]::IsNullOrWhiteSpace($service) -and $service -ne "-") {
            CreateOU -ouName $service -parentPath $departmentOUDN
        }
    }
}
