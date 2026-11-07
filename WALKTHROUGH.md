# Walkthrough

A guided tour of the projects in this repository: what to run, what you should see, and the reasoning a reviewer is looking for.

## 1. IAM Policy Review (projects/iam-policy-review)

Start with the checker. You need Python 3; nothing to install.

    python3 policy_check.py policy_before.json

    Policy: policy_before.json
    Findings: 3
      - [statement 1] Action s3:* grants every action in one service
      - [statement 1] Resource is a full wildcard (*): applies to every resource in the account
      - [statement 1] No Condition element: consider source, MFA, or encryption conditions where the workload allows

    python3 policy_check.py policy_after.json

    Policy: policy_after.json
    Findings: 2
      - [ReadSourceBuckets] No Condition element: consider source, MFA, or encryption conditions where the workload allows
      - [WriteResultsOnly] No Condition element: consider source, MFA, or encryption conditions where the workload allows

Read that result correctly: the rewrite clears both wildcard findings, which are the dangerous ones. The two remaining notes are informational. The checker flags the absence of conditions on every statement, and plenty of correct policies carry no condition. Knowing which findings matter and which are noise is the actual skill; the script is the broom, the judgment is yours.

Then open policy_before.json and policy_after.json side by side and trace the three changes: actions narrowed to three calls, resources narrowed to three buckets, and the bucket ARN versus object ARN split (ListBucket sits on the bucket, GetObject and PutObject sit on the objects). That split is the detail interviewers probe, because getting it wrong produces a policy that quietly does nothing.

## 2. Secure Cloud Account Baseline (projects/secure-cloud-account-baseline)

The two scripts, aws_baseline.sh and azure_baseline.sh, are runbooks, not installers. The correct way to use one:

1. Read the checklist in the project README first. The scripts implement it; they do not replace understanding it.
2. Open the script and replace every placeholder (account ID, bucket name, subscription, resource group) with real values.
3. Read each command before running anything. Two steps are deliberately notes instead of commands: root MFA on AWS and Conditional Access on Azure live in consoles and portals, and a script that pretended otherwise would be lying about how the platforms work.
4. Run in the checklist order: identity, then logging, then the rest.
5. Do the Prove it section. Sign in as a standard user, confirm an admin action is denied, trigger one alert on purpose. A baseline that has not been tested is a hope.

Safety: never run a baseline script against an account you do not own or are not authorized to administer, and never run it unreviewed against production. The commands change security settings; that is their purpose, and it is also why the review step exists.

## 3. PowerShell Admin Scripts (projects/powershell-admin-scripts)

    .\inactive_users_report.ps1 -InputPath .\sample_users.csv

The script reads the export and writes two files: inactive_users.csv (the detail) and inactive_users_summary.txt (the counts). What it will always report, on any date: the two accounts with an empty LastLogon, svc-reports and newhire.a, because an enabled account that has never logged on is a finding the day it is created. Which dated accounts join them depends on the run date against the 90-day default threshold: the script measures from today, so the report honestly changes as time passes. That is correct behavior for an inactivity report, and worth being able to say out loud.

Note the design decision the README calls out: the script reports and disables nothing. Disabling is a separate, approved step, taken after owners confirm the accounts are dormant. The loudest complaints in IT come from disabling the service account a report depended on, and svc-reports sits in the sample data to make exactly that point.

To adapt it: point InputPath at any export with the same four columns (SamAccountName, DisplayName, LastLogon, Enabled), and set DaysInactive to the window your policy uses.

## The thread through all three

Least privilege, evidence, and reversibility. The IAM project narrows power to what a job uses. The baseline turns on logging before workloads so decisions leave evidence. The PowerShell project reports before it would ever act. That ordering, narrow, observe, then act, is the whole philosophy, and it transfers to every cloud environment regardless of vendor.
