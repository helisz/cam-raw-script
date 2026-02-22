@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

cd /d "%SCRIPT_DIR%"

:main_menu
cls
echo ==========================================
echo   RAW文件清理工具
echo ==========================================
echo 当前目录: %SCRIPT_DIR%
echo.
echo 请选择功能:
echo   1. 解锁当前目录及子目录下的所有文件
echo   2. 创建RAW文件夹并移动所有RAW文件
echo   3. 删除RAW文件夹中的RAW文件，只保留与JPG同名的文件（永久删除）
echo   4. 删除RAW文件夹中的RAW文件，只保留与JPG同名的文件（移到回收站）
echo   0. 退出
echo ==========================================
set /p choice=请输入选项 (0/1/2/3/4):

if "%choice%"=="0" goto exit_program
if "%choice%"=="1" goto unlock_files
if "%choice%"=="2" goto move_arw_to_raw
if "%choice%"=="3" goto delete_raw_files_permanently
if "%choice%"=="4" goto clean_raw_files
echo 无效的选项。
pause
goto main_menu

:unlock_files
echo.
echo 正在解锁目录: %SCRIPT_DIR%
echo 这将递归解锁当前目录及所有子目录中的文件...
echo.
echo 正在解锁文件...
set unlocked_count=0

for /r "%SCRIPT_DIR%" %%f in (*) do (
    attrib -r "%%f" >nul 2>&1
    if !errorlevel! equ 0 (
        set /a unlocked_count+=1
    )
)

echo.
echo 解锁完成。
pause
goto main_menu

:move_arw_to_raw
set "raw_dir=%SCRIPT_DIR%\RAW"

echo.
echo 正在扫描RAW文件...
set raw_count=0

REM 扫描所有RAW文件
for %%e in (3fr arw cr2 dng erf kdc mef mos mrw nrw orf pef ptx pxn r3d raw raf rw2 rwl srf srw x3f) do (
    for %%f in ("%%e") do (
        if exist "%%f" (
            set /a raw_count+=1
            set "raw_file_!raw_count!=%%f"
        )
    )
)

if %raw_count%==0 (
    echo 未找到任何RAW文件。
    pause
    goto main_menu
)

echo 找到 %raw_count% 个RAW文件

REM 创建RAW文件夹（如果不存在）
if not exist "%raw_dir%" (
    echo.
    echo 正在创建RAW文件夹...
    mkdir "%raw_dir%"
    echo 已创建: %raw_dir%
)

echo.
echo 将移动 %raw_count% 个RAW文件到RAW文件夹:
for /l %%i in (1,1,%raw_count%) do (
    echo   !raw_file_%%i!
)

echo.
echo 正在移动...
set moved_count=0

for /l %%i in (1,1,%raw_count%) do (
    move "!raw_file_%%i!" "%raw_dir%\" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   已移动: !raw_file_%%i!
        set /a moved_count+=1
    )
)

echo.
echo 完成。已移动 %moved_count% 个文件到RAW文件夹。
pause
goto main_menu

:delete_raw_files_permanently
set "raw_dir=%SCRIPT_DIR%\RAW"

if not exist "%raw_dir%" (
    echo 错误: RAW文件夹 '%raw_dir%' 不存在。
    pause
    goto main_menu
)

echo.
echo 正在扫描JPG文件...
set jpg_count=0

REM 扫描JPG文件
for %%e in (jpg jpeg) do (
    for %%f in ("*.%%e") do (
        set /a jpg_count+=1
        set "jpg_file_!jpg_count!=%%~nf"
    )
)

if %jpg_count%==0 (
    echo 警告: 未找到任何JPG文件。
) else (
    echo 找到 %jpg_count% 个JPG文件
)

echo.
echo 正在扫描RAW文件...
set raw_count=0

REM 扫描RAW文件夹中的RAW文件
cd /d "%raw_dir%"
for %%e in (3fr arw cr2 dng erf kdc mef mos mrw nrw orf pef ptx pxn r3d raw raf rw2 rwl srf srw x3f) do (
    for %%f in ("*.%%e") do (
        set /a raw_count+=1
        set "raw_file_!raw_count!=%%f"
        set "raw_path_!raw_count!=%%f"
    )
)
cd /d "%SCRIPT_DIR%"

