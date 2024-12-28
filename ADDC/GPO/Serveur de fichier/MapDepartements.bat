@echo off

:: Variables
set "Server=\\SRV_FICHIER"
set "BasePath=Departements"

:: Obtenir l'utilisateur connecté
for /f "tokens=2 delims==" %%i in ('whoami /upn') do set "User=%%i"

:: Extraire le département à partir de l'UPN ou DN (remplacez selon votre logique)
for /f "tokens=2 delims=@" %%i in ("%User%") do set "Department=%%i"

:: Mapper le lecteur réseau
echo Mapping drive for department: %Department%
net use K: %Server%\%BasePath%\%Department% /persistent:no

if errorlevel 1 (
    echo Échec du mapping du lecteur réseau.
) else (
    echo Lecteur réseau mappé avec succès.
)
pause
