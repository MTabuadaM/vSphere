<#
.SYNOPSIS
    Generates a detailed inventory report of virtual machines in vSphere.
.DESCRIPTION
    Collects VM details including name, power state, CPU, memory, guest OS, IP addresses, datastores, and tags.
    Exports results to CSV, XML, or TXT format.
.PARAMETER vCenterServer
    The FQDN or IP address of the vCenter Server.
.PARAMETER OutputFormat
    Output format: CSV (default), XML, or TXT.
.PARAMETER FilterPowerState
    Optional filter: PoweredOn, PoweredOff, Suspended.
.EXAMPLE
    .\VM-Inventory-Report.ps1 -vCenterServer "vcsa01.domain.local" -OutputFormat CSV
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$vCenterServer,

    [ValidateSet("CSV", "XML", "TXT")]
    [string]$OutputFormat = "CSV",

    [ValidateSet("PoweredOn", "PoweredOff", "Suspended", $null)]
    [string]$FilterPowerState = $null
)

# Load PowerCLI module
if (-not (Get-Module -Name VMware.PowerCLI -ListAvailable)) {
    Write-Error "VMware.PowerCLI module not found. Install it with: Install-Module -Name VMware.PowerCLI -Scope CurrentUser"
    exit 1
}
Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue

try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop | Out-Null
}
catch {
    Write-Error "Failed to connect to vCenter: $($_.Exception.Message)"
    exit 1
}

try {
    $vms = Get-VM -ErrorAction Stop

    if ($FilterPowerState) {
        $vms = $vms | Where-Object { $_.PowerState -eq $FilterPowerState }
    }

    $report = $vms | Select-Object @{
        Name = 'Name'; Expression = { $_.Name }
    }, @{
        Name = 'PowerState'; Expression = { $_.PowerState }
    }, @{
        Name = 'NumCpu'; Expression = { $_.NumCpu }
    }, @{
        Name = 'MemoryGB'; Expression = { $_.MemoryGB }
    }, @{
        Name = 'GuestOS'; Expression = { $_.Guest.OSFullName }
    }, @{
        Name = 'IPAddress'; Expression = { ($_.Guest.IPAddress -join ', ') }
    }, @{
        Name = 'Datastore'; Expression = { ($_.DatastoreIdList | ForEach-Object { (Get-Datastore -Id $_).Name }) -join ', ' }
    }, @{
        Name = 'Tags'; Expression = { ($_.Tags | ForEach-Object { $_.Name }) -join ', ' }
    }

    $outputFile = "VM_Inventory_$((Get-Date).ToString('yyyyMMdd_HHmm')).$($OutputFormat.ToLower())"

    switch ($OutputFormat) {
        "CSV" { $report | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8 }
        "XML" { $report | Export-Clixml -Path $outputFile }
        "TXT" { $report | Format-Table -AutoSize | Out-File -FilePath $outputFile -Encoding UTF8 }
    }

    Write-Output "Inventory report generated: $outputFile"
}
catch {
    Write-Error "Error generating report: $($_.Exception.Message)"
}
finally {
    if ($global:DefaultVIServers) {
        Disconnect-VIServer -Server $vCenterServer -Confirm:$false -ErrorAction SilentlyContinue
    }
}
