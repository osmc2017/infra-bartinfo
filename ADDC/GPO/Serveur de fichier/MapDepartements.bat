@echo off
set LOGFILE=C:\MapDriveLog.txt
echo Début du script de mapping des lecteurs réseau >> %LOGFILE%

:: Serveur et chemin de base
set "Server=\\SRV_FICHIER"
set "BasePath=Partage\Departements"

:: Obtenir le nom de l'utilisateur connecté
for /f "tokens=2 delims==" %%i in ('whoami /upn') do set "User=%%i"

:: Extraire le département (remplacez cette logique selon vos besoins)
for /f "tokens=2 delims=@" %%i in ("%User%") do set "Department=%%i"
echo Utilisateur : %User%, Département : %Department% >> %LOGFILE%

:: Mapper le lecteur réseau pour le département
echo Tentative de mapping du lecteur réseau : %Server%\%BasePath%\%Department% >> %LOGFILE%
net use Z: %Server%\%BasePath%\%Department% /persistent:no >> %LOGFILE% 2>&1

if errorlevel 1 (
    echo Échec du mapping du lecteur réseau pour %Department%. >> %LOGFILE%
) else (
    echo Lecteur réseau mappé avec succès pour %Department%. >> %LOGFILE%
)
