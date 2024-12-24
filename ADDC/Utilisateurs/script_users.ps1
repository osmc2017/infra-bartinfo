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

# Parcourir chaque ligne du fichier CSV pour créer les utilisateurs
foreach ($user in $data) {
    # Récupérer les informations utilisateur depuis le CSV
    $firstName = $user.Prénom
    $lastName = $user.Nom
    $department = $user.Département
    $service = $user.Service
    $telephoneFixe = $user."Téléphone fixe"
    $telephonePortable = $user."Téléphone portable"

    # Construire le SamAccountName unique
    $normalizedFirstName = $firstName -replace "[^a-zA-Z0-9- ]", ""
    $normalizedLastName = $lastName -replace "[^a-zA-Z0-9- ]", ""
    $samAccountName = "$($normalizedFirstName.Substring(0,1).ToLower())$($normalizedLastName.ToLower().Replace(' ', '').Replace('-', ''))"

    # Assurer l'unicité du SamAccountName
    $uniqueSamAccountName = $samAccountName
    $counter = 1
    while (Get-ADUser -Filter { SamAccountName -eq $uniqueSamAccountName } -ErrorAction SilentlyContinue) {
        $uniqueSamAccountName = "$samAccountName$counter"
        $counter++
    }

    # Construire le Distinguished Name (DN) pour placer l'utilisateur dans la bonne OU
    if (-Not [string]::IsNullOrWhiteSpace($service) -and $service -ne "-") {
        $ouPath = "OU=$service,OU=$department,OU=Departements,DC=demo,DC=lan"
    } else {
        $ouPath = "OU=$department,OU=Departements,DC=demo,DC=lan"
    }

    # Vérifier si l'OU existe
    if (-Not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $ouPath } -ErrorAction SilentlyContinue)) {
        Write-Warning "L'OU spécifiée '$ouPath' n'existe pas. L'utilisateur '$firstName $lastName' sera ignoré."
        continue
    }

    try {
        # Créer l'utilisateur dans Active Directory
        New-ADUser -Name "$firstName $lastName" `
                   -GivenName $firstName `
                   -Surname $lastName `
                   -SamAccountName $uniqueSamAccountName `
                   -UserPrincipalName "$uniqueSamAccountName@demo.lan" `
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
