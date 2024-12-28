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
    $UserDN = whoami /fqdn
    Add-Content -Path $LogFile -Value "Sortie brute de whoami /fqdn : $UserDN"

    # Vérifier si l'utilisateur est dans l'OU des départements
    if ($UserDN -like "*$RootOU*") {
        Add-Content -Path $LogFile -Value "Utilisateur trouvé dans l'OU des départements."

        # Extraire les informations sur le service et le département
        $DNParts = $UserDN -split ","
        Add-Content -Path $LogFile -Value "DNParts : $DNParts"

        if ($DNParts.Length -lt 3) {
            Add-Content -Path $LogFile -Value "Erreur : Structure inattendue du DN. DNParts : $DNParts"
            exit 1
        }

        # Extraire le service et le département
        $Service = $DNParts[1] -replace "^OU=", ""  # Service (deuxième partie du DN)
        $Departement = $DNParts[2] -replace "^OU=", ""  # Département (troisième partie du DN)

        # Construire le chemin réseau
        $NetworkPath = "$Server\$BasePath\$Departement\$Service"

        # Mapper le lecteur réseau
        net use Z: $NetworkPath /persistent:no
        Add-Content -Path $LogFile -Value "Lecteur mappé : $NetworkPath"
    } else {
        Add-Content -Path $LogFile -Value "Utilisateur en dehors de l'OU des départements."
        exit 1
    }
} catch {
    # Enregistrer tous les détails de l'erreur
    Add-Content -Path $LogFile -Value "Erreur capturée : $_"
    exit 1
}

Add-Content -Path $LogFile -Value "=== Fin du script : $(Get-Date) ==="
