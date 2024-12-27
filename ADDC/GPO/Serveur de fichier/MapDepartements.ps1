# Fichier de log
$logFile = "C:\Logs\ScriptLog.txt"

# Créer un dossier pour les logs s'il n'existe pas
if (!(Test-Path -Path "C:\Logs")) {
    New-Item -ItemType Directory -Path "C:\Logs"
}

# Log de début
Add-Content -Path $logFile -Value "Début du script à $(Get-Date)"

# Variables
$baseDepartements = "\\ServeurDeFichiers\Departements"
$user = $env:USERNAME
Add-Content -Path $logFile -Value "Utilisateur connecté : $user"

# Charger le module AD
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Add-Content -Path $logFile -Value "Module Active Directory chargé avec succès."
} catch {
    Add-Content -Path $logFile -Value "Erreur lors du chargement du module AD : $_"
    exit
}

# Récupérer l'OU
try {
    $userOU = (Get-ADUser -Identity $user -Properties DistinguishedName).DistinguishedName
    Add-Content -Path $logFile -Value "OU de l'utilisateur : $userOU"
} catch {
    Add-Content -Path $logFile -Value "Erreur lors de la récupération de l'OU : $_"
    exit
}

# Extraire le département
try {
    $ouParts = $userOU -split ","
    $departement = ($ouParts | Where-Object { $_ -like "OU=*" })[1] -replace "^OU=", ""
    Add-Content -Path $logFile -Value "Département identifié : $departement"
} catch {
    Add-Content -Path $logFile -Value "Erreur lors de l'extraction du département."
    exit
}

# Mappage du lecteur
try {
    $departementPath = Join-Path $baseDepartements $departement
    if (Test-Path $departementPath) {
        New-PSDrive -Name "D" -PSProvider FileSystem -Root $departementPath -Persist
        Add-Content -Path $logFile -Value "Lecteur D: mappé vers $departementPath"
    } else {
        Add-Content -Path $logFile -Value "Erreur : Chemin département introuvable : $departementPath"
    }
} catch {
    Add-Content -Path $logFile -Value "Erreur lors du mappage du lecteur : $_"
}
