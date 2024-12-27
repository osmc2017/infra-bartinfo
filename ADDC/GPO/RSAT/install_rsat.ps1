# Script pour installer RSAT Active Directory
$rsatName = "Rsat.ActiveDirectory.DS-LDS.Tools"

# Vérifie si RSAT Active Directory est déjà installé
$rsat = Get-WindowsCapability -Online | Where-Object { $_.Name -eq $rsatName }

if ($rsat.State -ne "Installed") {
    Write-Host "Installation de RSAT Active Directory..."
    try {
        Add-WindowsCapability -Online -Name $rsatName
        $rsat = Get-WindowsCapability -Online | Where-Object { $_.Name -eq $rsatName }
        if ($rsat.State -eq "Installed") {
            Write-Host "RSAT Active Directory installé avec succès."
        } else {
            Write-Host "Erreur : RSAT Active Directory n'a pas pu être installé."
        }
    } catch {
        Write-Host "Erreur lors de l'installation : $_"
    }
} else {
    Write-Host "RSAT Active Directory est déjà installé."
}
