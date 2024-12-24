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
    $samAccountName = "$($firstName.Substring(0,1).ToLower())$($lastName.ToLower())"
    $telephoneFixe = $user."Téléphone fixe"
    $telephonePortable = $user."Téléphone portable"

    # Construire le Distinguished Name (DN) pour placer l'utilisateur dans la bonne OU
    if (-Not [string]::IsNullOrWhiteSpace($service) -and $service -ne "-") {
        $ouPath = "OU=$service,OU=$department,OU=Departements,DC=demo,DC=lan"
    } else {
        $ouPath = "OU=$department,OU=Departements,DC=demo,DC=lan"
    }

    # Vérifier si l'utilisateur existe déjà
    if (Get-ADUser -Filter { SamAccountName -eq $samAccountName } -ErrorAction SilentlyContinue) {
        Write-Warning "L'utilisateur avec SamAccountName '$samAccountName' existe déjà."
        continue
    }

    try {
        # Créer l'utilisateur dans Active Directory
        New-ADUser -GivenName $firstName `
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
