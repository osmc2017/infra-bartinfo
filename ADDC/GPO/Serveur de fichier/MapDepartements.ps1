# Variables générales pour les partages réseau
$baseDepartements = "\\SRV_FICHIER\Departements"

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

# Extraire le département (OU parent direct)
$ouParts = $userOU -split ","
$departement = ($ouParts | Where-Object { $_ -like "OU=*" })[1] -replace "^OU=", ""

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

# Mapper le lecteur départemental
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
