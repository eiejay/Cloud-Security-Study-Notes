# Secure Cloud Account Baseline

The hardening pass for a brand new cloud account, done before any workload is deployed. New accounts are born permissive; this is the checklist that closes the defaults in the right order. Written generically so it applies to AWS or Azure; the platform name for each control is noted.

## 1. Root and owner accounts

- [ ] MFA enabled on the AWS root user / Azure account owner, hardware key or authenticator, not SMS
- [ ] Root credentials sealed; a named break-glass procedure written down
- [ ] Billing alerts set at 50, 80, and 100 percent of the monthly budget (AWS Budgets / Azure Cost Management)
- [ ] Account contact details and alternate contacts verified

## 2. Identity

- [ ] Daily work uses individual named accounts, never root
- [ ] Admin access granted through groups or roles, with MFA required
- [ ] No long-term access keys for people; temporary credentials and SSO where available
- [ ] Password policy: length over complexity games, breached password screening on (Entra ID Protection / IAM password policy)
- [ ] Dormant account review scheduled monthly

## 3. Logging before workloads

- [ ] CloudTrail on in all regions / Azure Activity Log routed to a workspace
- [ ] Log storage locked: versioning on, delete protection on, separate from daily admin reach
- [ ] GuardDuty on / Defender for Cloud plan enabled
- [ ] Alerts live for: role or policy changes, new admin grants, sign-ins from new countries, root usage

## 4. Network and data defaults

- [ ] Default VPC security posture reviewed; no default rule allows inbound from 0.0.0.0/0 on management ports
- [ ] Account-level S3 Block Public Access on / storage public access defaults off
- [ ] Encryption by default for new storage
- [ ] Tags required from day one: owner, environment, purpose. Retrofitting tags is misery; starting with them is free

## 5. Prove it

- [ ] Sign in as a standard user and confirm admin actions are denied
- [ ] Trigger one alert deliberately (grant a test role) and confirm it arrives
- [ ] Export the configuration evidence into the account record: who, when, and what was set

## Why this order

Identity first, because credentials are the main attack path. Logging second, because controls without evidence are opinions. Everything after that is refinement. An account hardened after workloads land takes ten times longer and still misses things.
