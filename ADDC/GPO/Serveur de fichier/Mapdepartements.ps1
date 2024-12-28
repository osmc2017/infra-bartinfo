# Fichier de log
$LogFile = "C:\MapDriveLog_Department_Debug.txt"
Add-Content -Path $LogFile -Value "Début du script - $(Get-Date)"

# Variables
$Server = "\\SRV_FICHIER"
$BasePath = "Partage\Departements"

# Obtenir l'utilisateur connecté
try {
    $User = $env:USERNAME
    $Domain = $env:USERDOMAIN
    Add-Content -Path $LogFile -Value "Utilisateur connecté : $Domain\$User"
} catch {
    Add-Content -Path $LogFile -Value "Erreur lors de la récupération de l'utilisateur connecté : $_"
    exit 1
}

# Déduire le département de l'utilisateur
try {
    $Department = $env:USERDNSDOMAIN -split "\." | Select-Object -First 1
    Add-Content -Path $LogFile -Value "Département détecté : $Department"
} catch {
    Add-Content -Path $LogFile -Value "Erreur lors de la détection du département : $_"
    exit 1
}

# Construire le chemin réseau
$NetworkPath = "$Server\$BasePath\$Department"

# Vérification de l'accessibilité du chemin
try {
    if (Test-Path -Path $NetworkPath) {
        Add-Content -Path $LogFile -Value "Le chemin réseau est accessible : $NetworkPath"
    } else {
        Add-Content -Path $LogFile -Value "Erreur : Le chemin réseau est inaccessible : $NetworkPath"
        exit 1
    }
} catch {
    Add-Content -Path $LogFile -Value "Erreur lors de la vérification du chemin réseau : $_"
    exit 1
}

# Mapper le lecteur réseau
try {
    Add-Content -Path $LogFile -Value "Tentative de mapping du lecteur réseau : $NetworkPath"
    New-PSDrive -Name "Z" -PSProvider FileSystem -Root $NetworkPath -Persist
    Add-Content -Path $LogFile -Value "Lecteur réseau mappé avec succès : $NetworkPath"
} catch {
    Add-Content -Path $LogFile -Value "Erreur lors du mapping du lecteur réseau : $_"
    exit 1
}

Add-Content -Path $LogFile -Value "Fin du script - $(Get-Date)"
