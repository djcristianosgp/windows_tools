@echo off
title MENU DE SUPORTE E REPARO
color 0A
setlocal enabledelayedexpansion

:MENU
cls
echo ==============================================
echo       MENU DO SUPORTE TECNICO
echo           por Pablo Oliveira - V2.0
echo ==============================================
echo.
echo  1. Verificar e Reparar Disco (CHKDSK)
echo  2. Reparar Arquivos de Sistema (SFC)
echo  3. Limpar Arquivos Temporarios
echo  4. Verificar Erros de Memoria (Diagnostico)
echo  5. Restaurar Sistema
echo  6. Verificar Conectividade de Rede (Ping/Teste)
echo  7. Gerenciar Processos (Task Manager)
echo  8. Backup de Drivers
echo  9. Verificar Atualizacoes do Windows
echo 10. Informacoes do Sistema
echo 11. Limpar Cache DNS
echo 12. Reiniciar Servicos de Rede
echo 13. Desfragmentar Disco
echo 14. Gerenciar Usuarios Locais
echo 15. Verificar Integridade de Arquivos (DISM)
echo 16. Ativar/Desativar Firewall do Windows
echo 17. Ver Logs de Eventos
echo 18. Testar Velocidade de Disco
echo 19. Criar Ponto de Restauracao
echo 20. Executar Comando Personalizado (CMD)
echo 21. Atualizar Todos os Programas (Winget Update)
echo 22. Sair
echo ==============================================
choice /C 123456789ABCDEFGHIJKLMNOPQRSTUVWX /N /M "Escolha uma opcao (1-22): "

:: Mapeamento das escolhas
if errorlevel 22 exit
if errorlevel 21 call :WINGET
if errorlevel 20 call :CMD
if errorlevel 19 call :RESTOREPOINT
if errorlevel 18 call :DISKTEST
if errorlevel 17 call :EVENTLOG
if errorlevel 16 call :FIREWALL
if errorlevel 15 call :DISM
if errorlevel 14 call :USERS
if errorlevel 13 call :DEFRAG
if errorlevel 12 call :RESETNET
if errorlevel 11 call :DNS
if errorlevel 10 call :SYSINFO
if errorlevel 9 call :UPDATES
if errorlevel 8 call :DRIVERBACKUP
if errorlevel 7 call :TASKMGR
if errorlevel 6 call :PING
if errorlevel 5 call :RESTORE
if errorlevel 4 call :MEMTEST
if errorlevel 3 call :CLEANTEMP
if errorlevel 2 call :SFC
if errorlevel 1 call :CHKDSK
goto MENU

:LOG
echo [%date% %time%] %* >> support_log.txt
exit /b

:CHKDSK
call :LOG Executou CHKDSK
chkdsk
pause
goto MENU

:SFC
call :LOG Executou SFC
sfc /scannow
pause
goto MENU

:CLEANTEMP
call :LOG Limpou arquivos temporarios
powershell -command "Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue"
pause
goto MENU

:MEMTEST
call :LOG Abriu Diagnostico de Memoria
mdsched
goto MENU

:RESTORE
call :LOG Abriu Restauracao do Sistema
rstrui
goto MENU

:PING
call :LOG Testou conectividade de rede
ping 8.8.8.8 -n 5
pause
goto MENU

:TASKMGR
call :LOG Abriu Gerenciador de Tarefas
taskmgr
goto MENU

:DRIVERBACKUP
call :LOG Backup de drivers iniciado
echo Fazendo backup de drivers para a area de trabalho...
pnputil /export-driver * "%userprofile%\Desktop\BackupDrivers"
pause
goto MENU

:UPDATES
call :LOG Verificou atualizacoes do Windows
powershell -command "Get-WindowsUpdateLog"
pause
goto MENU

:SYSINFO
call :LOG Consultou informacoes do sistema
powershell -command "Get-ComputerInfo | Select-Object CsName,OsName,OsArchitecture,WindowsVersion,WindowsBuildLabEx"
pause
goto MENU

:DNS
call :LOG Limpou cache DNS
ipconfig /flushdns
pause
goto MENU

:RESETNET
set /p confirm="Tem certeza que deseja reiniciar os servicos de rede? (S/N): "
if /I "%confirm%"=="S" (
    call :LOG Reiniciou servicos de rede
    netsh winsock reset
    netsh int ip reset
)
pause
goto MENU

:DEFRAG
call :LOG Executou desfragmentacao
defrag %SystemDrive%
pause
goto MENU

:USERS
call :LOG Abriu gerenciamento de usuarios locais
lusrmgr.msc
goto MENU

:DISM
set /p confirm="Executar DISM /ScanHealth? (S/N): "
if /I "%confirm%"=="S" (
    call :LOG Executou DISM
    DISM /Online /Cleanup-Image /ScanHealth
)
pause
goto MENU

:FIREWALL
set /p confirm="Deseja DESATIVAR o Firewall do Windows? (S/N): "
if /I "%confirm%"=="S" (
    call :LOG Firewall desativado
    netsh advfirewall set allprofiles state off
) else (
    call :LOG Firewall mantido ativo
)
pause
goto MENU

:EVENTLOG
call :LOG Abriu Visualizador de Eventos
eventvwr
goto MENU

:DISKTEST
call :LOG Testou velocidade de disco
winsat disk
pause
goto MENU

:RESTOREPOINT
call :LOG Criou ponto de restauracao
powershell -Command "Checkpoint-Computer -Description 'Ponto de Restauracao Manual'"
pause
goto MENU

:CMD
call :LOG Abriu CMD personalizado
cmd
goto MENU

:WINGET
call :LOG Atualizou programas via Winget
winget upgrade --all
pause
goto MENU
