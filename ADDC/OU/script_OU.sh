# Importer le module Active Directory pour manipuler les objets dans l'AD
Import-Module ActiveDirectory

# Chemin vers votre fichier CSV contenant les départements et services => A adapter
$csvPath = "C:\Path\To\VotreFichier.csv"

# Vérifier si le fichier CSV existe
if (-Not (Test-Path $csvPath)) {
    Write-Error "Le fichier CSV n'existe pas à l'emplacement spécifié : $csvPath"
    exit
}

# Importer les données du fichier CSV
$data = Import-Csv -Path $csvPath

# Spécifier l'OU parent pour les départements => A adapter à votre infrastructure AD DS
$departmentsParentOU = "OU=Departments,DC=test,DC=lan"

# Fonction pour vérifier et créer une OU parent si elle n'existe pas
function CreateOU {
    param (
        [string]$ouDN,  # Chemin distingué de l'OU
        [string]$ouName,  # Nom de l'OU
        [string]$parentPath  # Chemin du conteneur parent
    )

    # Vérifier si l'OU existe déjà
    if (-Not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $ouDN } -ErrorAction SilentlyContinue)) {
        try {
            # Créer l'OU parent si elle n'existe pas
            New-ADOrganizationalUnit -Name $ouName -Path $parentPath -ErrorAction Stop
            Write-Host "L'OU '$ouName' créée avec succès."
        }
        catch {
            Write-Error "Erreur lors de la création de l'OU '$ouName'. Détails de l'erreur : $_"
        }
    } else {
        Write-Host "L'OU '$ouName' existe déjà."
    }
}

# Fonction pour désactiver la protection contre la suppression accidentelle sur une OU
function Remove-DeletionProtection {
    param ([string]$ouDN)  # Chemin distingué de l'OU

    try {
        # Désactiver la protection contre la suppression accidentelle
        Set-ADOrganizationalUnit -Identity $ouDN -ProtectedFromAccidentalDeletion $false
    }
    catch {
        Write-Warning "Impossible de supprimer la protection contre la suppression accidentelle pour l'OU '$ouDN'. Détails de l'erreur : $_"
    }
}

# Créer les OUs pour chaque département et leurs services
foreach ($row in $data) {
    $department = $row.Département
    $service = $row.Service

    # Vérifier que le nom du département n'est pas vide
    if ([string]::IsNullOrWhiteSpace($department)) {
        Write-Warning "Le département est vide, il sera ignoré."
        continue
    }

    # Construire le DN complet pour l'OU du département
    $departmentOUDN = "OU=$department,$departmentsParentOU"

    # Créer l'OU du département si elle n'existe pas
    CreateOU -ouDN $departmentOUDN -ouName $department -parentPath $departmentsParentOU

    # Supprimer la protection contre la suppression accidentelle pour l'OU du département
    Remove-DeletionProtection -ouDN $departmentOUDN

    # Si le service est renseigné, le créer sous l'OU du département
    if (-Not [string]::IsNullOrWhiteSpace($service)) {
        $serviceOUDN = "OU=$service,$departmentOUDN"

        # Créer l'OU du service si elle n'existe pas
        CreateOU -ouDN $serviceOUDN -ouName $service -parentPath $departmentOUDN

        # Supprimer la protection contre la suppression accidentelle pour l'OU du service
        Remove-DeletionProtection -ouDN $serviceOUDN
    }
}
