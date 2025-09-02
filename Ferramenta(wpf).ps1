<# ---------------------------------------------------------
 MENU DE SUPORTE TÉCNICO (GUI WPF)
 Versão: 4.0 (PowerShell + WPF)
 Melhorias: ChatGPT
-----------------------------------------------------------#>

# ========== 1) Pré-requisitos e utilidades ==========
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Elevação (Admin)
function Ensure-Elevated {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        # Reexecutar elevado
        $psi = New-Object System.Diagnostics.ProcessStartInfo "powershell"
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        $psi.Verb = "runas"
        try {
            [Diagnostics.Process]::Start($psi) | Out-Null
        } catch {
            [System.Windows.MessageBox]::Show("É necessário executar como Administrador para todas as funções funcionarem corretamente.","Permissão negada",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning) | Out-Null
        }
        exit
    }
}
Ensure-Elevated

# Log
$Global:LogFile = Join-Path $PSScriptRoot "support_log.txt"
function Write-Log {
    param([Parameter(Mandatory)][string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] $Message"
    Add-Content -Path $Global:LogFile -Value $line
    if ($Global:UiLog) { $Global:UiLog.AppendText($line + "`r`n"); $Global:UiLog.ScrollToEnd() }
}

# Confirmação rápida
function Confirm-Action {
    param([string]$Texto="Confirmar ação?")
    $r = [System.Windows.MessageBox]::Show($Texto,"Confirmação",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Question)
    return ($r -eq [System.Windows.MessageBoxResult]::Yes)
}

# Execução de comando visível no log
function Run-Command {
    param(
        [Parameter(Mandatory)][scriptblock]$Script,
        [string]$Titulo = "Executando...",
        [switch]$Wait
    )
    try {
        $Global:StatusText.Text = $Titulo
        Write-Log $Titulo
        & $Script
        if ($Wait) { Start-Sleep 1 }
        $Global:StatusText.Text = "Pronto"
    } catch {
        $Global:StatusText.Text = "Erro"
        [System.Windows.MessageBox]::Show("Erro: $($_.Exception.Message)","Erro",
            [System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Error) | Out-Null
        Write-Log "Erro: $($_.Exception.Message)"
    }
}

# ========== 2) XAML (Layout da Janela) ==========
# Observação: layout responsivo com duas colunas: botões à esquerda; detalhes à direita
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MENU DO SUPORTE TECNICO (v4.0)"
        Width="1050" Height="680" WindowStartupLocation="CenterScreen"
        Background="#0d1117" Foreground="#e6edf3" FontFamily="Segoe UI">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Margin" Value="6"/>
            <Setter Property="Padding" Value="10"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Background" Value="#21262d"/>
            <Setter Property="Foreground" Value="#e6edf3"/>
            <Setter Property="BorderBrush" Value="#30363d"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>
        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="#e6edf3"/>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Foreground" Value="#e6edf3"/>
            <Setter Property="Background" Value="#161b22"/>
            <Setter Property="BorderBrush" Value="#30363d"/>
        </Style>
        <Style TargetType="ComboBox">
            <Setter Property="Foreground" Value="#e6edf3"/>
            <Setter Property="Background" Value="#161b22"/>
            <Setter Property="BorderBrush" Value="#30363d"/>
        </Style>
    </Window.Resources>

    <Grid Margin="16">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="420"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Cabeçalho -->
        <StackPanel Grid.ColumnSpan="2" Orientation="Horizontal" Margin="0 0 0 10">
            <TextBlock Text="MENU DO SUPORTE TECNICO" FontSize="20" FontWeight="SemiBold"/>
            <TextBlock Text="  ·  v4.0" Margin="8,0,0,0" Foreground="#8b949e"/>
        </StackPanel>

        <!-- Coluna de botões -->
        <ScrollViewer Grid.Row="1" Grid.Column="0">
            <UniformGrid Columns="1">
                <Button x:Name="Btn1"  Content="1) Verificar e Reparar Disco (CHKDSK)"/>
                <Button x:Name="Btn2"  Content="2) Reparar Arquivos de Sistema (SFC)"/>
                <Button x:Name="Btn3"  Content="3) Limpar Arquivos Temporários"/>
                <Button x:Name="Btn4"  Content="4) Verificar Erros de Memória (Diagnóstico)"/>
                <Button x:Name="Btn5"  Content="5) Restaurar Sistema"/>
                <Button x:Name="Btn6"  Content="6) Verificar Conectividade de Rede (Ping/Teste)"/>
                <Button x:Name="Btn7"  Content="7) Gerenciar Processos (Task Manager)"/>
                <Button x:Name="Btn8"  Content="8) Backup de Drivers"/>
                <Button x:Name="Btn9"  Content="9) Verificar Atualizações do Windows (Log)"/>
                <Button x:Name="Btn10" Content="10) Informações do Sistema"/>
                <Button x:Name="Btn11" Content="11) Limpar Cache DNS"/>
                <Button x:Name="Btn12" Content="12) Reiniciar Serviços de Rede"/>
                <Button x:Name="Btn13" Content="13) Desfragmentar Disco"/>
                <Button x:Name="Btn14" Content="14) Gerenciar Usuários Locais"/>
                <Button x:Name="Btn15" Content="15) Verificar Integridade de Arquivos (DISM)"/>
                <Button x:Name="Btn16" Content="16) Ativar/Desativar Firewall do Windows"/>
                <Button x:Name="Btn17" Content="17) Ver Logs de Eventos"/>
                <Button x:Name="Btn18" Content="18) Testar Velocidade de Disco"/>
                <Button x:Name="Btn19" Content="19) Criar Ponto de Restauração"/>
                <Button x:Name="Btn20" Content="20) Executar Comando Personalizado (CMD)"/>
                <Button x:Name="Btn21" Content="21) Atualizar Todos os Programas (Winget Update)"/>
                <Button x:Name="Btn22" Content="22) Sair"/>
            </UniformGrid>
        </ScrollViewer>

        <!-- Coluna de detalhes -->
        <Grid Grid.Row="1" Grid.Column="1" Margin="12 0 0 0">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Parâmetros rápidos -->
            <Border BorderBrush="#30363d" BorderThickness="1" Padding="10" CornerRadius="8" Background="#0b0f14">
                <StackPanel>
                    <TextBlock Text="Parâmetros rápidos" FontWeight="SemiBold" Margin="0 0 0 8" />
                    <StackPanel Orientation="Horizontal" Margin="0 4 0 0" VerticalAlignment="Center">
                        <TextBlock Text="Host para Ping: " Width="130" VerticalAlignment="Center"/>
                        <TextBox x:Name="TxtPing" Width="220" Text="8.8.8.8"/>
                        <Button x:Name="BtnPingGo" Content="Ping" Margin="8 0 0 0" Width="80"/>
                    </StackPanel>
                    <StackPanel Orientation="Horizontal" Margin="0 8 0 0" VerticalAlignment="Center">
                        <TextBlock Text="Unidade p/ Desfragmentar: " Width="180" VerticalAlignment="Center"/>
                        <ComboBox x:Name="CmbDrives" Width="100"/>
                        <Button x:Name="BtnDefragGo" Content="Desfragmentar" Margin="8 0 0 0" Width="120"/>
                    </StackPanel>
                </StackPanel>
            </Border>

            <!-- Log de execução -->
            <Border Grid.Row="1" BorderBrush="#30363d" BorderThickness="1" Padding="10" Margin="0 10 0 10" CornerRadius="8" Background="#0b0f14">
                <DockPanel>
                    <TextBlock Text="Log de Execução" DockPanel.Dock="Top" FontWeight="SemiBold" Margin="0 0 0 8"/>
                    <TextBox x:Name="TxtLog" AcceptsReturn="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" TextWrapping="NoWrap" IsReadOnly="True"/>
                </DockPanel>
            </Border>

            <!-- Barra de status -->
            <StatusBar Grid.Row="2" Background="#0b0f14" Foreground="#8b949e">
                <StatusBarItem>
                    <TextBlock x:Name="TxtStatus" Text="Pronto"/>
                </StatusBarItem>
                <StatusBarItem HorizontalAlignment="Right">
                    <TextBlock Text="© FUNESA"/>
                </StatusBarItem>
            </StatusBar>
        </Grid>

        <!-- Rodapé -->
        <StackPanel Grid.Row="2" Grid.ColumnSpan="2" Orientation="Horizontal" HorizontalAlignment="Right">
            <Button x:Name="BtnAbrirLog" Content="Abrir arquivo de Log" Width="170"/>
        </StackPanel>
    </Grid>
</Window>
"@

# ========== 3) Carregar XAML ==========
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Guardar referências de UI
$Global:UiLog     = $window.FindName("TxtLog")
$Global:StatusText= $window.FindName("TxtStatus")
$txtPing          = $window.FindName("TxtPing")
$cmbDrives        = $window.FindName("CmbDrives")

# Popular drives
[System.IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -eq 'Fixed' } | ForEach-Object {
    $cmbDrives.Items.Add($_.Name.TrimEnd('\'))
}
if ($cmbDrives.Items.Count -gt 0) { $cmbDrives.SelectedIndex = 0 }

# ========== 4) Ações (as 22 opções) ==========
# 1) CHKDSK
$window.FindName("Btn1").Add_Click({
    Run-Command -Titulo "Executou CHKDSK" -Script { Start-Process "chkdsk.exe" -Wait }
})
# 2) SFC
$window.FindName("Btn2").Add_Click({
    if (Confirm-Action "Executar SFC /scannow?") {
        Run-Command -Titulo "Executou SFC /scannow" -Script { Start-Process "sfc.exe" "/scannow" -Wait }
    }
})
# 3) Limpar temporários
$window.FindName("Btn3").Add_Click({
    Run-Command -Titulo "Limpou arquivos temporários" -Script {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
})
# 4) Diagnóstico de Memória
$window.FindName("Btn4").Add_Click({
    Run-Command -Titulo "Abriu Diagnóstico de Memória" -Script { Start-Process "mdsched.exe" }
})
# 5) Restaurar Sistema
$window.FindName("Btn5").Add_Click({
    Run-Command -Titulo "Abriu Restauração do Sistema" -Script { Start-Process "rstrui.exe" }
})
# 6) Ping/Teste
$window.FindName("Btn6").Add_Click({
    $hostPing = ($txtPing.Text.Trim())
    if (-not $hostPing) { $hostPing = "8.8.8.8" }
    Run-Command -Titulo "Testou conectividade: $hostPing" -Script {
        Test-Connection $hostPing -Count 5 | Out-String | ForEach-Object { Write-Log $_ }
    }
})
# botão rápido Ping
$window.FindName("BtnPingGo").Add_Click({
    $window.FindName("Btn6").RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
})
# 7) Task Manager
$window.FindName("Btn7").Add_Click({
    Run-Command -Titulo "Abriu Gerenciador de Tarefas" -Script { Start-Process "taskmgr.exe" }
})
# 8) Backup de Drivers
$window.FindName("Btn8").Add_Click({
    Run-Command -Titulo "Backup de drivers" -Script {
        $dest = Join-Path $env:USERPROFILE "Desktop\BackupDrivers"
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        pnputil /export-driver * "$dest" | Out-String | ForEach-Object { Write-Log $_ }
    }
})
# 9) Windows Update (Log)
$window.FindName("Btn9").Add_Click({
    Run-Command -Titulo "Gerou WindowsUpdate.log" -Script {
        Get-WindowsUpdateLog | Out-Null
        Write-Log "WindowsUpdate.log gerado na área de trabalho do usuário atual."
    }
})
# 10) Informações do Sistema
$window.FindName("Btn10").Add_Click({
    Run-Command -Titulo "Consultou informações do sistema" -Script {
        Get-ComputerInfo | Select-Object CsName,OsName,OsArchitecture,WindowsVersion,WindowsBuildLabEx |
            Out-String | ForEach-Object { Write-Log $_ }
    }
})
# 11) Flush DNS
$window.FindName("Btn11").Add_Click({
    Run-Command -Titulo "Limpou cache DNS" -Script { ipconfig /flushdns | Out-String | ForEach-Object { Write-Log $_ } }
})
# 12) Reset serviços de rede
$window.FindName("Btn12").Add_Click({
    if (Confirm-Action "Reiniciar serviços de rede (netsh winsock reset / ip reset)?") {
        Run-Command -Titulo "Reiniciou serviços de rede" -Script {
            netsh winsock reset      | Out-Null
            netsh int ip reset       | Out-Null
            Write-Log "É recomendável reiniciar o computador."
        }
    }
})
# 13) Desfragmentar disco
$window.FindName("Btn13").Add_Click({
    $drive = if ($cmbDrives.SelectedItem) { $cmbDrives.SelectedItem.ToString() } else { $env:SystemDrive }
    Run-Command -Titulo "Desfragmentação em $drive" -Script { defrag $drive | Out-String | ForEach-Object { Write-Log $_ } }
})
# botão rápido Desfrag
$window.FindName("BtnDefragGo").Add_Click({
    $window.FindName("Btn13").RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
})
# 14) Usuários locais
$window.FindName("Btn14").Add_Click({
    Run-Command -Titulo "Abriu gerenciamento de usuários locais" -Script { Start-Process "lusrmgr.msc" }
})
# 15) DISM
$window.FindName("Btn15").Add_Click({
    if (Confirm-Action "Executar DISM /Online /Cleanup-Image /ScanHealth?") {
        Run-Command -Titulo "Executou DISM /ScanHealth" -Script { DISM /Online /Cleanup-Image /ScanHealth | Out-String | ForEach-Object { Write-Log $_ } }
    }
})
# 16) Firewall
$window.FindName("Btn16").Add_Click({
    if (Confirm-Action "Deseja DESATIVAR o Firewall do Windows (todos os perfis)?") {
        Run-Command -Titulo "Firewall desativado" -Script { netsh advfirewall set allprofiles state off | Out-String | ForEach-Object { Write-Log $_ } }
    } else {
        Run-Command -Titulo "Firewall mantido/ativado" -Script { netsh advfirewall set allprofiles state on | Out-String | ForEach-Object { Write-Log $_ } }
    }
})
# 17) Event Viewer
$window.FindName("Btn17").Add_Click({
    Run-Command -Titulo "Abriu Visualizador de Eventos" -Script { Start-Process "eventvwr.msc" }
})
# 18) WinSAT Disk
$window.FindName("Btn18").Add_Click({
    Run-Command -Titulo "Testou velocidade de disco (winsat disk)" -Script { winsat disk | Out-String | ForEach-Object { Write-Log $_ } }
})
# 19) Ponto de Restauração
$window.FindName("Btn19").Add_Click({
    Run-Command -Titulo "Criou ponto de restauração" -Script {
        Checkpoint-Computer -Description "Ponto de Restauração Manual"
        Write-Log "Ponto de restauração solicitado (requer Proteção do Sistema habilitada)."
    }
})
# 20) CMD
$window.FindName("Btn20").Add_Click({
    Run-Command -Titulo "Abriu CMD" -Script { Start-Process "cmd.exe" }
})
# 21) Winget Update
$window.FindName("Btn21").Add_Click({
    Run-Command -Titulo "Atualizou programas via Winget" -Script { winget upgrade --all | Out-String | ForEach-Object { Write-Log $_ } }
})
# 22) Sair
$window.FindName("Btn22").Add_Click({
    if (Confirm-Action "Deseja realmente sair?") {
        Write-Log "Aplicação encerrada pelo usuário."
        $window.Close()
    }
})

# Botão abrir arquivo de log
$window.FindName("BtnAbrirLog").Add_Click({
    if (Test-Path $Global:LogFile) { Start-Process $Global:LogFile } else {
        [System.Windows.MessageBox]::Show("Ainda não existe log. Execute alguma ação primeiro.","Log", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
    }
})

# ========== 5) Iniciar interface ==========
# Carregar log inicial (se existir)
if (Test-Path $Global:LogFile) {
    Get-Content $Global:LogFile | ForEach-Object { $Global:UiLog.AppendText($_ + "`r`n") }
    $Global:UiLog.ScrollToEnd()
}
# Exibir janela
[void]$window.ShowDialog()
