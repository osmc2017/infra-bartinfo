# Script de création d'utilisateurs dans Active Directory

# Importer les données
$CSVFile = "C:\Users\Administrator\Desktop\bartinfo.csv"
$CSVData = Import-CSV -Path $CSVFile -Delimiter ","

# Boucle pour parcourir les lignes CSV
Foreach($Utilisateur in $CSVData) {
    # Création de variable pour remplir les champs lors de la création des utilisateurs
    $UtilisateurPrenom = $Utilisateur.Prénom
    $UtilisateurNom = $Utilisateur.Nom
    $UtilisateurLogin = $UtilisateurNom.Replace(" ", ".").ToLower() + "." + ($UtilisateurPrenom).Substring(0,1).Replace(" ", ".").ToLower()
    $UtilisateurEmail = "$UtilisateurLogin@bartinfo.com"
    $UtilisateurMotDePasse = "Azerty1*"
    $UtilisateurFonction = $Utilisateur.Fonction
    $UtilisateurDepartement = $Utilisateur.Département
    $UtilisateurService = $Utilisateur.Service

    # Construire le chemin de l'OU basé sur le département et le service
    if (-Not [string]::IsNullOrWhiteSpace($UtilisateurService) -and $UtilisateurService -ne "-") {
        $OUPath = "OU=$UtilisateurService,OU=$UtilisateurDepartement,OU=Departements,DC=bartinfo,DC=com"
    } else {
        $OUPath = "OU=$UtilisateurDepartement,OU=Departements,DC=bartinfo,DC=com"
    }

    # Vérifier si l'OU existe
    if (-Not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $OUPath } -ErrorAction SilentlyContinue)) {
        Write-Warning "L'OU spécifiée '$OUPath' n'existe pas. L'utilisateur '$UtilisateurNom $UtilisateurPrenom' sera ignoré."
        continue
    }

    # Vérification si l'utilisateur a déjà été créé
    if (Get-ADUser -Filter { SamAccountName -eq $UtilisateurLogin }) {
        Write-Warning "L'identifiant $UtilisateurLogin existe déjà dans l'AD"
    } else {
        # Création de chaque utilisateur avec les variables
        try {
            New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                       -DisplayName "$UtilisateurNom $UtilisateurPrenom" `
                       -GivenName "$UtilisateurPrenom" `
                       -Surname $UtilisateurNom `
                       -SamAccountName $UtilisateurLogin `
                       -UserPrincipalName "$UtilisateurLogin@bartinfo.com" `
                       -EmailAddress $UtilisateurEmail `
                       -Title $UtilisateurFonction `
                       -Path $OUPath `
                       -AccountPassword (ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
                       -ChangePasswordAtLogon $true `
                       -Enabled $true

            Write-Host "Utilisateur '$UtilisateurNom $UtilisateurPrenom' créé avec succès dans '$OUPath'."
        } catch {
            Write-Error "Erreur lors de la création de l'utilisateur '$UtilisateurNom $UtilisateurPrenom'. Détails : $_"
        }
    }
}
