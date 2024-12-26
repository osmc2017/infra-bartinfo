# Variables générales pour le partage réseau
$baseUtilisateurs = "\\SRV_FICHIER\Utilisateurs"

# Récupérer l'utilisateur connecté
$user = $env:USERNAME

# Fonction pour mapper un lecteur réseau
function Map-Drive {
    param (
        [string]$DriveLetter,
        [string]$Path
    )
    # Vérifie si le lecteur est déjà mappé
    if (!(Get-PSDrive -Name $DriveLetter -ErrorAction SilentlyContinue)) {
        try {
            New-PSDrive -Name $DriveLetter -PSProvider FileSystem -Root $Path -Persist
            Write-Host "Lecteur $DriveLetter mappé vers $Path"
        } catch {
            Write-Host "Erreur lors du mappage du lecteur $DriveLetter vers $Path : $_"
        }
    } else {
        Write-Host "Lecteur $DriveLetter déjà mappé."
    }
}

# Construire le chemin du dossier utilisateur
$personalPath = Join-Path $baseUtilisateurs $user

# Mapper le lecteur utilisateur
Map-Drive -DriveLetter "I" -Path $personalPath
