# Cloud Security Study Notes

These are my study notes from working through Azure security and the AWS Solutions Architect track, turned into things I can show instead of just claim: a baseline I can run through an account, an IAM policy review with the before and after written out, a report-only PowerShell script for dormant accounts, and an anomaly scorer I built to catch the sign-in that is technically allowed and completely wrong.

## The projects

- projects/signin-anomaly-scorer: learns each user's home city and working hours from a sign-in log, then scores every sign-in with the reasons printed next to the points. In the sample data the 3 AM sign-ins from another continent flag INVESTIGATE while a business trip flags REVIEW, which is the difference between a queue and a false alarm storm.
- projects/secure-cloud-account-baseline: the checklist I run a new account against: MFA everywhere, legacy authentication off, dormant access hunted down, plus the AWS and Azure CLI runbooks, written to be reviewed before anyone runs them.
- projects/iam-policy-review: a worked least privilege rewrite. A wildcard policy that grants everything everywhere becomes a scoped one, and the included checker script proves the wildcards are gone instead of asking you to trust the writeup.
- projects/powershell-admin-scripts: an inactive users report that only reports. It touches nothing, changes nothing, and says so in the header, because an admin script you cannot trust is worse than none.

## The notes

- azure-security-notes.md, aws-architecture-notes.md, powershell-automation-notes.md: concepts in my own words, organized the way I review them before an interview, not copied reference material.

## How I use this repo

WALKTHROUGH.md reproduces the checks: the policy validator finds three problems in the before policy and clears them in the after. I studied the AWS architecture track without sitting the certification exam, and I say so plainly wherever it matters; the notes and projects are the evidence of the study. If I cannot run it in front of you, I do not list it as a skill.

## License

MIT.
