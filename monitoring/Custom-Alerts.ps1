# Custom-Alerts.ps1
# Example of monitoring CPU Ready Time and Memory Ballooning

Connect-VIServer -Server "vcenter.local" -User "admin" -Password "password"

Get-VM | ForEach-Object {
    $stats = Get-Stat -Entity $_ -Stat "cpu.ready.summation" -Realtime -MaxSamples 1
    if ($stats.Value -gt 500) {
        Write-Host "Alert: High CPU Ready Time on $($_.Name)"
    }
}

Disconnect-VIServer -Confirm:$false
