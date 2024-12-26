# Import du module Active Directory
Import-Module ActiveDirectory

# Schémas de nom des groupes à supprimer
$groupPatterns = @(
    "G_Departement_*",
    "G_Service_*"
)

foreach ($pattern in $groupPatterns) {
    # Récupérer les groupes correspondant au motif
    $groups = Get-ADGroup -Filter "Name -like '$pattern'"
    foreach ($group in $groups) {
        try {
            # Supprimer le groupe
            Remove-ADGroup -Identity $group.SamAccountName -Confirm:$false
            Write-Host "Groupe supprimé : $($group.Name)"
        } catch {
            Write-Host "Erreur lors de la suppression du groupe $($group.Name) : $($_.Exception.Message)"
        }
    }
}
