# Azure Security Notes

## Identity: Microsoft Entra ID

- Identity is the primary control plane in Azure. Most breaches start with a credential, not a network hole.
- MFA for every user, without exception lists that quietly grow. Privileged accounts get phishing-resistant methods.
- Conditional Access policies worth having on day one: block legacy authentication, require MFA for admins, require compliant or hybrid joined devices for sensitive apps, block sign-ins from countries the business never operates in.
- Break-glass accounts: two, cloud-only, excluded from Conditional Access, credentials sealed and alarmed on any use.

## Access control: Azure RBAC

- Assign roles to groups, not individuals, at the narrowest scope that works (resource group before subscription, subscription before management group).
- The roles that matter: Owner and Contributor are powerful; User Access Administrator is as sensitive as Owner because it can grant the others.
- Privileged Identity Management turns standing admin into just-in-time admin. Standing privilege is the risk; eligibility with approval and expiry is the control.
- Review access on a schedule. Permissions accumulate; nobody gives them back voluntarily.

## Network

- Network security groups are allow-list firewalls per subnet or NIC. Default deny inbound from the internet; open ports deliberately, one rule at a time.
- Management ports (3389, 22) should never face the internet. Use Azure Bastion or just-in-time VM access instead.
- Private endpoints keep storage and database traffic off the public internet entirely.

## Data and secrets

- Key Vault for secrets and keys, with its own access policies or RBAC, soft delete on, purge protection on for production.
- Storage accounts: public blob access off unless the workload truly publishes files.

## Monitoring

- Microsoft Defender for Cloud gives the secure score and the findings list; work it like a ticket queue.
- Activity Log and Entra sign-in logs to a Log Analytics workspace, with alerts on role assignments, policy changes, and impossible travel sign-ins.
- A log nobody alerts on is an archive, not a control.
