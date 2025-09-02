# ============================================
# MENU DE SUPORTE TECNICO
# Versão: 3.0 (PowerShell Edition)
# Autor original: Pablo Oliveira
# Melhorias: ChatGPT
# ============================================

$logFile = "$PSScriptRoot\support_log.txt"

function Write-Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$timestamp] $msg"
}

function Pause {
    Write-Host "`nPressione qualquer tecla para continuar..." -ForegroundColor DarkGray
    [void][System.Console]::ReadKey($true)
}

function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "      MENU DO SUPORTE TECNICO" -ForegroundColor Green
    Write-Host "             por Pablo Oliveira - V3.0" -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Verificar e Reparar Disco (CHKDSK)"
    Write-Host "  2. Reparar Arquivos de Sistema (SFC)"
    Write-Host "  3. Limpar Arquivos Temporarios"
    Write-Host "  4. Verificar Erros de Memoria (Diagnostico)"
    Write-Host "  5. Restaurar Sistema"
    Write-Host "  6. Verificar Conectividade de Rede (Ping/Teste)"
    Write-Host "  7. Gerenciar Processos (Task Manager)"
    Write-Host "  8. Backup de Drivers"
    Write-Host "  9. Verificar Atualizacoes do Windows"
    Write-Host " 10. Informacoes do Sistema"
    Write-Host " 11. Limpar Cache DNS"
    Write-Host " 12. Reiniciar Servicos de Rede"
    Write-Host " 13. Desfragmentar Disco"
    Write-Host " 14. Gerenciar Usuarios Locais"
    Write-Host " 15. Verificar Integridade de Arquivos (DISM)"
    Write-Host " 16. Ativar/Desativar Firewall do Windows"
    Write-Host " 17. Ver Logs de Eventos"
    Write-Host " 18. Testar Velocidade de Disco"
    Write-Host " 19. Criar Ponto de Restauracao"
    Write-Host " 20. Executar Comando Personalizado (CMD)"
    Write-Host " 21. Atualizar Todos os Programas (Winget Update)"
    Write-Host " 22. Sair"
    Write-Host "==============================================" -ForegroundColor Cyan
}

function Run-Option($choice) {
    switch ($choice) {
        1 { Write-Log "Executou CHKDSK"; Start-Process "chkdsk" -Wait }
        2 { Write-Log "Executou SFC"; Start-Process "sfc" "/scannow" -Wait }
        3 { Write-Log "Limpou arquivos temporarios"; Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue }
        4 { Write-Log "Abriu Diagnostico de Memoria"; Start-Process "mdsched.exe" }
        5 { Write-Log "Abriu Restauracao do Sistema"; Start-Process "rstrui.exe" }
        6 { Write-Log "Testou conectividade de rede"; Test-Connection 8.8.8.8 -Count 5 | Format-Table }
        7 { Write-Log "Abriu Task Manager"; Start-Process "taskmgr.exe" }
        8 { Write-Log "Backup de drivers iniciado"; pnputil /export-driver * "$env:USERPROFILE\Desktop\BackupDrivers" }
        9 { Write-Log "Verificou atualizacoes do Windows"; Get-WindowsUpdateLog }
        10 { Write-Log "Consultou informacoes do sistema"; Get-ComputerInfo | Select-Object CsName,OsName,OsArchitecture,WindowsVersion,WindowsBuildLabEx | Format-List }
        11 { Write-Log "Limpou cache DNS"; ipconfig /flushdns }
        12 { 
            $ans = Read-Host "Tem certeza que deseja reiniciar servicos de rede? (S/N)"
            if ($ans -match "^[Ss]$") {
                Write-Log "Reiniciou servicos de rede"
                netsh winsock reset; netsh int ip reset
            }
        }
        13 { Write-Log "Executou desfragmentacao"; defrag $env:SystemDrive }
        14 { Write-Log "Abriu gerenciamento de usuarios locais"; Start-Process "lusrmgr.msc" }
        15 { 
            $ans = Read-Host "Executar DISM /ScanHealth? (S/N)"
            if ($ans -match "^[Ss]$") {
                Write-Log "Executou DISM"
                DISM /Online /Cleanup-Image /ScanHealth
            }
        }
        16 { 
            $ans = Read-Host "Deseja DESATIVAR o Firewall do Windows? (S/N)"
            if ($ans -match "^[Ss]$") {
                Write-Log "Firewall desativado"
                netsh advfirewall set allprofiles state off
            } else {
                Write-Log "Firewall mantido ativo"
            }
        }
        17 { Write-Log "Abriu Visualizador de Eventos"; Start-Process "eventvwr.msc" }
        18 { Write-Log "Testou velocidade de disco"; winsat disk }
        19 { Write-Log "Criou ponto de restauracao"; Checkpoint-Computer -Description "Ponto de Restauracao Manual" }
        20 { Write-Log "Abriu CMD"; Start-Process "cmd.exe" }
        21 { Write-Log "Atualizou programas via Winget"; winget upgrade --all }
        22 { Write-Host "Saindo..." -ForegroundColor Red; exit }
        Default { Write-Host "Opcao invalida!" -ForegroundColor Red }
    }
    Pause
}

# ===== LOOP PRINCIPAL =====
while ($true) {
    Show-Menu
    $choice = Read-Host "Digite uma opcao (1-22)"
    Run-Option $choice
}
