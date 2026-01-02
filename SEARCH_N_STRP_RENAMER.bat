@echo off
setlocal enabledelayedexpansion

:MENU
cls
echo ======================================================
echo       V12 "SEARCH ^& STRIP" RENAMER (ULTRA STABLE)
echo ======================================================
echo  1. Rename Files/Folders (Add Prefix/Suffix)
echo  2. Undo (Strip Prefix/Suffix from all names)
echo  3. Exit
echo ======================================================
set /p mainChoice="Choice [Default: 1]: "
if "%mainChoice%"=="" set "mainChoice=1"

if "%mainChoice%"=="1" goto RENAME_SETUP
if "%mainChoice%"=="2" goto UNDO_STRIP
if "%mainChoice%"=="3" exit
goto MENU

:RENAME_SETUP
cls
echo [ RENAME MODE ]
set /p targetDir="Enter Path [Enter for Current]: "
if "%targetDir%"=="" set "targetDir=%cd%"
set "targetDir=%targetDir:"=%"

:: Anchor to Drive
set "driveLetter=%targetDir:~0,2%"
%driveLetter% >nul 2>&1
cd /d "%targetDir%"

echo.
echo 1. Add Prefix (Before Name)
echo 2. Add Suffix (After Name, Before Extension)
set /p sideChoice="Choice [Default: 1]: "
if "%sideChoice%"=="" set "sideChoice=1"

set /p customText="Enter Text to add [Default: input_]: "
if "!customText!"=="" set "customText=input_"

set /p renFolders="Rename folders too? (Y/N) [Default: N]: "
set "doFolders=N"
for %%A in (Y y YES Yes yes) do if "%renFolders%"=="%%A" set "doFolders=Y"

echo.
echo Processing...
set /a count=0

:: Files
for /f "delims=" %%f in ('dir /s /b /a-d "%targetDir%\*" 2^>nul') do (
    if /i "%%~nxf" NEQ "%~nx0" (
        if "%sideChoice%"=="1" (set "newName=!customText!%%~nxf") else (set "newName=%%~nf!customText!%%~xf")
        ren "%%f" "!newName!" >nul 2>&1
        if !errorlevel! equ 0 set /a count+=1
    )
)

:: Folders
if /i "%doFolders%"=="Y" (
    for /f "delims=" %%d in ('dir /s /b /ad "%targetDir%" 2^>nul ^| sort /r') do (
        if "%sideChoice%"=="1" (set "newName=!customText!%%~nxd") else (set "newName=%%~nxd!customText!")
        ren "%%d" "!newName!" >nul 2>&1
        if !errorlevel! equ 0 set /a count+=1
    )
)

echo SUCCESS: !count! items renamed.
pause
goto MENU

:UNDO_STRIP
cls
echo [ UNDO MODE: SEARCH ^& STRIP ]
set /p undoDir="Target Folder [Enter for Current]: "
if "%undoDir%"=="" set "undoDir=%cd%"
set "undoDir=%undoDir:"=%"

:: Anchor to Drive
set "uDrive=%undoDir:~0,2%"
%uDrive% >nul 2>&1
cd /d "%undoDir%"

echo.
echo Enter the EXACT Prefix or Suffix you want to REMOVE.
set /p stripText="Text to remove (e.g., input_): "

if "!stripText!"=="" (echo Error: Text cannot be blank. && pause && goto MENU)

echo.
echo Stripping '!stripText!' from all files and folders...
set /a uCount=0

:: PASS 1: FILES (Deep Scan)
for /f "delims=" %%f in ('dir /s /b /a-d "%undoDir%\*%stripText%*" 2^>nul') do (
    set "oldName=%%~nxf"
    set "newName=!oldName:%stripText%=!"
    ren "%%f" "!newName!" >nul 2>&1
    if !errorlevel! equ 0 set /a uCount+=1
)

:: PASS 2: FOLDERS (Deep Scan - Reverse order to keep paths valid)
for /f "delims=" %%d in ('dir /s /b /ad "%undoDir%\*%stripText%*" 2^>nul ^| sort /r') do (
    set "oldFolderName=%%~nxd"
    set "newFolderName=!oldFolderName:%stripText%=!"
    ren "%%d" "!newFolderName!" >nul 2>&1
    if !errorlevel! equ 0 set /a uCount+=1
)

echo.
echo SUCCESS: Removed '!stripText!' from !uCount! items.
pause
goto MENU