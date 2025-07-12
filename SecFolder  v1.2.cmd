@echo off
title Project of Anees Sarwar
color 0A
setlocal EnableDelayedExpansion

:: === CONFIGURATION ===
set "folder=Private"
set "locked=Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}"
set "aboutFile=%folder%\About.txt"
set "baseKeyDir=%USERPROFILE%\LockerKeys"

:: Ensure password directory exists
if not exist "%baseKeyDir%" mkdir "%baseKeyDir%"

:: Sanitize path for unique filename
set "rawPath=%cd%"
set "safePath=%rawPath:\=_%"
set "safePath=%safePath::=_%"
set "safePath=%safePath: =_%"
set "passfile=%baseKeyDir%\%safePath%.dat"

:: === CHECK IF UNLOCK NEEDED ===
if exist "%locked%" goto :UNLOCK

:: === CREATE FOLDER + ABOUT FILE IF FIRST TIME ===
if not exist "%folder%" (
    md "%folder%"
    >"%aboutFile%" (
        echo. 
        echo ==================================================
        echo 🔐          SMART FOLDER LOCKER TOOL           🔐
        echo ==================================================
        echo 👨‍💻  Developer : Anees-Sarwar on Github
        echo 🛠️  Version   : 1.2
        echo 📅  Created   : %DATE%  %TIME%
        echo --------------------------------------------------
        echo.
        echo 💡 How it works^:
        echo    ✅ On first run, creates a secure folder
        echo    ✅ Asks you to set a password
        echo    ✅ Use your password anytime to unlock
        echo.
        echo 🚀 Features^:
        echo    ⚡ Lightweight  ^|  📦 Portable     ^|  ⚙️ Fast
        echo    🔒 Secure       ^|  🧰 Easy to use  ^|  📁 Multi-folder support
        echo.
        echo 📝 Tip^:
        echo    Secret Commands: Type "reset" or "admin"
        echo    instead of your current password.
        echo ==================================================
    )
    goto :SETPASS
)

:: === SET PASSWORD IF NOT FOUND ===
if not exist "%passfile%" goto :SETPASS

goto :LOCK

:SETPASS
echo ------------------------------------------
echo         PASSWORD SETUP REQUIRED
echo ------------------------------------------
set /p "newpass=Set a password: "
>"%passfile%" echo(!newpass!
attrib +h +s "%passfile%"
goto :LOCK

:LOCK
ren "%folder%" "%locked%"
attrib +h +s "%locked%"
goto :END

:UNLOCK
if not exist "%passfile%" goto :SETPASS

:PasswordPrompt
echo ------------------------------------------
echo            PASSWORD REQUIRED
echo ------------------------------------------
for /f %%P in ('powershell -Command "[System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR((Read-Host -AsSecureString 'Enter password')))"') do set "pass=%%P"
set /p "stored="<"%passfile%"

if /i "!pass!"=="reset" goto :CHANGEPASS
if /i "!pass!"=="admin" goto :PASSWORDS

if "!pass!"=="!stored!" (
    attrib -h -s "%locked%"
    ren "%locked%" "%folder%"

    :: Open folder
    start "" "%folder%"

    :: Auto-hide after opening
    timeout /t 1 >nul
    ren "%folder%" "%locked%"
    attrib +h +s "%locked%"

    goto :END
) else (
    powershell -Command "& {Write-Host 'Incorrect password. Try again.' -ForegroundColor Red}"
    timeout /t 1 >nul
    cls
    goto :PasswordPrompt
)

:CHANGEPASS
cls
echo ------------------------------------------
echo             CHANGE PASSWORD
echo ------------------------------------------
set /p "oldpass=Current password: "
set /p "stored="<"%passfile%"

if not "!oldpass!"=="!stored!" (
    powershell -Command "& {Write-Host 'Wrong current password.' -ForegroundColor Red}"
    timeout /t 1 >nul
    cls
    goto :PasswordPrompt
)

set /p "newpass=Enter new password: "
attrib -h -s -r "%passfile%" >nul 2>&1
>"%passfile%" echo(!newpass!
attrib +h +s "%passfile%"
powershell -Command "& {Write-Host 'Password changed successfully.' -ForegroundColor Yellow}"
timeout /t 2 >nul
cls
goto :PasswordPrompt

:PASSWORDS
cls
echo ------------------------------------------
echo              SAVED PASSWORDS
echo ------------------------------------------
set "found=0"
for /f "delims=" %%F in ('dir /b /a "%baseKeyDir%\*.dat" 2^>nul') do (
    set "found=1"
    set "filePath=%baseKeyDir%\%%F"
    set /p passContent=<"!filePath!"
    echo File: %%~nF
    echo Password: !passContent!
    echo.
)
if "!found!"=="0" (
    echo No password files found in %baseKeyDir%
)
pause
cls
goto :PasswordPrompt

:END
endlocal
exit