; Copyright (c) 2015 ARM Limited. All rights reserved.
;
; SPDX-License-Identifier: Apache-2.0
;
; Licensed under the Apache License, Version 2.0 (the License); you may
; not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
; http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an AS IS BASIS, WITHOUT
; WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; Yotta Windows Installer
;
; This script installs the yotta dependencies and then yotta itself
; pip is installed as part of python, it is assumed to exist on the user system
; All dependencies use NSIS for their installers, See http://nsis.sourceforge.net/Docs/Chapter4.html#4.12
;  for a full list of NSIS install parameters
;--------------------------------

;--------------------------------
;Include Modern UI
!include MUI2.nsh
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "..\source\HeaderImage_Bitmap.bmp" ; recommended size: 150x57 pixels
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\source\WelcomeScreen.bmp" ;recommended size: 164x314 pixels
;!define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
!define MUI_ICON p.ico

;--------------------------------
;Config Section
  !define PRODUCT_NAME      "yotta"
  !define PRODUCT_VERSION   "0.1.0"
  !define PRODUCT_PUBLISHER "ARM®mbed™"
  !define PYTHON_INSTALLER  "python-2.7.10.msi"
  !define GCC_INSTALLER     "gcc-arm-none-eabi-4_9-2015q2-20150609-win32.exe"
  !define CMAKE_INSTALLER   "cmake-3.2.1-win32-x86.exe"
  !define NINJA_INSTALLER   "ninja.exe"

  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  OutFile "yotta_install_v${PRODUCT_VERSION}.exe"
  InstallDir "C:\yotta"
  ShowInstDetails show

;--------------------------------
;Pages
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE 'yotta - it means build awesome'
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\source\license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TITLE 'Now, go build awesome!'
!insertmacro MUI_PAGE_FINISH

;--------------------------------
;Branding
BrandingText "next gen build system from ${PRODUCT_PUBLISHER}"

;!define MUI_WELCOMEFINISHPAGE_BITMAP "mbed-enabled-logo.bmp"
;BGGradient 00699d 0079b4  cc2020

;--------------------------------
;Languages
!insertmacro MUI_LANGUAGE "English"

Section -SETTINGS
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
SectionEnd

;--------------------------------
;Installer Sections

Section "python 2.7.10" SecPython
  SetOutPath $INSTDIR
  File "..\prerequisites\${PYTHON_INSTALLER}"
  ; Install options for python taken from https://www.python.org/download/releases/2.5/msi/
  ; This gets python to add itsself to the path.
  ExecWait '"msiexec" TARGETDIR="$INSTDIR\python" /i "$INSTDIR\${PYTHON_INSTALLER}" /qb!'
;  ExecWait '"msiexec" /i "$INSTDIR\${PYTHON_INSTALLER}" ADDLOCAL=ALL /qb!'
  ; for logging msiexec /i python-2.7.10.msi /qb /l*v "c:\Program Files\yotta\install.log.txt"
SectionEnd

Section "gcc" SecGCC
  File "..\prerequisites\${GCC_INSTALLER}"
  ExecWait "$INSTDIR\${GCC_INSTALLER} /S /D=$INSTDIR\gcc"
SectionEnd

Section "cMake" SecCmake
  File "..\prerequisites\${CMAKE_INSTALLER}"
  ; TODO: get cmake to add itself to the path via command line install options
  ExecWait "$INSTDIR\${CMAKE_INSTALLER} /S /D=$INSTDIR\cmake"
SectionEnd

Section "ninja" SecNinja
  File "..\prerequisites\${NINJA_INSTALLER}"
  ;ExecWait '"setx" PATH "%PATH%;$INSTDIR"' ; setx is a windows vista,7,8,10 command to modify the path, here we are adding the yotta directory to the path
  ; note: this will fail on XP, XP users are not covered and will need to add ninja to their path manually
SectionEnd

Section "yotta (requires pip)" SecYotta
  File "..\source\pip_install_yotta.bat"
  ExecWait '"$INSTDIR\pip_install_yotta.bat" "$INSTDIR"'
SectionEnd

Section "Add yotta shortcut to StartMenu / Desktop" SecRunYotta
  File "..\source\run_yotta.bat"
  File "..\source\p.ico"
;  Exec "run_yotta.bat"
  CreateShortCut "$SMPROGRAMS\Run Yotta.lnk" "$INSTDIR\run_yotta.bat"  ""  "$INSTDIR\p.ico"
  CreateShortCut "$DESKTOP\Run Yotta.lnk"    "$INSTDIR\run_yotta.bat"  ""  "$INSTDIR\p.ico"
SectionEnd
