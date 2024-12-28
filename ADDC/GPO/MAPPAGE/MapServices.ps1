# Initialisation
$LogFile = "$env:USERPROFILE\MapDriveLog_Services.txt"
Set-Content -Path $LogFile -Value "=== Début du script : $(Get-Date) ==="

# Serveur et chemin des services
$Server = "\\SRV_FICHIER"
$BasePath = "Partage\Services"

# OU principal des départements
$RootOU = "OU=Departements,DC=bartinfo,DC=com"

try {
    # Récupérer l'utilisateur actuel
    $Username = $env:USERNAME
    $UserDN = (Get-ADUser -Identity $Username -Properties DistinguishedName).DistinguishedName

    # Vérifier si l'utilisateur appartient à une sous-OU d'un département
    if ($UserDN -like "*$RootOU*") {
        # Extraire les informations sur le département et le service
        $OUs = $UserDN -split ","
        $Service = $OUs[0] -replace "^OU=", ""
        $Departement = $OUs[1] -replace "^OU=", ""

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
    Add-Content -Path $LogFile -Value "Erreur : $_"
    exit 1
}

Add-Content -Path $LogFile -Value "=== Fin du script : $(Get-Date) ==="
