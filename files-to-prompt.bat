@echo off
REM files-to-prompt.bat - Batch file ingestion for Claude (Windows)
REM Created for CH405_047 | Chaos Line

setlocal enabledelayedexpansion

REM Default settings
set "RECURSIVE=1"
set "SHOW_TREE=1"
set "SHOW_INSTRUCTIONS=1"
set "OUTPUT_FILE="
set "DIRECTORY="

REM Parse arguments
:parse_args
if "%~1"=="" goto check_args
if /i "%~1"=="-h" goto show_help
if /i "%~1"=="--help" goto show_help
if /i "%~1"=="-o" (
    set "OUTPUT_FILE=%~2"
    shift
    shift
    goto parse_args
)
if /i "%~1"=="-n" (
    set "RECURSIVE=0"
    shift
    goto parse_args
)
if /i "%~1"=="-t" (
    set "SHOW_TREE=0"
    shift
    goto parse_args
)
if /i "%~1"=="-i" (
    set "SHOW_INSTRUCTIONS=0"
    shift
    goto parse_args
)
set "DIRECTORY=%~1"
shift
goto parse_args

:check_args
if "%DIRECTORY%"=="" (
    echo Error: Directory argument required
    echo Use -h for help
    exit /b 1
)

if not exist "%DIRECTORY%" (
    echo Error: Directory '%DIRECTORY%' does not exist
    exit /b 1
)

REM Get absolute path
pushd "%DIRECTORY%"
set "DIRECTORY=%CD%"
popd

echo Scanning: %DIRECTORY%

REM Create temp file list
set "TEMP_LIST=%TEMP%\files_list_%RANDOM%.txt"

REM Collect files
if %RECURSIVE%==1 (
    dir /b /s /a-d "%DIRECTORY%\*" 2>nul | findstr /v /i "\.git\\ node_modules\\ __pycache__\\ \.pyc$ \.DS_Store$ venv\\ dist\\ build\\" > "%TEMP_LIST%"
) else (
    dir /b /a-d "%DIRECTORY%\*" 2>nul | findstr /v /i "\.pyc$ \.DS_Store$" > "%TEMP_LIST%"
)

REM Count files
set /a FILE_COUNT=0
for /f %%A in ('type "%TEMP_LIST%" ^| find /c /v ""') do set FILE_COUNT=%%A

if %FILE_COUNT%==0 (
    echo No files found
    del "%TEMP_LIST%"
    exit /b 1
)

echo Found %FILE_COUNT% files
echo Generating prompt...

REM Redirect output
if not "%OUTPUT_FILE%"=="" (
    call :generate_prompt > "%OUTPUT_FILE%"
    echo Prompt written to %OUTPUT_FILE%
) else (
    call :generate_prompt
)

del "%TEMP_LIST%"
echo Done!
exit /b 0

REM ============================================================================
REM Generate prompt function
REM ============================================================================
:generate_prompt

echo ================================================================================
echo FILE INGESTION PROMPT
echo Source Directory: %DIRECTORY%
echo Total Files: %FILE_COUNT%
echo ================================================================================
echo.

REM Directory tree
if %SHOW_TREE%==1 (
    echo DIRECTORY STRUCTURE:
    echo --------------------------------------------------------------------------------
    tree /F "%DIRECTORY%" 2>nul
    echo.
    echo ================================================================================
    echo.
)

REM Instructions
if %SHOW_INSTRUCTIONS%==1 (
    echo INSTRUCTIONS:
    echo --------------------------------------------------------------------------------
    echo Please analyze the following files and help me:
    echo 1. Extract and organize components into /components directory
    echo 2. Create templates in /templates directory
    echo 3. Set up proper project structure with fonts, public, pages
    echo 4. Generate a comprehensive README.md
    echo.
    echo Focus on:
    echo - Component separation ^(Hero, CTA, Testimonials, PricingSection, Header, Footer^)
    echo - Template creation ^(LandingPageBusiness, AgencySite, PortfolioSite^)
    echo - Configuration files and scripts organization
    echo - Best practices and code quality
    echo.
    echo ================================================================================
    echo.
)

REM File contents
echo FILE CONTENTS:
echo ================================================================================
echo.

set /a COUNTER=1
for /f "usebackq delims=" %%F in ("%TEMP_LIST%") do (
    call :process_file "%%F"
    set /a COUNTER+=1
)

echo ================================================================================
echo END OF FILE INGESTION
echo Total Files Processed: %FILE_COUNT%
echo ================================================================================

exit /b 0

REM ============================================================================
REM Process individual file
REM ============================================================================
:process_file
set "FILE_PATH=%~1"
set "RELATIVE_PATH=!FILE_PATH:%DIRECTORY%\=!"
set "FILE_EXT=%~x1"
set "FILE_EXT=!FILE_EXT:~1!"

REM Get file size
for %%A in ("%FILE_PATH%") do set FILE_SIZE=%%~zA

echo [FILE %COUNTER%/%FILE_COUNT%]
echo Path: !RELATIVE_PATH!
echo Info: !FILE_EXT! ^| !FILE_SIZE! bytes
echo --------------------------------------------------------------------------------
type "%FILE_PATH%"
echo.
echo --------------------------------------------------------------------------------
echo.

exit /b 0

REM ============================================================================
REM Show help
REM ============================================================================
:show_help
echo files-to-prompt - Batch file ingestion tool for Claude
echo.
echo USAGE:
echo     files-to-prompt.bat [OPTIONS] ^<directory^>
echo.
echo OPTIONS:
echo     -o FILE         Output to file instead of stdout
echo     -n              Non-recursive (current directory only)
echo     -t              Skip directory tree
echo     -i              Skip instructions
echo     -h              Show this help message
echo.
echo EXAMPLES:
echo     REM Process Downloads directory
echo     files-to-prompt.bat C:\Users\YourName\Downloads
echo.
echo     REM Save to file
echo     files-to-prompt.bat C:\Users\YourName\Downloads -o prompt.txt
echo.
echo     REM Quick mode (no tree, no instructions)
echo     files-to-prompt.bat C:\Users\YourName\Downloads -t -i -o prompt.txt
echo.
echo     REM Current directory only
echo     files-to-prompt.bat . -n
echo.
echo Created for CH405_047 ^| Chaos Line
exit /b 0
