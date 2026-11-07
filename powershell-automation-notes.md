# PowerShell Automation Notes

## Working pattern

PowerShell work follows the pipeline: get objects, filter, then act or report. The verbs are consistent (Get, Set, New, Remove), which makes scripts readable once the pattern clicks.

## User administration staples

    Get-ADUser -Filter * -Properties LastLogonDate
    Get-ADUser -Identity jsmith -Properties MemberOf
    Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 -UsersOnly
    Disable-ADAccount -Identity jsmith
    Unlock-ADAccount -Identity jsmith

Search-ADAccount is the built-in shortcut for the inactive account hunt; the script project in this repo does the same job from exported data, which is how the task often arrives in practice (a CSV from HR or a ticketing system).

## Reporting shape

    Get-ADUser -Filter {Enabled -eq $true} -Properties LastLogonDate |
      Select-Object SamAccountName, Name, LastLogonDate |
      Export-Csv -Path report.csv -NoTypeInformation

Select before export, always: a CSV with forty default properties helps nobody.

## Safety rules learned

- WhatIf first on anything that changes state: Remove and Set cmdlets support it, and it costs nothing.
- Never run a bulk change against a filter you have not first run as a Get. Count the objects before you touch them.
- Log what the script did: a transcript or a written list of changed accounts goes with the ticket.
- Test accounts and a test OU are not optional for automation work.
