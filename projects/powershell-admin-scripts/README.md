# PowerShell Admin Scripts

Small reporting scripts for the recurring asks of user administration. This one works from exported data (a CSV) rather than a live directory, because that is how the request usually arrives: an export from HR, a ticketing system, or another team's report.

## inactive_users_report.ps1

Reads a user export with the columns SamAccountName, DisplayName, LastLogon, and Enabled, and writes two files:

- inactive_users.csv: enabled accounts whose last logon is older than the threshold (default 90 days), or that have never logged on
- inactive_users_summary.txt: the counts a ticket or a manager actually reads

### Run it

    .\inactive_users_report.ps1 -InputPath .\sample_users.csv
    .\inactive_users_report.ps1 -InputPath .\export.csv -DaysInactive 60

### Why it matters

Inactive enabled accounts are standing risk: valid credentials nobody watches. Every security baseline asks the same question (who has not logged on in 90 days?), and this turns a half-day of clicking into one command.

### Safety

The script only reports. It disables nothing. Disabling is a separate, approved step taken after owners confirm the accounts are truly dormant, because the loudest complaints in IT come from disabling the service account somebody forgot a report depended on.

### The sample data

sample_users.csv holds ten invented accounts showing the interesting cases: active users, a dormant account, a never-logged-on account, a disabled account that should be excluded, and a service account flagged for a human conversation rather than automatic action.
