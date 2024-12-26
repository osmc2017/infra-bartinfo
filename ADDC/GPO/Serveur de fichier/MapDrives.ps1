# Variables générales pour les partages réseau
$baseUtilisateurs = "\\ServeurDeFichiers\Utilisateurs"
$baseDepartements = "\\ServeurDeFichiers\Departements"
$baseServices = "\\ServeurDeFichiers\Services"

# Récupérer l'utilisateur connecté
$user = $env:USERNAME

# Ajouter une ligne de log pour vérifier l'utilisateur
Write-Host "Utilisateur connecté : $user"

# Récupérer les groupes AD de l'utilisateur
Import-Module ActiveDirectory
$groups = (Get-ADUser -Identity $user -Properties MemberOf).MemberOf

# Ajouter une ligne pour vérifier les groupes de l'utilisateur
Write-Host "Groupes de l'utilisateur : $($groups -join ', ')"

# Fonction pour mapper un lecteur réseau
function Map-Drive ($DriveLetter, $Path) {
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

# Mappage du dossier personnel
$personalPath = Join-Path $baseUtilisateurs $user
Map-Drive -DriveLetter "U" -Path $personalPath

# Mappage pour le département
foreach ($group in $groups) {
    if ($group -like "*Departement*") {
        $departement = $group -replace "CN=Group_Departement_", "" -replace ",.*", ""
        $departementPath = Join-Path $baseDepartements $departement
        Map-Drive -DriveLetter "D" -Path $departementPath
    }
}

# Mappage pour le service
foreach ($group in $groups) {
    if ($group -like "*Service*") {
        $service = $group -replace "CN=Group_Service_", "" -replace ",.*", ""
        $servicePath = Join-Path $baseServices $service
        Map-Drive -DriveLetter "S" -Path $servicePath
    }
}
