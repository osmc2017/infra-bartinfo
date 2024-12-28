# Fichier de log
$LogFile = "C:\MapDriveLog_Departments.txt"
Add-Content -Path $LogFile -Value "=== Début du script - $(Get-Date) ==="

# Variables principales
$Server = "\\SRV_FICHIER"
$BasePath = "Partage\Departements"

# Étape 1 : Obtenir les informations utilisateur
try {
    $User = $env:USERNAME
    $Domain = $env:USERDOMAIN
    Add-Content -Path $LogFile -Value "Utilisateur connecté : $Domain\$User"
} catch {
    Add-Content -Path $LogFile -Value "Erreur : Impossible de récupérer les informations utilisateur : $_"
    exit 1
}

# Étape 2 : Déduire le département de l'utilisateur à partir de l'OU
try {
    # Commande pour trouver le DistinguishedName de l'utilisateur
    $UserDN = (Get-WmiObject -Query "SELECT * FROM Win32_ComputerSystem").Domain
    $OUPath = $UserDN -replace "CN=.*?,", "" -replace "DC=.*", ""
    $Department = $OUPath -split "," | Select-Object -Last 1 -replace "OU=", ""
    Add-Content -Path $LogFile -Value "Département détecté : $Department"
} catch {
    Add-Content -Path $LogFile -Value "Erreur : Impossible de déduire le département de l'utilisateur : $_"
    exit 1
}

# Étape 3 : Construire le chemin réseau pour le département
$NetworkPath = "$Server\$BasePath\$Department"
try {
    Add-Content -Path $LogFile -Value "Chemin réseau construit : $NetworkPath"
} catch {
    Add-Content -Path $LogFile -Value "Erreur : Impossible de construire le chemin réseau : $_"
    exit 1
}

# Étape 4 : Vérifier l'accessibilité du chemin réseau
try {
    if (Test-Path -Path $NetworkPath) {
        Add-Content -Path $LogFile -Value "Le chemin réseau est accessible : $NetworkPath"
    } else {
        Add-Content -Path $LogFile -Value "Erreur : Le chemin réseau est inaccessible : $NetworkPath"
        exit 1
    }
} catch {
    Add-Content -Path $LogFile -Value "Erreur : Vérification de l'accessibilité échouée : $_"
    exit 1
}

# Étape 5 : Mapper le lecteur réseau
try {
    Add-Content -Path $LogFile -Value "Tentative de mapping du lecteur réseau : $NetworkPath"
    net use Z: $NetworkPath /persistent:no | Out-Null
    Add-Content -Path $LogFile -Value "Lecteur réseau mappé avec succès : $NetworkPath"
} catch {
    Add-Content -Path $LogFile -Value "Erreur : Mapping du lecteur réseau échoué : $_"
    exit 1
}

# Fin du script
Add-Content -Path $LogFile -Value "=== Fin du script - $(Get-Date) ==="
