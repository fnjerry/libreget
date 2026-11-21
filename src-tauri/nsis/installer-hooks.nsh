!include "LogicLib.nsh"

!macro NSIS_HOOK_PREINSTALL
  ; Terminate running OmniGet processes so uninstaller can remove files without locks
  DetailPrint "Stopping running instances of OmniGet..."
  nsExec::Exec 'taskkill /F /IM "omniget.exe"'
  nsExec::Exec 'taskkill /F /IM "OmniGet.exe"'
  Sleep 1000

  ; 1. Check registry UninstallString (catches custom install locations)
  StrCpy $R0 ""
  ReadRegStr $R0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OmniGet" "UninstallString"
  ${If} $R0 == ""
    ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OmniGet" "UninstallString"
  ${EndIf}
  ${If} $R0 == ""
    ReadRegStr $R0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\com.openselena.omniget" "UninstallString"
  ${EndIf}
  ${If} $R0 == ""
    ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\com.openselena.omniget" "UninstallString"
  ${EndIf}

  ${If} $R0 != ""
    DetailPrint "Executing OmniGet uninstaller from registry..."
    ExecWait '$R0 /S'
    Sleep 1000
  ${EndIf}

  ; 2. Check standard Tauri per-user install directory ($LOCALAPPDATA\OmniGet)
  ${If} ${FileExists} "$LOCALAPPDATA\OmniGet\uninstall.exe"
    DetailPrint "Uninstalling OmniGet ($LOCALAPPDATA\OmniGet)..."
    ExecWait '"$LOCALAPPDATA\OmniGet\uninstall.exe" /S _?=$LOCALAPPDATA\OmniGet'
    Sleep 1000
  ${EndIf}

  ; 3. Check Programs per-user install directory ($LOCALAPPDATA\Programs\OmniGet)
  ${If} ${FileExists} "$LOCALAPPDATA\Programs\OmniGet\uninstall.exe"
    DetailPrint "Uninstalling OmniGet ($LOCALAPPDATA\Programs\OmniGet)..."
    ExecWait '"$LOCALAPPDATA\Programs\OmniGet\uninstall.exe" /S _?=$LOCALAPPDATA\Programs\OmniGet'
    Sleep 1000
  ${EndIf}

  ; 4. Check machine-wide install directory ($PROGRAMFILES\OmniGet)
  ${If} ${FileExists} "$PROGRAMFILES\OmniGet\uninstall.exe"
    DetailPrint "Uninstalling OmniGet ($PROGRAMFILES\OmniGet)..."
    ExecWait '"$PROGRAMFILES\OmniGet\uninstall.exe" /S _?=$PROGRAMFILES\OmniGet'
    Sleep 1000
  ${EndIf}

  ; 5. Check 64-bit machine-wide install directory ($PROGRAMFILES64\OmniGet)
  ${If} ${FileExists} "$PROGRAMFILES64\OmniGet\uninstall.exe"
    DetailPrint "Uninstalling OmniGet ($PROGRAMFILES64\OmniGet)..."
    ExecWait '"$PROGRAMFILES64\OmniGet\uninstall.exe" /S _?=$PROGRAMFILES64\OmniGet'
    Sleep 1000
  ${EndIf}

  ; 6. Hard-clean leftover directories in case uninstaller left any lingering files
  DetailPrint "Cleaning any leftover OmniGet artifacts..."
  RMDir /r "$LOCALAPPDATA\OmniGet"
  RMDir /r "$LOCALAPPDATA\Programs\OmniGet"
  RMDir /r "$PROGRAMFILES\OmniGet"
  RMDir /r "$PROGRAMFILES64\OmniGet"

  ; 7. Remove shortcuts (current user and all users)
  SetShellVarContext current
  Delete "$DESKTOP\OmniGet.lnk"
  Delete "$SMPROGRAMS\OmniGet.lnk"
  Delete "$SMPROGRAMS\OmniGet\*.lnk"
  RMDir /r "$SMPROGRAMS\OmniGet"

  SetShellVarContext all
  Delete "$DESKTOP\OmniGet.lnk"
  Delete "$SMPROGRAMS\OmniGet.lnk"
  Delete "$SMPROGRAMS\OmniGet\*.lnk"
  RMDir /r "$SMPROGRAMS\OmniGet"
  SetShellVarContext current

  ; 8. Clean obsolete registry uninstall keys
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OmniGet"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OmniGet"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\com.openselena.omniget"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\com.openselena.omniget"
!macroend
