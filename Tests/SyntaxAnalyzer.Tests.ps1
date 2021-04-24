using namespace Microsoft.PowerShell.Commands

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "SyntaxAnalyzer" {
    BeforeAll {
        function Test-IsPrerequisitesRunning {
            $result = $true
            $ports = 7071, 10002

            foreach ($port in $ports) {
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $result = $result -and $tcpClient.ConnectAsync('127.0.0.1', $port).Wait(100)
            }

            $tcpClient.Dispose()

            return $result
        }

        Write-Warning "Checking if function app and storage emulator are running.."
        if (-not (Test-IsPrerequisitesRunning)) {
            Write-Warning "Starting Function App and Azure Storage Emulator.."
            Start-Job {
                AzureStorageEmulator.exe start
            }

            Start-Job {
                Push-Location .\explainpowershell.analysisservice\
                func host start .\explainpowershell.analysisservice
            }

            do {
                Start-Sleep -Seconds 2
            } until (Test-IsPrerequisitesRunning)
        }

        Write-Warning "OK - Function App and Azure Storage Emulator running"
    }

    It "Converts aliase to full command name" {
        $code = 'gci'
        [BasicHtmlWebResponseObject]$result = SyntaxAnalyzer -PowerShellCode $code
        $content = $result.Content | ConvertFrom-Json
        $content.ExpandedCode | Should -BeExactly 'Get-ChildItem'
    }

    It "Converts multiple aliases to full command names" {
        $code = 'gps | select name | ? name -like dotnet'
        [BasicHtmlWebResponseObject]$result = SyntaxAnalyzer -PowerShellCode $code
        $content = $result.Content | ConvertFrom-Json
        $content.ExpandedCode | Should -BeExactly 'Get-Process | Select-Object name | Where-Object name -like dotnet'
    }

    AfterAll {
        Get-Job | Stop-Job -PassThru | Remove-Job -Force
    }
}
