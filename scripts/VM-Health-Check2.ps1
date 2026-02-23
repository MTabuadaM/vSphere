<#
.SYNOPSIS
    Reports active alarms, recent events, and failed tasks.
.DESCRIPTION
    Combines Get-AlarmDefinition, Get-Event, and Get-Task for incident analysis.
.PARAMETER vCenterServer
    vCenter FQDN or IP.
.EXAMPLE
    .\Alarm-Event-Task-Report.ps1 -vCenterServer "vcsa01.domain.local"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer
)

Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null

    $alarms = Get-AlarmDefinition | Where-Object { $_.Enabled }
    $events = Get-Event -After (Get-Date).AddDays(-7) -Severity Error, Warning
    $tasks = Get-Task -Status Error -Start (Get-Date).AddDays(-7)

    $report = [PSCustomObject]@{
        ActiveAlarms = $alarms.Name -join ', '
        RecentEvents = $events | Select-Object -First 10 | ForEach-Object { "$($_.CreatedTime): $($_.FullFormattedMessage)" } -join "`n"
        FailedTasks  = $tasks | Select-Object Name, StartTime, CompleteTime, Description -First 10
    }

    $report | Export-Csv -Path "Alarm_Event_Task_Report.csv" -NoTypeInformation  # Nota: Para objetos complejos, considera ConvertTo-Json para TXT
    Write-Output "Report exported to Alarm_Event_Task_Report.csv"
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
}
