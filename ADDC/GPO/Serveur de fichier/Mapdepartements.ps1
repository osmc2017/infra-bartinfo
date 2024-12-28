# Définir le fichier de log
$LogFile = "C:\MapDriveLog_Department.txt"
Add-Content -Path $LogFile -Value "Début du script de mapping des lecteurs réseau - $(Get-Date)"

# Variables
$Server = "\\SRV_FICHIER"
$BasePath = "Partage\Departements"

# Obtenir l'utilisateur connecté et son domaine
try {
    $User = $env:USERNAME
    $Domain = $env:USERDOMAIN
    Add-Content -Path $LogFile -Value "Utilisateur connecté : $Domain\$User"
} catch {
    Add-Content -Path $LogFile -Value "Erreur lors de la récupération des informations utilisateur : $_"
    exit 1
}

# Logique pour extraire le département de l'utilisateur
# Remplacez cette logique par celle qui convient à votre structure
try {
    $Department = $env:USERDNSDOMAIN -split "\." | Select-Object -First 1
    Add-Content -Path $LogFile -Value "Département détecté : $Department"
} catch {
    Add-Content -Path $LogFile -Value "Erreur lors de la détection du département : $_"
    exit 1
}

# Construire le chemin réseau
$NetworkPath = "$Server\$BasePath\$Department"

# Mapper le lecteur réseau
try {
    Add-Content -Path $LogFile -Value "Tentative de mapping du lecteur réseau : $NetworkPath"
    New-PSDrive -Name "K" -PSProvider FileSystem -Root $NetworkPath -Persist
    Add-Content -Path $LogFile -Value "Lecteur réseau mappé avec succès : $NetworkPath"
} catch {
    Add-Content -Path $LogFile -Value "Erreur lors du mapping du lecteur réseau : $_"
    exit 1
}

Add-Content -Path $LogFile -Value "Fin du script - $(Get-Date)"
