# Initialisation
$LogFile = "$env:USERPROFILE\MapDriveLog_Services.txt"
Set-Content -Path $LogFile -Value "=== Début du script : $(Get-Date) ==="

# Serveur et chemin des services
$Server = "\\SRV_FICHIER"
$BasePath = "Partage\Services"

try {
    # Obtenir les groupes de l'utilisateur
    $UserGroups = (whoami /groups | Where-Object { $_ -match "G_Service" }) -join ", "

    if (-not $UserGroups) {
        Add-Content -Path $LogFile -Value "Aucun groupe service détecté."
        exit 1
    }

    # Mapper un lecteur pour chaque groupe service
    foreach ($Group in $UserGroups -split ", ") {
        $ServicePath = "$Server\$BasePath\$Group"
        net use J: $ServicePath /persistent:no
        Add-Content -Path $LogFile -Value "Lecteur mappé : $ServicePath"
    }

} catch {
    Add-Content -Path $LogFile -Value "Erreur : $_"
    exit 1
}

Add-Content -Path $LogFile -Value "=== Fin du script : $(Get-Date) ==="
