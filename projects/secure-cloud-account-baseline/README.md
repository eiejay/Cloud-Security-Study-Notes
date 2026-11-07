# Secure Cloud Account Baseline

The hardening pass for a brand new cloud account, done before any workload is deployed, with the runbooks that apply it. New accounts are born permissive; this closes the defaults in the right order.

## Files

- aws_baseline.sh: AWS CLI commands for the AWS controls below
- azure_baseline.sh: Azure CLI commands for the Azure controls below

Both scripts are runbooks: read them, replace the placeholders, and run them deliberately. Steps that only exist in a console or portal (root MFA, Conditional Access) are written into the scripts as notes at the point where they belong, so the order is not lost.

## 1. Root and owner accounts

- MFA enabled on the root or owner account, authenticator or hardware key, not SMS
- Root credentials sealed; a named break-glass procedure written down
- Budget alerts at 50, 80, and 100 percent of the monthly budget
- Account contact details verified

## 2. Identity

- Daily work uses individual named accounts, never root
- Admin access through groups or roles, MFA required
- No long-term access keys for people; temporary credentials and SSO where available
- Password policy: length over complexity games
- Dormant account review scheduled monthly (see the PowerShell Admin Scripts project for the reporting side)

## 3. Logging before workloads

- CloudTrail on in all regions / Azure Activity Log routed to a workspace
- Log storage locked: versioning on, public access off
- GuardDuty on / Defender for Cloud plans enabled
- Alerts live for: role or policy changes, new admin grants, sign-ins from new countries, root usage

## 4. Network and data defaults

- No default rule allows inbound from 0.0.0.0/0 on management ports
- Account-level public access blocks on for storage
- Encryption by default for new storage
- Tags from day one: owner, environment, purpose

## 5. Prove it

- Sign in as a standard user and confirm admin actions are denied
- Trigger one alert deliberately and confirm it arrives
- File the configuration evidence: who, when, and what was set

## Why this order

Identity first, because credentials are the main attack path. Logging second, because controls without evidence are opinions. Everything after that is refinement. An account hardened after workloads land takes ten times longer and still misses things.
