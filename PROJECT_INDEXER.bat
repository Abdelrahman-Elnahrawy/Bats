@echo off
setlocal enabledelayedexpansion

:: --- STEP 1: CHOOSE FILE TYPE ---
cls
echo ======================================================
echo          STEP 1: CHOOSE FILE TYPE
echo ======================================================
set /p fileExt="Enter extension (e.g., .ino) [Default .h]: "
if "%fileExt%"=="" set "fileExt=.h"
if "%fileExt:~0,1%" NEQ "." set "fileExt=.%fileExt%"

set "searchDir=%cd%"
set "outputName=indexer_report.txt"

:CONFIRMATION
set "outputFile=%searchDir%\%outputName%"
cls
echo ======================================================
echo         ADVANCED PROJECT INDEXER (V11)
echo ======================================================
echo SEARCH FOLDER : %searchDir%
echo FILE TYPE     : *%fileExt%
echo SORT ORDER    : Date (Section 1) ^| Name (Section 2)
echo ======================================================
echo.
set /p confirm="Is this correct? (Yes/No): "

:: --- NEW FEATURE: MULTI-POSSIBILITY INPUT HANDLER ---
set "isYes="
set "isNo="
if /i "%confirm%"=="Y" set isYes=1
if /i "%confirm%"=="YES" set isYes=1
if /i "%confirm%"=="N" set isNo=1
if /i "%confirm%"=="NO" set isNo=1

if defined isNo goto MANUAL_INPUT
if not defined isYes goto CONFIRMATION
goto START_PROCESS

:MANUAL_INPUT
echo.
echo [CHANGE SETTINGS]
set /p searchDir="Enter Full Path: "
set /p outputName="Enter Output Filename: "
if "%outputName:~-4%" NEQ ".txt" set "outputName=%outputName%.txt"
goto CONFIRMATION

:START_PROCESS
echo.
echo Indexing projects... please wait...

echo ==================================================================================== > "%outputFile%"
echo ARDUINO PROJECT ARCHIVE REPORT - %date% >> "%outputFile%"
echo ==================================================================================== >> "%outputFile%"

set "tempDate=%temp%\p_date.tmp"
set "tempName=%temp%\p_name.tmp"
if exist "%tempDate%" del "%tempDate%"
if exist "%tempName%" del "%tempName%"

pushd "%searchDir%" 2>nul
for /r %%i in (*%fileExt%) do (
    for /f "tokens=1-3" %%a in ('dir "%%i" ^| findstr /i "%%~nxi"') do (
        set "fDate=%%a"
        set "fTime=%%b %%c"
        set "fName=%%~nxi"
        
        :: Convert MM/DD/YYYY to YYYYMMDD for perfect chronological sorting
        for /f "tokens=1-3 delims=/-" %%u in ("%%a") do (
            set "sortDate=%%w%%u%%v"
        )
        
        echo !sortDate!_%%b_%%c_%%a^|!fName! >> "%tempDate%"
        echo !fName!^|%%a_%%b_%%c >> "%tempName%"
    )
)
popd

:: --- SECTION 1: DATE SORT ---
echo. >> "%outputFile%"
echo [ SECTION 1: SORTED BY DATE (NEWEST FIRST) ] >> "%outputFile%"
echo ------------------------------------------------------------------------------------ >> "%outputFile%"
echo Filename                                          Modified Date         Time >> "%outputFile%"
echo ------------------------------------------------------------------------------------ >> "%outputFile%"

for /f "tokens=1,2 delims=|" %%A in ('sort /r "%tempDate%"') do (
    set "metadata=%%A"
    set "nVal=%%B"
    for /f "tokens=1-4 delims=_" %%u in ("!metadata!") do (
        set "dShow=%%x"
        set "tShow=%%v %%w"
    )
    set "nameLine=!nVal!                                                  "
    echo !nameLine:~0,50! !dShow!            !tShow! >> "%outputFile%"
)

echo. >> "%outputFile%"
echo. >> "%outputFile%"

:: --- SECTION 2: NAME SORT ---
echo [ SECTION 2: SORTED BY NAME (A-Z) ] >> "%outputFile%"
echo ------------------------------------------------------------------------------------ >> "%outputFile%"
echo Filename                                          Modified Date         Time >> "%outputFile%"
echo ------------------------------------------------------------------------------------ >> "%outputFile%"

for /f "tokens=1,2 delims=|" %%A in ('sort "%tempName%"') do (
    set "nVal=%%A"
    set "metadata=%%B"
    for /f "tokens=1,2,3 delims=_" %%u in ("!metadata!") do (
        set "dVal=%%u"
        set "tVal=%%v %%w"
    )
    set "nameLine=!nVal!                                                  "
    echo !nameLine:~0,50! !dVal!            !tVal! >> "%outputFile%"
)

:: Clean up
if exist "%tempDate%" del "%tempDate%"
if exist "%tempName%" del "%tempName%"

:: --- NEW FEATURE: FINAL INTERACTIVE STEP ---
echo.
echo Process Complete. Report saved to: 
echo %outputFile%
echo.
echo ======================================================
echo   PRESS ANY KEY TO OPEN THE REPORT...
echo ======================================================
pause >nul
start "" "%outputFile%"
exit