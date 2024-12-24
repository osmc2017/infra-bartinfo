# Script de création d'utilisateurs dans Active Directory

# Importer le module Active Directory
Import-Module ActiveDirectory

# Chemin vers votre fichier CSV contenant les informations des utilisateurs
$csvPath = "C:\Users\Administrator\Desktop\Phargreen.csv"

# Vérifier si le fichier CSV existe
if (-Not (Test-Path $csvPath)) {
    Write-Error "Le fichier CSV n'existe pas à l'emplacement spécifié : $csvPath"
    exit
}

# Importer les données du fichier CSV
$data = Import-Csv -Path $csvPath

# Mot de passe par défaut pour tous les utilisateurs
$defaultPassword = ConvertTo-SecureString "Azerty1*" -AsPlainText -Force

# Fonction pour nettoyer les noms et supprimer les caractères spéciaux sauf espaces
function CleanName {
    param ([string]$name)
    return $name -replace "[^a-zA-Z0-9 ]", ""
}

# Parcourir chaque ligne du fichier CSV pour créer les utilisateurs
foreach ($user in $data) {
    # Récupérer les informations utilisateur depuis le CSV
    $firstName = $user.Prénom
    $lastName = $user.Nom
    $department = $user.Département
    $service = $user.Service
    $telephoneFixe = $user."Téléphone fixe"
    $telephonePortable = $user."Téléphone portable"

    # Nettoyer les noms pour le SamAccountName et les DN
    $cleanFirstName = CleanName $firstName
    $cleanLastName = CleanName $lastName
    $samAccountName = "$($cleanFirstName.Substring(0,1).ToLower())$($cleanLastName.ToLower())"
    $cleanDepartment = CleanName $department
    $cleanService = if (-Not [string]::IsNullOrWhiteSpace($service) -and $service -ne "-") { CleanName $service } else { "" }

    # Construire le Distinguished Name (DN) pour placer l'utilisateur dans la bonne OU
    if (-Not [string]::IsNullOrWhiteSpace($cleanService)) {
        $ouPath = "OU=$cleanService,OU=$cleanDepartment,OU=Departements,DC=demo,DC=lan"
    } else {
        $ouPath = "OU=$cleanDepartment,OU=Departements,DC=demo,DC=lan"
    }

    # Vérifier si l'OU existe
    if (-Not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $ouPath } -ErrorAction SilentlyContinue)) {
        Write-Warning "L'OU spécifiée '$ouPath' n'existe pas. L'utilisateur '$firstName $lastName' sera ignoré."
        continue
    }

    # Vérifier si l'utilisateur existe déjà
    if (Get-ADUser -Filter { SamAccountName -eq $samAccountName } -ErrorAction SilentlyContinue) {
        Write-Warning "L'utilisateur avec SamAccountName '$samAccountName' existe déjà."
        continue
    }

    try {
        # Créer l'utilisateur dans Active Directory
        New-ADUser -Name "$firstName $lastName" `
                   -GivenName $firstName `
                   -Surname $lastName `
                   -SamAccountName $samAccountName `
                   -UserPrincipalName "$samAccountName@demo.lan" `
                   -Path $ouPath `
                   -OfficePhone $telephoneFixe `
                   -MobilePhone $telephonePortable `
                   -AccountPassword $defaultPassword `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true

        Write-Host "Utilisateur '$firstName $lastName' créé avec succès dans '$ouPath'."
    } catch {
        Write-Error "Erreur lors de la création de l'utilisateur '$firstName $lastName'. Détails : $_"
    }
}
