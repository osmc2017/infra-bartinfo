# Variables générales pour les partages réseau
$baseUtilisateurs = "\\ServeurDeFichiers\Utilisateurs"
$baseDepartements = "\\ServeurDeFichiers\Departements"
$baseServices = "\\ServeurDeFichiers\Services"

# Récupérer l'utilisateur connecté
$user = $env:USERNAME

# Charger le module Active Directory
Import-Module ActiveDirectory -ErrorAction Stop

# Récupérer l'OU complet de l'utilisateur
try {
    $userOU = (Get-ADUser -Identity $user -Properties DistinguishedName).DistinguishedName
    Write-Host "Utilisateur connecté : $user, OU : $userOU"
} catch {
    Write-Host "Erreur lors de la récupération de l'OU pour l'utilisateur : $user"
    exit
}

# Extraire le département (OU parent direct) et le service (sous-OU)
$ouParts = $userOU -split ","
$departement = ($ouParts | Where-Object { $_ -like "OU=*" })[1] -replace "^OU=", ""
$service = ($ouParts | Where-Object { $_ -like "OU=*" })[0] -replace "^OU=", ""

# Fonction pour mapper un lecteur réseau
function Map-Drive {
    param (
        [string]$DriveLetter,
        [string]$Path
    )
    # Vérifie si le lecteur est déjà mappé
    if (!(Get-PSDrive -Name $DriveLetter -ErrorAction SilentlyContinue)) {
        try {
            New-PSDrive -Name $DriveLetter -PSProvider FileSystem -Root $Path -Persist
            Write-Host "Lecteur $DriveLetter mappé vers $Path"
        } catch {
            Write-Host "Erreur lors du mappage du lecteur $DriveLetter vers $Path : $_"
        }
    } else {
        Write-Host "Lecteur $DriveLetter déjà mappé."
    }
}

# Mappage du dossier utilisateur personnel
try {
    $personalPath = Join-Path $baseUtilisateurs $user
    Map-Drive -DriveLetter "U" -Path $personalPath
} catch {
    Write-Host "Erreur lors du mappage du dossier personnel pour : $user"
}

# Mappage du dossier département
if ($departement) {
    try {
        $departementPath = Join-Path $baseDepartements $departement
        Map-Drive -DriveLetter "D" -Path $departementPath
    } catch {
        Write-Host "Erreur lors du mappage pour le département : $departement"
    }
} else {
    Write-Host "Aucun département trouvé pour l'utilisateur : $user"
}

# Mappage du dossier service
if ($service) {
    try {
        $servicePath = Join-Path $baseServices $service
        Map-Drive -DriveLetter "S" -Path $servicePath
    } catch {
        Write-Host "Erreur lors du mappage pour le service : $service"
    }
} else {
    Write-Host "Aucun service trouvé pour l'utilisateur : $user"
}
