# Variables générales pour les partages réseau
$baseDepartements = "\\SRV_FICHIER\Departements"

# Récupérer l'utilisateur connecté
$user = $env:USERNAME

# Ajouter un log pour vérifier chaque étape
$logFile = "C:\Logs\ScriptLog.txt"
if (!(Test-Path -Path "C:\Logs")) {
    New-Item -ItemType Directory -Path "C:\Logs"
}
Add-Content -Path $logFile -Value "Début du script pour $user à $(Get-Date)"

# Charger le module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Add-Content -Path $logFile -Value "Module ActiveDirectory chargé avec succès."
} catch {
    Add-Content -Path $logFile -Value "Erreur : Impossible de charger le module ActiveDirectory. $_"
    exit
}

# Récupérer l'OU complet de l'utilisateur
try {
    $userOU = (Get-ADUser -Identity $user -Properties DistinguishedName).DistinguishedName
    Add-Content -Path $logFile -Value "Utilisateur connecté : $user, OU : $userOU"
} catch {
    Add-Content -Path $logFile -Value "Erreur : Impossible de récupérer l'OU pour l'utilisateur $user. $_"
    exit
}

# Extraire le département (OU parent direct)
try {
    $ouParts = $userOU -split ","
    $departement = ($ouParts | Where-Object { $_ -like "OU=*" })[1] -replace "^OU=", ""
    Add-Content -Path $logFile -Value "Département identifié : $departement"
} catch {
    Add-Content -Path $logFile -Value "Erreur : Impossible d'extraire le département pour $user."
    exit
}

# Fonction pour mapper un lecteur réseau
function Map_Drive {
    param (
        [string]$DriveLetter,
        [string]$Path
    )
    # Vérifie si le lecteur est déjà mappé
    if (!(Get-PSDrive -Name $DriveLetter -ErrorAction SilentlyContinue)) {
        try {
            New-PSDrive -Name $DriveLetter -PSProvider FileSystem -Root $Path -Persist
            Add-Content -Path $logFile -Value "Lecteur $DriveLetter mappé vers $Path"
        } catch {
            Add-Content -Path $logFile -Value "Erreur : Impossible de mapper le lecteur $DriveLetter vers $Path. $_"
        }
    } else {
        Add-Content -Path $logFile -Value "Lecteur $DriveLetter déjà mappé."
    }
}

# Mapper le lecteur départemental
if ($departement) {
    try {
        $departementPath = Join-Path $baseDepartements $departement
        Map-Drive -DriveLetter "D" -Path $departementPath
    } catch {
        Add-Content -Path $logFile -Value "Erreur lors du mappage pour le département : $departement"
    }
} else {
    Add-Content -Path $logFile -Value "Aucun département trouvé pour l'utilisateur : $user"
}

# Fin du script
Add-Content -Path $logFile -Value "Fin du script à $(Get-Date)"
