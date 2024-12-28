# Initialisation
$LogFile = "$env:USERPROFILE\MapDriveLog_Services.txt"
Set-Content -Path $LogFile -Value "=== Début du script : $(Get-Date) ==="

# Serveur et chemin des services
$Server = "\\SRV_FICHIER"
$BasePath = "Partage\Services"

# OU principal des départements
$RootOU = "OU=Departements,DC=bartinfo,DC=com"

try {
    # Récupérer le DN complet de l'utilisateur
    $UserDN = whoami /fqdn | ForEach-Object { ($_ -split ": ")[1] }
    Add-Content -Path $LogFile -Value "DN de l'utilisateur récupéré : $UserDN"

    # Vérifier si l'utilisateur est dans l'OU des départements
    if ($UserDN -like "*$RootOU*") {
        Add-Content -Path $LogFile -Value "Utilisateur trouvé dans l'OU des départements."

        # Extraire les informations sur le service et le département
        $DNParts = $UserDN -split ","
        $Service = $DNParts[0] -replace "^OU=", ""  # Service
        $Departement = $DNParts[1] -replace "^OU=", ""  # Département

        # Construire le chemin réseau
        $NetworkPath = "$Server\$BasePath\$Departement\$Service"

        # Mapper le lecteur réseau
        net use J: $NetworkPath /persistent:no
        Add-Content -Path $LogFile -Value "Lecteur mappé : $NetworkPath"
    } else {
        Add-Content -Path $LogFile -Value "Utilisateur en dehors de l'OU des départements."
        exit 1
    }
} catch {
    Add-Content -Path $LogFile -Value "Erreur : $_"
    exit 1
}

Add-Content -Path $LogFile -Value "=== Fin du script : $(Get-Date) ==="
