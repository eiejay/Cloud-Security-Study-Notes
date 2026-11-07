<#
.SYNOPSIS
Reports enabled accounts that have been inactive longer than a threshold.

.DESCRIPTION
Reads a CSV export with columns SamAccountName, DisplayName, LastLogon,
Enabled. Writes inactive_users.csv with the matching accounts and
inactive_users_summary.txt with counts. Report only: changes nothing.

.EXAMPLE
.\inactive_users_report.ps1 -InputPath .\sample_users.csv -DaysInactive 90
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,
    [int]$DaysInactive = 90,
    [string]$OutputPath = ".\inactive_users.csv",
    [string]$SummaryPath = ".\inactive_users_summary.txt"
)

$cutoff = (Get-Date).AddDays(-$DaysInactive)
$users = Import-Csv -Path $InputPath

$inactive = foreach ($user in $users) {
    if ($user.Enabled -ne "True") { continue }
    if ([string]::IsNullOrWhiteSpace($user.LastLogon)) {
        [PSCustomObject]@{
            SamAccountName = $user.SamAccountName
            DisplayName    = $user.DisplayName
            LastLogon      = "Never"
            Finding        = "Enabled account has never logged on"
        }
        continue
    }
    $lastLogon = [datetime]$user.LastLogon
    if ($lastLogon -lt $cutoff) {
        [PSCustomObject]@{
            SamAccountName = $user.SamAccountName
            DisplayName    = $user.DisplayName
            LastLogon      = $lastLogon.ToString("yyyy-MM-dd")
            Finding        = "Inactive more than $DaysInactive days"
        }
    }
}

$inactive | Export-Csv -Path $OutputPath -NoTypeInformation

$summary = @(
    "Inactive account report"
    "Source file: $InputPath"
    "Threshold: $DaysInactive days"
    "Total accounts reviewed: $($users.Count)"
    "Inactive enabled accounts found: $(@($inactive).Count)"
    "Detail written to: $OutputPath"
)
$summary | Set-Content -Path $SummaryPath
$summary | ForEach-Object { Write-Host $_ }
