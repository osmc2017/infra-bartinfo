# Fichier de log
$LogFile = "$env:USERPROFILE\MapDriveLog.txt"
try {
    # Initialiser le fichier log
    Set-Content -Path $LogFile -Value "=== Début du script - $(Get-Date) ==="
} catch {
    Write-Host "Erreur : Impossible de créer ou écrire dans le fichier log à $LogFile : $_"
    exit 1
}

# Variables principales
$Server = "\\SRV_FICHIER"
$BasePath = "Partage\Departements"

# Étape 1 : Obtenir l'utilisateur connecté
try {
    $User = $env:USERNAME
    Add-Content -Path $LogFile -Value "Utilisateur détecté : $User"
} catch {
    Add-Content -Path $LogFile -Value "Erreur : Impossible de récupérer l'utilisateur connecté : $_"
    exit 1
}

# Étape 2 : Déduire le département de l'utilisateur depuis son OU
try {
    # Obtenir le DN complet de l'utilisateur via WMI
    $UserDN = (Get-WmiObject -Query "SELECT DistinguishedName FROM Win32_ComputerSystem").DistinguishedName
    if (-not $UserDN) {
        throw "Impossible de récupérer le Distinguished Name de l'utilisateur."
    }

    # Extraire le département depuis le DN
    $Department = ($UserDN -split ",OU=")[1] -split "," | Select-Object -First 1
    Add-Content -Path $LogFile -Value "Département détecté : $Department"
} catch {
    Add-Content -Path $LogFile -Value "Erreur : Impossible de déduire le département depuis l'OU : $_"
    exit 1
}

# Étape 3 : Construire le chemin réseau pour le département
try {
    $NetworkPath = "$Server\$BasePath\$Department"
    Add-Content -Path $LogFile -Value "Chemin réseau construit : $NetworkPath"
} catch {
    Add-Content -Path $LogFile -Value "Erreur : Impossible de construire le chemin réseau : $_"
    exit 1
}

# Étape 4 : Vérifier l'accès au chemin réseau
try {
    if (Test-Path -Path $NetworkPath) {
        Add-Content -Path $LogFile -Value "Le chemin réseau est accessible : $NetworkPath"
    } else {
        Add-Content -Path $LogFile -Value "Erreur : Chemin réseau inaccessible : $NetworkPath"
        exit 1
    }
} catch {
    Add-Content -Path $LogFile -Value "Erreur lors de la vérification du chemin réseau : $_"
    exit 1
}

# Étape 5 : Mapper le lecteur réseau
try {
    Add-Content -Path $LogFile -Value "Tentative de mapping du lecteur réseau : $NetworkPath"
    net use Z: $NetworkPath /persistent:no | Out-Null
    Add-Content -Path $LogFile -Value "Lecteur réseau mappé avec succès : $NetworkPath"
} catch {
    Add-Content -Path $LogFile -Value "Erreur : Impossible de mapper le lecteur réseau : $_"
    exit 1
}

# Fin du script
Add-Content -Path $LogFile -Value "=== Fin du script - $(Get-Date) ==="