if %raw_count%==0 (
    echo 未找到任何RAW文件。
    pause
    goto main_menu
)

echo 找到 %raw_count% 个RAW文件

REM 找出需要删除的文件
set delete_count=0
for /l %%i in (1,1,%raw_count%) do (
    set "found=0"
    for /l %%j in (1,1,%jpg_count%) do (
        if /i "!raw_file_%%i:~0,-4!"=="!jpg_file_%%j!" (
            set "found=1"
        )
    )
    if !found!==0 (
        set /a delete_count+=1
        set "delete_file_!delete_count!=!raw_path_%%i!"
    )
)

if %delete_count%==0 (
    echo.
    echo 没有需要删除的RAW文件。
    pause
    goto main_menu
)

echo.
echo 将永久删除 %delete_count% 个RAW文件:
for /l %%i in (1,1,%delete_count%) do (
    echo   !delete_file_%%i!
)

echo.
set /p confirm=确认永久删除? (y/n):
if /i not "%confirm%"=="y" (
    echo 已取消。
    pause
    goto main_menu
)

echo.
echo 正在永久删除...
set deleted_count=0

for /l %%i in (1,1,%delete_count%) do (
    del "%raw_dir%\!delete_file_%%i!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   已删除: !delete_file_%%i!
        set /a deleted_count+=1
    )
)

echo.
echo 完成。已永久删除 %deleted_count% 个文件。
pause
goto main_menu

:clean_raw_files
set "raw_dir=%SCRIPT_DIR%\RAW"

if not exist "%raw_dir%" (
    echo 错误: RAW文件夹 '%raw_dir%' 不存在。
    pause
    goto main_menu
)

echo.
echo 正在扫描JPG文件...
set jpg_count=0

REM 扫描JPG文件
for %%e in (jpg jpeg) do (
    for %%f in ("*.%%e") do (
        set /a jpg_count+=1
        set "jpg_file_!jpg_count!=%%~nf"
    )
)

if %jpg_count%==0 (
    echo 警告: 未找到任何JPG文件。
) else (
    echo 找到 %jpg_count% 个JPG文件
)

echo.
echo 正在扫描RAW文件...
set raw_count=0

REM 扫描RAW文件夹中的RAW文件
cd /d "%raw_dir%"
for %%e in (3fr arw cr2 dng erf kdc mef mos mrw nrw orf pef ptx pxn r3d raw raf rw2 rwl srf srw x3f) do (
    for %%f in ("*.%%e") do (
        set /a raw_count+=1
        set "raw_file_!raw_count!=%%f"
        set "raw_path_!raw_count!=%%f"
    )
)
cd /d "%SCRIPT_DIR%"

if %raw_count%==0 (
    echo 未找到任何RAW文件。
    pause
    goto main_menu
)

echo 找到 %raw_count% 个RAW文件

REM 找出需要删除的文件
set delete_count=0
for /l %%i in (1,1,%raw_count%) do (
    set "found=0"
    for /l %%j in (1,1,%jpg_count%) do (
        if /i "!raw_file_%%i:~0,-4!"=="!jpg_file_%%j!" (
            set "found=1"
        )
    )
    if !found!==0 (
        set /a delete_count+=1
        set "delete_file_!delete_count!=!raw_path_%%i!"
    )
)

if %delete_count%==0 (
    echo.
    echo 没有需要删除的RAW文件。
    pause
    goto main_menu
)

echo.
echo 将移动 %delete_count% 个RAW文件到回收站:
for /l %%i in (1,1,%delete_count%) do (
    echo   !delete_file_%%i!
)

echo.
set /p confirm=确认移动到回收站? (y/n):
if /i not "%confirm%"=="y" (
    echo 已取消。
    pause
    goto main_menu
)

echo.
echo 正在移动到回收站...
set deleted_count=0

for /l %%i in (1,1,%delete_count%) do (
    powershell -Command "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile('%raw_dir%\!delete_file_%%i!', 'OnlyErrorDialogs', 'SendToRecycleBin')" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   已移动到回收站: !delete_file_%%i!
        set /a deleted_count+=1
    )
)

echo.
echo 完成。已移动 %deleted_count% 个文件到回收站。
pause
goto main_menu

:exit_program
echo 退出程序。
pause
