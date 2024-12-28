# Log file location
$LogFile = "C:\MapDriveLog_User.txt"
Add-Content -Path $LogFile -Value "Début du script de mapping des lecteurs réseau - $(Get-Date)"

# Variables
$Server = "\\SRV_FICHIER"
$BasePath = "Partage\Departements"

# Obtenir le nom de l'utilisateur connecté
try {
    $User = $env:USERNAME
    Add-Content -Path $LogFile -Value "Utilisateur connecté : $User"
} catch {
    Add-Content -Path $LogFile -Value "Erreur lors de la récupération de l'utilisateur connecté : $_"
    exit 1
}

# Déduire le département de l'utilisateur (personnalisez cette logique si nécessaire)
try {
    Import-Module ActiveDirectory
    $UserOU = (Get-ADUser -Identity $User).DistinguishedName -split ',OU='
    $Department = $UserOU[1]  # Prend le département basé sur l'OU
    Add-Content -Path $LogFile -Value "Département détecté : $Department"
} catch {
    Add-Content -Path $LogFile -Value "Erreur lors de la détection du département : $_"
    exit 1
}

# Construire le chemin réseau pour le département
$NetworkPath = "$Server\$BasePath\$Department"

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
