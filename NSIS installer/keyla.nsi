; Headers

!include MUI2.nsh

; Constants

!define ICON          ..\keyla\res\Icon.ico
!define PROGRAM_NAME  keyla
!define VERSION_SHORT 0.1.9
!define VERSION 0.1.9.0
!define WNDCLASS      "keyla main window"

; General configuration

InstallDir   $PROGRAMFILES\${PROGRAM_NAME}
Name         ${PROGRAM_NAME}
OutFile      keyla-${VERSION_SHORT}-setup.exe

InstallDirRegKey HKCU "Software\${PROGRAM_NAME}" "installDir"

; General configuration for MUI

!define MUI_ICON   ${ICON}
!define MUI_UNICON ${ICON}

; Pages configuration

!define MUI_ABORTWARNING

; List of pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE ..\LICENSE
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN $INSTDIR\${PROGRAM_NAME}.exe
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION AddToAutostart
Function AddToAutostart
  CreateShortCut $SMSTARTUP\${PROGRAM_NAME}.lnk $INSTDIR\${PROGRAM_NAME}.exe
FunctionEnd
!define MUI_CUSTOMFUNCTION_GUIINIT GuiInit
Function GuiInit
  !define MUI_FINISHPAGE_SHOWREADME_TEXT $(STRING_AUTORUN)
FunctionEnd
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Languages

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "Bulgarian"

!include "languages\english.nsh"
!include "languages\russian.nsh"
!include "languages\bulgarian.nsh"

; Version information

VIProductVersion ${VERSION}

VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© Eugene Arshinov, 2008"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Keyboard layout switcher"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" ${VERSION}

VIAddVersionKey /LANG=${LANG_RUSSIAN} "LegalCopyright" "© Евгений Аршинов, 2008"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "FileDescription" "Переключатель раскладки клавиатуры"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "FileVersion" ${VERSION}

VIAddVersionKey /LANG=${LANG_BULGARIAN} "LegalCopyright" "© Евгений Аршинов, 2008"
VIAddVersionKey /LANG=${LANG_BULGARIAN} "FileDescription" "Програма за превключване на клавиатурните подредби"
VIAddVersionKey /LANG=${LANG_BULGARIAN} "FileVersion" ${VERSION}

; Callbacks

Function .onInit

  ; Choose language

  !insertmacro MUI_LANGDLL_DISPLAY
  
  ; Check whether keyla is already installed

  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "UninstallString"
  StrCmp $R0 "" done
  MessageBox MB_YESNO|MB_ICONEXCLAMATION $(STRING_UNINSTALL_OLD_VERSION) IDYES uninst
  Abort 
uninst:
  ClearErrors
  Exec $INSTDIR\Uninstall.exe	
done:

FunctionEnd

Function un.onInit

  ; Choose language

  !insertmacro MUI_LANGDLL_DISPLAY
  
  ; Check whether keyla is now running

  retry:
  FindWindow $0 "${WNDCLASS}"
  StrCmp $0 0 continue
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION $(STRING_QUIT_KEYLA) IDRETRY retry
    Abort
  continue:
  
FunctionEnd

; Sections

Section

  ; Files 
  SetOutPath $INSTDIR
  File ..\Release\keyla.exe
  File ..\Release\layoutHookDll.dll
  SetOutPath $INSTDIR\icons
  File ..\icons\*.ico
  
  ;  Registry keys
  WriteRegStr HKCU Software\${PROGRAM_NAME} installDir $INSTDIR
  
  ; Start menu items
  CreateDirectory $SMPROGRAMS\${PROGRAM_NAME}
  CreateShortCut $SMPROGRAMS\${PROGRAM_NAME}\${PROGRAM_NAME}.lnk $INSTDIR\${PROGRAM_NAME}.exe
  
  ; Uninstaller registry keys
  WriteRegStr HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME} DisplayName $(STRING_KEYLA_IS_A_KEYBOARD_LAYOUT_SWITCHER)
  WriteRegStr HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME} UninstallString $INSTDIR\Uninstall.exe
  
  ; Uninstaller
  WriteUninstaller $INSTDIR\Uninstall.exe
  
SectionEnd

 
Section Uninstall

  ;Current working directory can not be deleted. So change it
  SetOutPath $TEMP
  
  ;Files 
  Delete $INSTDIR\${PROGRAM_NAME}.exe
  Delete $INSTDIR\Uninstall.exe
  RMDir /r $INSTDIR\icons
  RMDir $INSTDIR
  
  ;Start menu items
  RMDir /r $SMPROGRAMS\${PROGRAM_NAME}
  
  ; Autostart
  Delete $SMSTARTUP\${PROGRAM_NAME}.lnk
  
  ;Uninstaller registry keys 
  DeleteRegKey HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}
  
SectionEnd
